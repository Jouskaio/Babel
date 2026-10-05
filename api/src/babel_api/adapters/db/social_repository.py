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
    FriendshipRow,
    LibraryItemRow,
    ReadingPositionRow,
    RecommendationRow,
    ReviewRow,
    SocialProfileRow,
    SubscriptionRow,
    UserRow,
)
from babel_api.domain.errors import HandleTakenError
from babel_api.domain.social import (
    Audience,
    Profile,
    Reading,
    Recommendation,
    Review,
    SharedNote,
)


def _aware(value: datetime) -> datetime:
    return value if value.tzinfo else value.replace(tzinfo=UTC)


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
            )
            .order_by(ReadingPositionRow.client_time.desc())
            .limit(limit)
        )
        seen: set[UUID] = set()
        found: list[Reading] = []
        for position, item in rows:
            if item.id in seen:
                continue
            seen.add(item.id)
            found.append(
                Reading(
                    user_id=item.user_id,
                    item_id=item.id,
                    title=item.title,
                    authors=tuple(item.authors or ()),
                    percent=position.percent,
                    at=_aware(position.client_time),
                )
            )
        return found

    async def library(self, user_id: UUID, limit: int) -> list[tuple[str, tuple[str, ...]]]:
        rows = await self._session.execute(
            select(LibraryItemRow.title, LibraryItemRow.authors)
            .where(LibraryItemRow.user_id == user_id)
            .order_by(LibraryItemRow.added_at.desc())
            .limit(limit)
        )
        return [(title, tuple(authors or ())) for title, authors in rows]

    async def library_count(self, user_id: UUID) -> int:
        count = await self._session.scalar(
            select(func.count())
            .select_from(LibraryItemRow)
            .where(LibraryItemRow.user_id == user_id)
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

    async def commit(self) -> None:
        await self._session.commit()
