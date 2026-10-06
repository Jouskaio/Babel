"""SQLAlchemy storage of profiles, friendships, follows, reviews and recommendations."""

from collections.abc import Sequence
from datetime import UTC, datetime
from typing import Any
from uuid import UUID

from sqlalchemy import and_, delete, func, or_, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from babel_api.adapters.db.models import (
    AnnotationRow,
    BlockRow,
    EditionRow,
    FriendshipRow,
    LibraryItemRow,
    ReadingPositionRow,
    RecommendationRow,
    ReportRow,
    ReviewRow,
    ShelfItemRow,
    ShelfRow,
    SocialProfileRow,
    SubscriptionRow,
    UserRow,
)
from babel_api.domain.errors import HandleTakenError
from babel_api.domain.files import ReadingStatus
from babel_api.domain.social import (
    Audience,
    Profile,
    Reading,
    Recommendation,
    Report,
    ReportReason,
    Review,
    SharedNote,
    SharedShelf,
)


def _aware(value: datetime) -> datetime:
    return value if value.tzinfo else value.replace(tzinfo=UTC)


# Reading statuses as stored (domain ReadingStatus).
_READING = ReadingStatus.READING.value
_FINISHED = ReadingStatus.FINISHED.value
_DONE = (ReadingStatus.FINISHED.value, ReadingStatus.ABANDONED.value)


# Books other readers may see: neither hidden nor taken out of the library.
_SHOWN = and_(LibraryItemRow.hidden.is_(False), LibraryItemRow.removed_at.is_(None))


def _reading(item: LibraryItemRow, percent: float, at: datetime) -> Reading:
    return Reading(
        user_id=item.user_id,
        item_id=item.id,
        title=item.title,
        authors=tuple(item.authors or ()),
        percent=percent,
        at=_aware(at),
    )


def _profile(user: UserRow, row: SocialProfileRow | None) -> Profile:
    return Profile(
        user_id=user.id,
        handle=row.handle if row else None,
        display_name=user.display_name,
        share_reading=Audience(row.share_reading) if row else Audience.FRIENDS,
        share_library=Audience(row.share_library) if row else Audience.FRIENDS,
    )


def _review(row: ReviewRow) -> Review:
    return Review(
        id=row.id,
        user_id=row.user_id,
        item_id=row.item_id,
        title=row.title,
        authors=tuple(row.authors or ()),
        rating=row.rating,
        text=row.text,
        audience=Audience(row.audience),
        created_at=_aware(row.created_at),
        updated_at=_aware(row.updated_at),
    )


def _recommendation(row: RecommendationRow) -> Recommendation:
    return Recommendation(
        id=row.id,
        sender_id=row.sender_id,
        recipient_id=row.recipient_id,
        title=row.title,
        authors=tuple(row.authors or ()),
        url=row.url,
        message=row.message,
        created_at=_aware(row.created_at),
        read_at=_aware(row.read_at) if row.read_at else None,
    )


class SqlSocialRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    # ------------------------------------------------------------ profiles
    async def profile(self, user_id: UUID) -> Profile | None:
        user = await self._session.get(UserRow, user_id)
        if user is None:
            return None
        return _profile(user, await self._session.get(SocialProfileRow, user_id))

    async def profiles(self, user_ids: Sequence[UUID]) -> dict[UUID, Profile]:
        if not user_ids:
            return {}
        rows = await self._session.execute(
            select(UserRow, SocialProfileRow)
            .outerjoin(SocialProfileRow, SocialProfileRow.user_id == UserRow.id)
            .where(UserRow.id.in_(user_ids))
        )
        return {user.id: _profile(user, profile) for user, profile in rows}

    async def by_handle(self, handle: str) -> Profile | None:
        row = await self._session.scalar(
            select(SocialProfileRow).where(SocialProfileRow.handle == handle)
        )
        if row is None:
            return None
        return _profile(await self._session.get_one(UserRow, row.user_id), row)

    async def search(self, prefix: str, exclude: UUID, limit: int) -> list[Profile]:
        escaped = prefix.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")
        rows = await self._session.execute(
            select(UserRow, SocialProfileRow)
            .join(SocialProfileRow, SocialProfileRow.user_id == UserRow.id)
            .where(
                SocialProfileRow.handle.like(f"{escaped}%", escape="\\"),
                UserRow.id != exclude,
            )
            .order_by(func.length(SocialProfileRow.handle), SocialProfileRow.handle)
            .limit(limit)
        )
        return [_profile(user, profile) for user, profile in rows]

    async def save_profile(
        self,
        user_id: UUID,
        *,
        handle: str | None = None,
        share_reading: Audience | None = None,
        share_library: Audience | None = None,
    ) -> None:
        row = await self._session.get(SocialProfileRow, user_id)
        if row is None:
            row = SocialProfileRow(
                user_id=user_id,
                share_reading=Audience.FRIENDS.value,
                share_library=Audience.FRIENDS.value,
            )
            self._session.add(row)
        if handle is not None:
            taken = await self._session.scalar(
                select(SocialProfileRow.user_id).where(
                    SocialProfileRow.handle == handle, SocialProfileRow.user_id != user_id
                )
            )
            if taken is not None:
                raise HandleTakenError
            row.handle = handle
        if share_reading is not None:
            row.share_reading = share_reading.value
        if share_library is not None:
            row.share_library = share_library.value
        try:
            await self._session.flush()
        except IntegrityError as error:  # taken at the same moment
            raise HandleTakenError from error

    # ------------------------------------------------------------ friends
    def _pair(self, a: UUID, b: UUID) -> Any:
        return or_(
            and_(FriendshipRow.requester_id == a, FriendshipRow.addressee_id == b),
            and_(FriendshipRow.requester_id == b, FriendshipRow.addressee_id == a),
        )

    async def friendship(self, a: UUID, b: UUID) -> tuple[UUID, bool] | None:
        """(who asked, accepted) between two readers, if anything."""
        row = await self._session.scalar(select(FriendshipRow).where(self._pair(a, b)))
        return (row.requester_id, row.accepted_at is not None) if row else None

    async def request_friend(self, requester: UUID, addressee: UUID) -> None:
        self._session.add(FriendshipRow(requester_id=requester, addressee_id=addressee))
        await self._session.flush()

    async def accept_friend(self, requester: UUID, addressee: UUID, at: datetime) -> None:
        row = await self._session.scalar(
            select(FriendshipRow).where(
                FriendshipRow.requester_id == requester, FriendshipRow.addressee_id == addressee
            )
        )
        if row is not None:
            row.accepted_at = at
            await self._session.flush()

    async def remove_friendship(self, a: UUID, b: UUID) -> None:
        await self._session.execute(delete(FriendshipRow).where(self._pair(a, b)))

    async def friends(self, user_id: UUID) -> list[UUID]:
        rows = await self._session.execute(
            select(FriendshipRow.requester_id, FriendshipRow.addressee_id).where(
                FriendshipRow.accepted_at.is_not(None),
                or_(FriendshipRow.requester_id == user_id, FriendshipRow.addressee_id == user_id),
            )
        )
        return [b if a == user_id else a for a, b in rows]

    async def requests(self, user_id: UUID) -> tuple[list[UUID], list[UUID]]:
        """(incoming, outgoing) pending requests."""
        rows = await self._session.execute(
            select(FriendshipRow.requester_id, FriendshipRow.addressee_id).where(
                FriendshipRow.accepted_at.is_(None),
                or_(FriendshipRow.requester_id == user_id, FriendshipRow.addressee_id == user_id),
            )
        )
        incoming: list[UUID] = []
        outgoing: list[UUID] = []
        for requester, addressee in rows:
            (outgoing if requester == user_id else incoming).append(
                addressee if requester == user_id else requester
            )
        return incoming, outgoing

    # ------------------------------------------------------------ follows
    async def is_following(self, follower: UUID, followee: UUID) -> bool:
        return await self._session.get(SubscriptionRow, (follower, followee)) is not None

    async def follow(self, follower: UUID, followee: UUID) -> None:
        if not await self.is_following(follower, followee):
            self._session.add(SubscriptionRow(follower_id=follower, followee_id=followee))
            await self._session.flush()

    async def unfollow(self, follower: UUID, followee: UUID) -> None:
        await self._session.execute(
            delete(SubscriptionRow).where(
                SubscriptionRow.follower_id == follower, SubscriptionRow.followee_id == followee
            )
        )

    async def following(self, user_id: UUID) -> list[UUID]:
        return list(
            await self._session.scalars(
                select(SubscriptionRow.followee_id).where(SubscriptionRow.follower_id == user_id)
            )
        )

    async def follower_count(self, user_id: UUID) -> int:
        count = await self._session.scalar(
            select(func.count())
            .select_from(SubscriptionRow)
            .where(SubscriptionRow.followee_id == user_id)
        )
        return int(count or 0)

    # ------------------------------------------------------------ reviews
    async def review(self, user_id: UUID, item_id: UUID) -> Review | None:
        row = await self._session.scalar(
            select(ReviewRow).where(ReviewRow.user_id == user_id, ReviewRow.item_id == item_id)
        )
        return _review(row) if row else None

    async def save_review(self, review: Review) -> Review:
        row = await self._session.scalar(
            select(ReviewRow).where(
                ReviewRow.user_id == review.user_id, ReviewRow.item_id == review.item_id
            )
        )
        if row is None:
            row = ReviewRow(
                id=review.id,
                user_id=review.user_id,
                item_id=review.item_id,
                created_at=review.created_at,
            )
            self._session.add(row)
        row.title, row.authors = review.title[:500], list(review.authors[:5])
        row.rating, row.text = review.rating, review.text
        row.audience, row.updated_at = review.audience.value, review.updated_at
        await self._session.flush()
        return _review(row)

    async def delete_review(self, user_id: UUID, item_id: UUID) -> None:
        await self._session.execute(
            delete(ReviewRow).where(ReviewRow.user_id == user_id, ReviewRow.item_id == item_id)
        )

    async def reviews(
        self, user_ids: Sequence[UUID], audiences: Sequence[Audience], limit: int
    ) -> list[Review]:
        if not user_ids:
            return []
        rows = await self._session.scalars(
            select(ReviewRow)
            .where(
                ReviewRow.user_id.in_(user_ids),
                ReviewRow.audience.in_([a.value for a in audiences]),
            )
            .order_by(ReviewRow.updated_at.desc())
            .limit(limit)
        )
        return [_review(row) for row in rows]

    # ------------------------------------------------------------ recommendations
    async def add_recommendation(self, recommendation: Recommendation) -> Recommendation:
        row = RecommendationRow(
            id=recommendation.id,
            sender_id=recommendation.sender_id,
            recipient_id=recommendation.recipient_id,
            title=recommendation.title[:500],
            authors=list(recommendation.authors[:5]),
            url=recommendation.url,
            message=recommendation.message,
            created_at=recommendation.created_at,
        )
        self._session.add(row)
        await self._session.flush()
        return _recommendation(row)

    async def recommendations(self, recipient: UUID, limit: int) -> list[Recommendation]:
        rows = await self._session.scalars(
            select(RecommendationRow)
            .where(RecommendationRow.recipient_id == recipient)
            .order_by(RecommendationRow.created_at.desc())
            .limit(limit)
        )
        return [_recommendation(row) for row in rows]

    async def mark_read(self, recipient: UUID, recommendation_id: UUID, at: datetime) -> bool:
        row = await self._session.get(RecommendationRow, recommendation_id)
        if row is None or row.recipient_id != recipient:
            return False
        row.read_at = row.read_at or at
        await self._session.flush()
        return True

    # ------------------------------------------------------------ reading, library, notes
    async def reading(self, user_ids: Sequence[UUID], since: datetime, limit: int) -> list[Reading]:
        """Books started and not finished, read since [since], latest first."""
        if not user_ids:
            return []
        latest = (
            select(
                ReadingPositionRow.item_id,
                func.max(ReadingPositionRow.client_time).label("at"),
            )
            .where(ReadingPositionRow.user_id.in_(user_ids))
            .group_by(ReadingPositionRow.item_id)
            .subquery()
        )
        rows = await self._session.execute(
            select(ReadingPositionRow, LibraryItemRow)
            .join(
                latest,
                and_(
                    latest.c.item_id == ReadingPositionRow.item_id,
                    latest.c.at == ReadingPositionRow.client_time,
                ),
            )
            .join(LibraryItemRow, LibraryItemRow.id == ReadingPositionRow.item_id)
            .where(
                ReadingPositionRow.client_time >= since,
                ReadingPositionRow.percent > 0,
                ReadingPositionRow.percent < 99.5,
                or_(LibraryItemRow.status.is_(None), LibraryItemRow.status.not_in(_DONE)),
                _SHOWN,
            )
            .order_by(ReadingPositionRow.client_time.desc())
            .limit(limit)
        )
        found: dict[UUID, Reading] = {}
        for position, item in rows:
            if item.id not in found:
                found[item.id] = _reading(item, position.percent, position.client_time)
        # Progress declared by hand (a book read elsewhere) counts when it is newer.
        declared = await self._session.scalars(
            select(LibraryItemRow)
            .where(
                LibraryItemRow.user_id.in_(user_ids),
                LibraryItemRow.status == _READING,
                LibraryItemRow.state_time >= since,
                _SHOWN,
            )
            .order_by(LibraryItemRow.state_time.desc())
            .limit(limit)
        )
        for item in declared:
            known = found.get(item.id)
            when = item.state_time
            if when is None or (known is not None and known.at >= _aware(when)):
                continue
            percent = item.progress
            if percent is None:
                percent = known.percent if known else 0
            found[item.id] = _reading(item, percent, when)
        return sorted(found.values(), key=lambda r: r.at, reverse=True)[:limit]

    async def finished(
        self, user_ids: Sequence[UUID], since: datetime | None, limit: int
    ) -> list[Reading]:
        """Books finished (since [since]), latest first."""
        if not user_ids:
            return []
        query = select(LibraryItemRow).where(
            LibraryItemRow.user_id.in_(user_ids),
            LibraryItemRow.status == _FINISHED,
            LibraryItemRow.finished_at.is_not(None),
            _SHOWN,
        )
        if since is not None:
            query = query.where(LibraryItemRow.finished_at >= since)
        items = await self._session.scalars(
            query.order_by(LibraryItemRow.finished_at.desc()).limit(limit)
        )
        return [_reading(item, 100, item.finished_at) for item in items if item.finished_at]

    async def shelves(self, user_id: UUID, audiences: Sequence[Audience]) -> list[SharedShelf]:
        """The reader's shelves shown to [audiences], with their books in order."""
        shelves = (
            await self._session.scalars(
                select(ShelfRow)
                .where(
                    ShelfRow.user_id == user_id,
                    ShelfRow.visibility.in_([a.value for a in audiences]),
                )
                .order_by(ShelfRow.created_at)
            )
        ).all()
        found: list[SharedShelf] = []
        for shelf in shelves:
            books = await self._session.execute(
                select(LibraryItemRow.title, LibraryItemRow.authors)
                .join(ShelfItemRow, ShelfItemRow.item_id == LibraryItemRow.id)
                .where(ShelfItemRow.shelf_id == shelf.id, _SHOWN)
                .order_by(ShelfItemRow.position)
                .limit(200)
            )
            found.append(
                SharedShelf(
                    name=shelf.name,
                    audience=Audience(shelf.visibility),
                    books=tuple((title, tuple(authors or ())) for title, authors in books),
                )
            )
        return found

    async def reviews_by_item(self, user_id: UUID) -> dict[UUID, Review]:
        rows = await self._session.scalars(select(ReviewRow).where(ReviewRow.user_id == user_id))
        return {row.item_id: _review(row) for row in rows}

    async def note_counts(self, user_id: UUID) -> dict[str, int]:
        """Number of highlights and notes per file."""
        rows = await self._session.execute(
            select(AnnotationRow.file_sha256, func.count())
            .where(AnnotationRow.user_id == user_id)
            .group_by(AnnotationRow.file_sha256)
        )
        return {sha: int(count) for sha, count in rows.all()}

    async def work_ids(self, edition_ids: Sequence[UUID]) -> dict[UUID, UUID]:
        if not edition_ids:
            return {}
        rows = await self._session.execute(
            select(EditionRow.id, EditionRow.work_id).where(EditionRow.id.in_(edition_ids))
        )
        return {edition: work for edition, work in rows.all()}

    async def library(self, user_id: UUID, limit: int) -> list[tuple[str, tuple[str, ...]]]:
        rows = await self._session.execute(
            select(LibraryItemRow.title, LibraryItemRow.authors)
            .where(LibraryItemRow.user_id == user_id, _SHOWN)
            .order_by(LibraryItemRow.added_at.desc())
            .limit(limit)
        )
        return [(title, tuple(authors or ())) for title, authors in rows]

    async def library_count(self, user_id: UUID) -> int:
        count = await self._session.scalar(
            select(func.count())
            .select_from(LibraryItemRow)
            .where(LibraryItemRow.user_id == user_id, _SHOWN)
        )
        return int(count or 0)

    async def notes(
        self, user_ids: Sequence[UUID], audiences: Sequence[Audience], limit: int
    ) -> list[SharedNote]:
        if not user_ids:
            return []
        rows = await self._session.execute(
            select(AnnotationRow, LibraryItemRow.title)
            .outerjoin(LibraryItemRow, LibraryItemRow.id == AnnotationRow.item_id)
            .where(
                AnnotationRow.user_id.in_(user_ids),
                AnnotationRow.visibility.in_([a.value for a in audiences]),
            )
            .order_by(AnnotationRow.client_time.desc())
            .limit(limit)
        )
        return [
            SharedNote(
                id=row.id,
                user_id=row.user_id,
                title=title or "",
                quote=row.quote,
                note=row.note,
                audience=Audience(row.visibility),
                at=_aware(row.client_time),
                page=row.chapter if row.region else None,
                region=row.region,
            )
            for row, title in rows
        ]

    # ------------------------------------------------------------ a work, all editions
    def _seen_by(self, column: Any, owner: Any, viewer: UUID, friends: Sequence[UUID]) -> Any:
        """Content the viewer may read: their own, public, or friends-only from a friend."""
        return or_(
            owner == viewer,
            column == Audience.PUBLIC.value,
            and_(column == Audience.FRIENDS.value, owner.in_(list(friends))),
        )

    async def work_reviews(
        self,
        work_id: UUID,
        viewer: UUID,
        friends: Sequence[UUID],
        hidden: Sequence[UUID],
        limit: int,
    ) -> list[Review]:
        """Reviews of any edition or file of a work, as the viewer may see them."""
        rows = await self._session.scalars(
            select(ReviewRow)
            .join(LibraryItemRow, LibraryItemRow.id == ReviewRow.item_id)
            .where(
                LibraryItemRow.work_id == work_id,
                ReviewRow.user_id.not_in(list(hidden)),
                self._seen_by(ReviewRow.audience, ReviewRow.user_id, viewer, friends),
            )
            .order_by(ReviewRow.updated_at.desc())
            .limit(limit)
        )
        return [_review(row) for row in rows]

    async def work_notes(
        self,
        work_id: UUID,
        viewer: UUID,
        friends: Sequence[UUID],
        hidden: Sequence[UUID],
        limit: int,
    ) -> list[SharedNote]:
        """Highlights and notes on any edition or file of a work, as the viewer may see them."""
        rows = await self._session.execute(
            select(AnnotationRow, LibraryItemRow.title)
            .join(LibraryItemRow, LibraryItemRow.id == AnnotationRow.item_id)
            .where(
                LibraryItemRow.work_id == work_id,
                AnnotationRow.user_id.not_in(list(hidden)),
                self._seen_by(AnnotationRow.visibility, AnnotationRow.user_id, viewer, friends),
            )
            .order_by(AnnotationRow.client_time.desc())
            .limit(limit)
        )
        return [
            SharedNote(
                id=row.id,
                user_id=row.user_id,
                title=title or "",
                quote=row.quote,
                note=row.note,
                audience=Audience(row.visibility),
                at=_aware(row.client_time),
                page=row.chapter if row.region else None,
                region=row.region,
            )
            for row, title in rows
        ]

    # ------------------------------------------------------------ blocks and reports
    async def block(self, blocker: UUID, blocked: UUID) -> None:
        await self.remove_friendship(blocker, blocked)
        await self.unfollow(blocker, blocked)
        await self.unfollow(blocked, blocker)
        if await self._session.get(BlockRow, (blocker, blocked)) is None:
            self._session.add(BlockRow(blocker_id=blocker, blocked_id=blocked))
        await self._session.flush()

    async def unblock(self, blocker: UUID, blocked: UUID) -> None:
        await self._session.execute(
            delete(BlockRow).where(BlockRow.blocker_id == blocker, BlockRow.blocked_id == blocked)
        )

    async def blocked(self, blocker: UUID) -> list[UUID]:
        return list(
            await self._session.scalars(
                select(BlockRow.blocked_id)
                .where(BlockRow.blocker_id == blocker)
                .order_by(BlockRow.created_at.desc())
            )
        )

    async def hidden(self, user_id: UUID) -> set[UUID]:
        """Readers this one blocked, or who blocked this one: invisible to each other."""
        rows = await self._session.execute(
            select(BlockRow.blocker_id, BlockRow.blocked_id).where(
                or_(BlockRow.blocker_id == user_id, BlockRow.blocked_id == user_id)
            )
        )
        return {b if a == user_id else a for a, b in rows}

    async def add_report(self, report: Report) -> None:
        self._session.add(
            ReportRow(
                id=report.id,
                reporter_id=report.reporter_id,
                reported_id=report.reported_id,
                reason=report.reason.value,
                note=report.note,
                created_at=report.created_at,
            )
        )
        await self._session.flush()

    async def reports(self, limit: int) -> list[Report]:
        rows = await self._session.scalars(
            select(ReportRow)
            .order_by(ReportRow.resolved_at.is_not(None), ReportRow.created_at.desc())
            .limit(limit)
        )
        return [
            Report(
                id=row.id,
                reporter_id=row.reporter_id,
                reported_id=row.reported_id,
                reason=ReportReason(row.reason),
                note=row.note,
                created_at=_aware(row.created_at),
                resolved_at=_aware(row.resolved_at) if row.resolved_at else None,
            )
            for row in rows
        ]

    async def resolve_report(self, report_id: UUID, at: datetime) -> bool:
        row = await self._session.get(ReportRow, report_id)
        if row is None:
            return False
        row.resolved_at = at
        await self._session.flush()
        return True

    async def admins(self) -> list[UUID]:
        return list(await self._session.scalars(select(UserRow.id).where(UserRow.is_admin)))

    async def commit(self) -> None:
        await self._session.commit()
