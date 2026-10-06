"""Readers together: handles, friends, follows, reviews, recommendations and the feed.

Every read goes through the viewer's relation to the reader: a reader's private content is
never returned to anyone else, friends-only content only to mutual friends.
"""

from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from uuid import UUID, uuid4

from babel_api.adapters.db.social_repository import SqlSocialRepository
from babel_api.domain.errors import (
    InvalidHandleError,
    NotFoundError,
    NotFriendsError,
)
from babel_api.domain.files import LibraryItem
from babel_api.domain.ports import FileRepository
from babel_api.domain.social import (
    Audience,
    BookNote,
    BookTrace,
    FeedEntry,
    FeedKind,
    FriendStatus,
    Profile,
    Reading,
    Recommendation,
    Relation,
    Report,
    ReportReason,
    Review,
    SharedNote,
    SharedShelf,
    normalize_handle,
)
from babel_api.services.notifications import Notifier

MAX_REVIEW = 5000
MAX_MESSAGE = 1000
READING_WINDOW = timedelta(days=60)


@dataclass(frozen=True, slots=True)
class Reader:
    """Another reader as the viewer sees them."""

    profile: Profile
    relation: Relation


@dataclass(frozen=True, slots=True)
class ReaderPage:
    reader: Reader
    friends: int
    followers: int
    books: int | None
    reading: list[Reading]
    library: list[tuple[str, tuple[str, ...]]] | None
    reviews: list[Review]
    notes: list[SharedNote]
    finished: list[Reading]
    shelves: list[SharedShelf]


@dataclass(frozen=True, slots=True)
class WorkReaders:
    """What readers left on a work, across all its editions and files."""

    reviews: list[Review]
    notes: list[SharedNote]
    profiles: dict[UUID, Profile]

    @property
    def rating(self) -> tuple[float | None, int]:
        """Average rating of the reviews shown, and how many have one."""
        ratings = [r.rating for r in self.reviews if r.rating]
        return (sum(ratings) / len(ratings) if ratings else None, len(ratings))


@dataclass(frozen=True, slots=True)
class Friends:
    friends: list[Reader]
    incoming: list[Reader]
    outgoing: list[Reader]
    following: list[Reader]


class SocialService:
    def __init__(
        self,
        social: SqlSocialRepository,
        files: FileRepository,
        notifier: Notifier | None = None,
    ) -> None:
        self._social = social
        self._files = files
        self._notifier = notifier

    # ------------------------------------------------------------ own profile
    async def profile(self, user_id: UUID) -> Profile:
        profile = await self._social.profile(user_id)
        if profile is None:
            raise NotFoundError
        return profile

    async def update_profile(
        self,
        user_id: UUID,
        *,
        handle: str | None = None,
        share_reading: Audience | None = None,
        share_library: Audience | None = None,
    ) -> Profile:
        normalized = None
        if handle is not None:
            try:
                normalized = normalize_handle(handle)
            except ValueError as error:
                raise InvalidHandleError from error
        await self._social.save_profile(
            user_id, handle=normalized, share_reading=share_reading, share_library=share_library
        )
        await self._social.commit()
        return await self.profile(user_id)

    # ------------------------------------------------------------ relations
    async def relation(self, viewer: UUID, other: UUID) -> Relation:
        friendship = await self._social.friendship(viewer, other)
        if friendship is None:
            friend = FriendStatus.NONE
        elif friendship[1]:
            friend = FriendStatus.FRIENDS
        else:
            friend = FriendStatus.REQUESTED if friendship[0] == viewer else FriendStatus.INCOMING
        return Relation(
            friend=friend,
            following=await self._social.is_following(viewer, other),
            follows_you=await self._social.is_following(other, viewer),
        )

    async def _reader(self, viewer: UUID, profile: Profile) -> Reader:
        return Reader(profile, await self.relation(viewer, profile.user_id))

    async def _readers(self, viewer: UUID, user_ids: list[UUID]) -> list[Reader]:
        profiles = await self._social.profiles(user_ids)
        return [await self._reader(viewer, profiles[u]) for u in user_ids if u in profiles]

    async def _other(self, viewer: UUID, handle: str) -> Profile:
        try:
            profile = await self._social.by_handle(normalize_handle(handle))
        except ValueError as error:
            raise NotFoundError from error
        if profile is None or profile.user_id == viewer:
            raise NotFoundError
        if profile.user_id in await self._social.hidden(viewer):
            raise NotFoundError  # blocked, one way or the other: invisible
        return profile

    async def search(self, viewer: UUID, query: str, limit: int = 20) -> list[Reader]:
        prefix = query.strip().removeprefix("@").lower()
        if len(prefix) < 2:
            return []
        hidden = await self._social.hidden(viewer)
        return [
            await self._reader(viewer, p)
            for p in await self._social.search(prefix, exclude=viewer, limit=limit)
            if p.user_id not in hidden
        ]

    async def add_friend(self, viewer: UUID, handle: str) -> Reader:
        """Sends a friend request, or accepts the one this reader sent."""
        other = await self._other(viewer, handle)
        friendship = await self._social.friendship(viewer, other.user_id)
        if friendship is None:
            await self._social.request_friend(viewer, other.user_id)
            await self._social.commit()
            await self._notify(other.user_id, "friend_request", viewer)
        elif not friendship[1] and friendship[0] == other.user_id:
            await self._social.accept_friend(other.user_id, viewer, datetime.now(UTC))
            await self._social.commit()
            await self._notify(other.user_id, "friend_accepted", viewer)
        return await self._reader(viewer, other)

    async def remove_friend(self, viewer: UUID, handle: str) -> Reader:
        """Cancels a request, declines one, or ends a friendship."""
        other = await self._other(viewer, handle)
        await self._social.remove_friendship(viewer, other.user_id)
        await self._social.commit()
        return await self._reader(viewer, other)

    async def follow(self, viewer: UUID, handle: str) -> Reader:
        other = await self._other(viewer, handle)
        await self._social.follow(viewer, other.user_id)
        await self._social.commit()
        return await self._reader(viewer, other)

    async def unfollow(self, viewer: UUID, handle: str) -> Reader:
        other = await self._other(viewer, handle)
        await self._social.unfollow(viewer, other.user_id)
        await self._social.commit()
        return await self._reader(viewer, other)

    async def friends(self, viewer: UUID) -> Friends:
        incoming, outgoing = await self._social.requests(viewer)
        return Friends(
            friends=await self._readers(viewer, await self._social.friends(viewer)),
            incoming=await self._readers(viewer, incoming),
            outgoing=await self._readers(viewer, outgoing),
            following=await self._readers(viewer, await self._social.following(viewer)),
        )

    # ------------------------------------------------------------ blocking and reporting
    async def block(self, viewer: UUID, handle: str) -> None:
        """Ends friendship and follows both ways; neither sees the other any more."""
        other = await self._other(viewer, handle)
        await self._social.block(viewer, other.user_id)
        await self._social.commit()

    async def unblock(self, viewer: UUID, handle: str) -> None:
        try:
            profile = await self._social.by_handle(normalize_handle(handle))
        except ValueError as error:
            raise NotFoundError from error
        if profile is None:
            raise NotFoundError
        await self._social.unblock(viewer, profile.user_id)
        await self._social.commit()

    async def blocked(self, viewer: UUID) -> list[Profile]:
        ids = await self._social.blocked(viewer)
        profiles = await self._social.profiles(ids)
        return [profiles[i] for i in ids if i in profiles]

    async def report(
        self, viewer: UUID, handle: str, reason: ReportReason, note: str | None
    ) -> None:
        """Tells the administrators; the reader reported is not told."""
        other = await self._other(viewer, handle)
        await self._social.add_report(
            Report(
                id=uuid4(),
                reporter_id=viewer,
                reported_id=other.user_id,
                reason=reason,
                note=(note or "").strip()[:MAX_MESSAGE] or None,
                created_at=datetime.now(UTC),
            )
        )
        await self._social.commit()
        for admin in await self._social.admins():
            await self._notify(admin, "report", other.user_id)

    async def reports(self) -> tuple[list[Report], dict[UUID, Profile]]:
        found = await self._social.reports(200)
        ids = list({r.reporter_id for r in found} | {r.reported_id for r in found})
        return found, await self._social.profiles(ids)

    async def resolve_report(self, report_id: UUID) -> None:
        if not await self._social.resolve_report(report_id, datetime.now(UTC)):
            raise NotFoundError
        await self._social.commit()

    # ------------------------------------------------------------ a reader's page
    def _audiences(self, relation: Relation) -> list[Audience]:
        if relation.friend is FriendStatus.FRIENDS:
            return [Audience.FRIENDS, Audience.PUBLIC]
        return [Audience.PUBLIC]

    async def reader_page(self, viewer: UUID, handle: str) -> ReaderPage:
        other = await self._other(viewer, handle)
        relation = await self.relation(viewer, other.user_id)
        audiences = self._audiences(relation)
        user = other.user_id
        sees_reading = relation.sees(other.share_reading)
        sees_library = relation.sees(other.share_library)
        since = datetime.now(UTC) - READING_WINDOW
        return ReaderPage(
            reader=Reader(other, relation),
            friends=len(await self._social.friends(user)),
            followers=await self._social.follower_count(user),
            books=await self._social.library_count(user) if sees_library else None,
            reading=await self._social.reading([user], since, 10) if sees_reading else [],
            library=await self._social.library(user, 200) if sees_library else None,
            reviews=await self._social.reviews([user], audiences, 50),
            notes=await self._social.notes([user], audiences, 50),
            finished=await self._social.finished([user], None, 10) if sees_reading else [],
            shelves=await self._social.shelves(user, audiences),
        )

    # ------------------------------------------------------------ feed
    async def feed(
        self, viewer: UUID, limit: int = 50
    ) -> tuple[list[FeedEntry], dict[UUID, Profile]]:
        """What friends and followed readers shared lately, newest first."""
        hidden = await self._social.hidden(viewer)
        friends = set(await self._social.friends(viewer)) - hidden
        followed = set(await self._social.following(viewer)) - friends - hidden
        people = list(friends | followed)
        profiles = await self._social.profiles(people)
        entries: list[FeedEntry] = []
        since = datetime.now(UTC) - READING_WINDOW
        for reading in await self._social.reading(people, since, limit):
            profile = profiles.get(reading.user_id)
            relation = Relation(
                friend=FriendStatus.FRIENDS if reading.user_id in friends else FriendStatus.NONE
            )
            if profile and relation.sees(profile.share_reading):
                entries.append(
                    FeedEntry(
                        FeedKind.READING,
                        reading.user_id,
                        reading.at,
                        reading.title,
                        reading.authors,
                        percent=reading.percent,
                    )
                )
        for done in await self._social.finished(people, since, limit):
            profile = profiles.get(done.user_id)
            relation = Relation(
                friend=FriendStatus.FRIENDS if done.user_id in friends else FriendStatus.NONE
            )
            if profile and relation.sees(profile.share_reading):
                entries.append(
                    FeedEntry(FeedKind.FINISHED, done.user_id, done.at, done.title, done.authors)
                )
        for group, audiences in (
            (list(friends), [Audience.FRIENDS, Audience.PUBLIC]),
            (list(followed), [Audience.PUBLIC]),
        ):
            for review in await self._social.reviews(group, audiences, limit):
                entries.append(
                    FeedEntry(
                        FeedKind.REVIEW,
                        review.user_id,
                        review.updated_at,
                        review.title,
                        review.authors,
                        rating=review.rating,
                        text=review.text,
                    )
                )
            for note in await self._social.notes(group, audiences, limit):
                entries.append(
                    FeedEntry(
                        FeedKind.NOTE,
                        note.user_id,
                        note.at,
                        note.title,
                        quote=note.quote or None,
                        text=note.note,
                    )
                )
        entries.sort(key=lambda e: e.at, reverse=True)
        return entries[:limit], profiles

    # ------------------------------------------------------------ a work
    async def work_readers(self, viewer: UUID, work_id: UUID) -> WorkReaders:
        """Reviews and notes of every reader on a work, whatever the edition they read."""
        hidden = list(await self._social.hidden(viewer))
        friends = await self._social.friends(viewer)
        reviews = await self._social.work_reviews(work_id, viewer, friends, hidden, 100)
        notes = await self._social.work_notes(work_id, viewer, friends, hidden, 100)
        people = list({r.user_id for r in reviews} | {n.user_id for n in notes})
        return WorkReaders(reviews, notes, await self._social.profiles(people))

    async def book_notes(
        self, viewer: UUID, item_id: UUID
    ) -> tuple[list[BookNote], dict[UUID, Profile]]:
        """Other readers' notes to show in the viewer's copy of a book, whatever edition
        they were written in."""
        item = await self._own_item(viewer, item_id)
        hidden = list(await self._social.hidden(viewer))
        friends = await self._social.friends(viewer)
        notes = await self._social.book_notes(
            item.work_id, item.file.sha256, viewer, friends, hidden, 500
        )
        return notes, await self._social.profiles(list({n.user_id for n in notes}))

    # ------------------------------------------------------------ history
    async def history(self, user_id: UUID) -> list[BookTrace]:
        """Every book the reader has or once had, with what they left on it.

        Removing a book, or the file going away, never erases the reader's data: it is
        shown again on the book's page and in searches, and comes back with the book.
        """
        items = await self._files.all_items(user_id)
        reviews = await self._social.reviews_by_item(user_id)
        notes = await self._social.note_counts(user_id)
        works = await self._social.work_ids(
            list({i.file.edition_id for i in items if i.file.edition_id and not i.work_id})
        )
        return [
            BookTrace(
                item=item,
                work_id=item.work_id
                or (works.get(item.file.edition_id) if item.file.edition_id else None),
                review=reviews.get(item.id),
                notes=notes.get(item.file.sha256, 0),
                available=item.file.available,
            )
            for item in items
        ]

    # ------------------------------------------------------------ reviews
    async def _own_item(self, user_id: UUID, item_id: UUID) -> LibraryItem:
        item = await self._files.get_item(item_id)
        if item is None or item.user_id != user_id:
            raise NotFoundError
        return item

    async def review(self, user_id: UUID, item_id: UUID) -> Review | None:
        await self._own_item(user_id, item_id)
        return await self._social.review(user_id, item_id)

    async def save_review(
        self,
        user_id: UUID,
        item_id: UUID,
        *,
        rating: int | None,
        text: str | None,
        audience: Audience,
    ) -> Review:
        item = await self._own_item(user_id, item_id)
        text = (text or "").strip() or None
        if rating is not None and not 1 <= rating <= 5:
            raise ValueError("rating")
        if text is not None and len(text) > MAX_REVIEW:
            text = text[:MAX_REVIEW]
        now = datetime.now(UTC)
        existing = await self._social.review(user_id, item_id)
        review = Review(
            id=existing.id if existing else uuid4(),
            user_id=user_id,
            item_id=item_id,
            title=item.title,
            authors=item.authors,
            rating=rating,
            text=text,
            audience=audience,
            created_at=existing.created_at if existing else now,
            updated_at=now,
        )
        saved = await self._social.save_review(review)
        await self._social.commit()
        return saved

    async def delete_review(self, user_id: UUID, item_id: UUID) -> None:
        await self._own_item(user_id, item_id)
        await self._social.delete_review(user_id, item_id)
        await self._social.commit()

    # ------------------------------------------------------------ recommendations
    async def recommend(
        self,
        sender: UUID,
        handle: str,
        *,
        item_id: UUID | None = None,
        title: str | None = None,
        authors: tuple[str, ...] = (),
        url: str | None = None,
        message: str | None = None,
    ) -> Recommendation:
        """Suggests a book of the sender's library, or any title or link, to a friend."""
        other = await self._other(sender, handle)
        if (await self.relation(sender, other.user_id)).friend is not FriendStatus.FRIENDS:
            raise NotFriendsError
        if item_id is not None:
            item = await self._own_item(sender, item_id)
            title, authors = item.title, item.authors
        if not title or not title.strip():
            raise ValueError("title")
        recommendation = await self._social.add_recommendation(
            Recommendation(
                id=uuid4(),
                sender_id=sender,
                recipient_id=other.user_id,
                title=title.strip(),
                authors=authors,
                url=url,
                message=(message or "").strip()[:MAX_MESSAGE] or None,
                created_at=datetime.now(UTC),
            )
        )
        await self._social.commit()
        await self._notify(other.user_id, "recommendation", sender, title.strip())
        return recommendation

    async def recommendations(
        self, user_id: UUID
    ) -> tuple[list[Recommendation], dict[UUID, Profile]]:
        found = await self._social.recommendations(user_id, 100)
        return found, await self._social.profiles(list({r.sender_id for r in found}))

    async def mark_read(self, user_id: UUID, recommendation_id: UUID) -> None:
        if not await self._social.mark_read(user_id, recommendation_id, datetime.now(UTC)):
            raise NotFoundError
        await self._social.commit()

    # ------------------------------------------------------------ notifications
    async def _notify(
        self, recipient: UUID, kind: str, sender: UUID, title: str | None = None
    ) -> None:
        if self._notifier is None:
            return
        profile = await self._social.profile(sender)
        if profile is None:
            return
        await self._notifier.social(recipient, kind, profile.display_name, profile.handle, title)
