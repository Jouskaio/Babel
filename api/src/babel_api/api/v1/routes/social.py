"""Readers together: public profile, search by handle, friends, follows, feed, reviews and
recommendations."""

from datetime import datetime
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Query, Response, status
from pydantic import BaseModel, Field

from babel_api.api.dependencies import CurrentAdminId, CurrentUserId, SocialServiceDep
from babel_api.api.v1.routes.library import LibraryItemResponse
from babel_api.domain.social import (
    Audience,
    FeedEntry,
    FeedKind,
    FriendStatus,
    Profile,
    Recommendation,
    ReportReason,
    Review,
)
from babel_api.services.social import Reader

router = APIRouter(tags=["social"])

Handle = Annotated[str, Field(min_length=1, max_length=40)]


class SocialProfileResponse(BaseModel):
    """The signed-in reader's public side."""

    handle: str | None = Field(description="Unique, how other readers find you")
    display_name: str
    share_reading: Audience = Field(description="Who sees what you are reading")
    share_library: Audience = Field(description="Who sees the titles of your library")

    @classmethod
    def of(cls, profile: Profile) -> "SocialProfileResponse":
        return cls(
            handle=profile.handle,
            display_name=profile.display_name,
            share_reading=profile.share_reading,
            share_library=profile.share_library,
        )


class UpdateSocialProfileRequest(BaseModel):
    handle: Handle | None = None
    share_reading: Audience | None = None
    share_library: Audience | None = None


class RelationResponse(BaseModel):
    friend: FriendStatus
    following: bool
    follows_you: bool


class ReaderResponse(BaseModel):
    handle: str | None
    display_name: str
    relation: RelationResponse

    @classmethod
    def of(cls, reader: Reader) -> "ReaderResponse":
        return cls(
            handle=reader.profile.handle,
            display_name=reader.profile.display_name,
            relation=RelationResponse(
                friend=reader.relation.friend,
                following=reader.relation.following,
                follows_you=reader.relation.follows_you,
            ),
        )


class AuthorResponse(BaseModel):
    """Who wrote a feed entry or sent a recommendation."""

    handle: str | None
    display_name: str


class ReadingResponse(BaseModel):
    title: str
    authors: list[str]
    percent: float
    at: datetime


class BookTitleResponse(BaseModel):
    title: str
    authors: list[str]


class ShelfResponse(BaseModel):
    name: str
    audience: Audience
    books: list[BookTitleResponse]


class ReviewResponse(BaseModel):
    item_id: UUID
    title: str
    authors: list[str]
    rating: int | None
    text: str | None
    audience: Audience
    updated_at: datetime

    @classmethod
    def of(cls, review: Review) -> "ReviewResponse":
        return cls(
            item_id=review.item_id,
            title=review.title,
            authors=list(review.authors),
            rating=review.rating,
            text=review.text,
            audience=review.audience,
            updated_at=review.updated_at,
        )


class SharedNoteResponse(BaseModel):
    title: str
    quote: str = Field(description="Empty for a note on a comic page")
    note: str | None
    at: datetime
    page: int | None = Field(description="Comic page notes: the page, from 0")
    region: str | None = Field(description="Comic page notes: x,y,w,h in fractions of the page")


class ReaderPageResponse(BaseModel):
    reader: ReaderResponse
    friends: int
    followers: int
    books: int | None = Field(description="Null when the library is not shared with you")
    reading: list[ReadingResponse]
    library: list[BookTitleResponse] | None
    reviews: list[ReviewResponse]
    notes: list[SharedNoteResponse]
    finished: list[ReadingResponse] = Field(description="Books finished lately")
    shelves: list[ShelfResponse]


class BookTraceResponse(BaseModel):
    """A book the reader has or once had, and what they left on it."""

    item: LibraryItemResponse
    removed_at: datetime | None = Field(description="Taken out of the library (data kept)")
    work_id: UUID | None = Field(description="The catalog work, to show it on the work's page")
    review: ReviewResponse | None
    notes: int = Field(description="Highlights and notes kept for this book")
    available: bool = Field(description="False when the file is gone: only the data remains")


class FriendsResponse(BaseModel):
    friends: list[ReaderResponse]
    incoming: list[ReaderResponse] = Field(description="Requests waiting for your answer")
    outgoing: list[ReaderResponse] = Field(description="Requests you sent")
    following: list[ReaderResponse]


class FeedEntryResponse(BaseModel):
    kind: FeedKind
    reader: AuthorResponse
    at: datetime
    title: str
    authors: list[str]
    percent: float | None
    rating: int | None
    text: str | None
    quote: str | None


class ReviewRequest(BaseModel):
    rating: Annotated[int, Field(ge=1, le=5)] | None = None
    text: Annotated[str, Field(max_length=5000)] | None = None
    audience: Audience = Audience.PUBLIC


class RecommendRequest(BaseModel):
    to: Handle
    item_id: UUID | None = Field(default=None, description="A book of your library")
    title: Annotated[str, Field(max_length=500)] | None = None
    authors: Annotated[list[str], Field(max_length=5)] = []
    url: Annotated[str, Field(max_length=2000)] | None = None
    message: Annotated[str, Field(max_length=1000)] | None = None


class RecommendationResponse(BaseModel):
    id: UUID
    sender: AuthorResponse
    title: str
    authors: list[str]
    url: str | None
    message: str | None
    created_at: datetime
    read: bool
    work_id: UUID | None = Field(default=None, description="The catalog work, for its page")
    cover_path: str | None = None


def _author(profile: Profile | None) -> AuthorResponse:
    return AuthorResponse(
        handle=profile.handle if profile else None,
        display_name=profile.display_name if profile else "",
    )


# ---------------------------------------------------------------- own profile
@router.get("/me/profile", operation_id="getSocialProfile", tags=["account"])
async def get_profile(user_id: CurrentUserId, social: SocialServiceDep) -> SocialProfileResponse:
    """Your handle and what you share."""
    return SocialProfileResponse.of(await social.profile(user_id))


@router.patch("/me/profile", operation_id="updateSocialProfile", tags=["account"])
async def update_profile(
    user_id: CurrentUserId, social: SocialServiceDep, body: UpdateSocialProfileRequest
) -> SocialProfileResponse:
    """Choose a handle (3 to 30 letters, digits, dots, underscores) and what you share."""
    return SocialProfileResponse.of(
        await social.update_profile(
            user_id,
            handle=body.handle,
            share_reading=body.share_reading,
            share_library=body.share_library,
        )
    )


# ---------------------------------------------------------------- readers
@router.get("/social/readers", operation_id="searchReaders")
async def search_readers(
    user_id: CurrentUserId,
    social: SocialServiceDep,
    q: Annotated[str, Query(min_length=2, max_length=40)],
) -> list[ReaderResponse]:
    """Readers whose handle starts with ``q``."""
    return [ReaderResponse.of(r) for r in await social.search(user_id, q)]


@router.get("/social/readers/{handle}", operation_id="getReader")
async def get_reader(
    user_id: CurrentUserId, social: SocialServiceDep, handle: str
) -> ReaderPageResponse:
    """A reader's page: only what they share with you."""
    page = await social.reader_page(user_id, handle)
    return ReaderPageResponse(
        reader=ReaderResponse.of(page.reader),
        friends=page.friends,
        followers=page.followers,
        books=page.books,
        reading=[
            ReadingResponse(title=r.title, authors=list(r.authors), percent=r.percent, at=r.at)
            for r in page.reading
        ],
        library=None
        if page.library is None
        else [BookTitleResponse(title=t, authors=list(a)) for t, a in page.library],
        reviews=[ReviewResponse.of(r) for r in page.reviews],
        notes=[
            SharedNoteResponse(
                title=n.title, quote=n.quote, note=n.note, at=n.at, page=n.page, region=n.region
            )
            for n in page.notes
        ],
        finished=[
            ReadingResponse(title=r.title, authors=list(r.authors), percent=r.percent, at=r.at)
            for r in page.finished
        ],
        shelves=[
            ShelfResponse(
                name=s.name,
                audience=s.audience,
                books=[BookTitleResponse(title=t, authors=list(a)) for t, a in s.books],
            )
            for s in page.shelves
        ],
    )


# ---------------------------------------------------------------- friends and follows
@router.get("/social/friends", operation_id="getFriends")
async def get_friends(user_id: CurrentUserId, social: SocialServiceDep) -> FriendsResponse:
    friends = await social.friends(user_id)
    return FriendsResponse(
        friends=[ReaderResponse.of(r) for r in friends.friends],
        incoming=[ReaderResponse.of(r) for r in friends.incoming],
        outgoing=[ReaderResponse.of(r) for r in friends.outgoing],
        following=[ReaderResponse.of(r) for r in friends.following],
    )


@router.put("/social/friends/{handle}", operation_id="addFriend")
async def add_friend(
    user_id: CurrentUserId, social: SocialServiceDep, handle: str
) -> ReaderResponse:
    """Send a friend request, or accept the one this reader sent you."""
    return ReaderResponse.of(await social.add_friend(user_id, handle))


@router.delete("/social/friends/{handle}", operation_id="removeFriend")
async def remove_friend(
    user_id: CurrentUserId, social: SocialServiceDep, handle: str
) -> ReaderResponse:
    """Cancel or decline a request, or end a friendship."""
    return ReaderResponse.of(await social.remove_friend(user_id, handle))


@router.put("/social/following/{handle}", operation_id="followReader")
async def follow_reader(
    user_id: CurrentUserId, social: SocialServiceDep, handle: str
) -> ReaderResponse:
    """Follow a reader's public activity (no request needed)."""
    return ReaderResponse.of(await social.follow(user_id, handle))


@router.delete("/social/following/{handle}", operation_id="unfollowReader")
async def unfollow_reader(
    user_id: CurrentUserId, social: SocialServiceDep, handle: str
) -> ReaderResponse:
    return ReaderResponse.of(await social.unfollow(user_id, handle))


@router.get("/social/feed", operation_id="getFeed")
async def get_feed(user_id: CurrentUserId, social: SocialServiceDep) -> list[FeedEntryResponse]:
    """What friends and followed readers shared lately, newest first."""
    entries, profiles = await social.feed(user_id)

    def of(entry: FeedEntry) -> FeedEntryResponse:
        return FeedEntryResponse(
            kind=entry.kind,
            reader=_author(profiles.get(entry.user_id)),
            at=entry.at,
            title=entry.title,
            authors=list(entry.authors),
            percent=entry.percent,
            rating=entry.rating,
            text=entry.text,
            quote=entry.quote,
        )

    return [of(e) for e in entries]


# ---------------------------------------------------------------- reviews
@router.get(
    "/library/{item_id}/review",
    operation_id="getReview",
    tags=["library"],
    responses={204: {"description": "No review yet"}},
    response_model=ReviewResponse,
)
async def get_review(
    user_id: CurrentUserId, social: SocialServiceDep, item_id: UUID
) -> ReviewResponse | Response:
    """Your review of this book, if any."""
    review = await social.review(user_id, item_id)
    if review is None:
        return Response(status_code=status.HTTP_204_NO_CONTENT)
    return ReviewResponse.of(review)


@router.put("/library/{item_id}/review", operation_id="saveReview", tags=["library"])
async def save_review(
    user_id: CurrentUserId, social: SocialServiceDep, item_id: UUID, body: ReviewRequest
) -> ReviewResponse:
    """Rate and review a book of your library, and choose who sees it."""
    return ReviewResponse.of(
        await social.save_review(
            user_id, item_id, rating=body.rating, text=body.text, audience=body.audience
        )
    )


@router.delete(
    "/library/{item_id}/review",
    operation_id="deleteReview",
    tags=["library"],
    status_code=status.HTTP_204_NO_CONTENT,
)
async def delete_review(user_id: CurrentUserId, social: SocialServiceDep, item_id: UUID) -> None:
    await social.delete_review(user_id, item_id)


# ---------------------------------------------------------------- recommendations
def _recommendation(r: Recommendation, sender: Profile | None) -> RecommendationResponse:
    return RecommendationResponse(
        id=r.id,
        sender=_author(sender),
        title=r.title,
        authors=list(r.authors),
        url=r.url,
        message=r.message,
        created_at=r.created_at,
        read=r.read_at is not None,
        work_id=r.work_id,
        cover_path=f"/v1/catalog/covers/{r.cover_id}/M" if r.cover_id else None,
    )


@router.post(
    "/social/recommendations",
    operation_id="recommend",
    status_code=status.HTTP_201_CREATED,
)
async def recommend(
    user_id: CurrentUserId, social: SocialServiceDep, body: RecommendRequest
) -> RecommendationResponse:
    """Recommend a book of your library, or a title or link, to a friend."""
    sent = await social.recommend(
        user_id,
        body.to,
        item_id=body.item_id,
        title=body.title,
        authors=tuple(body.authors),
        url=body.url,
        message=body.message,
    )
    return _recommendation(sent, await social.profile(user_id))


@router.get("/social/recommendations", operation_id="getRecommendations")
async def get_recommendations(
    user_id: CurrentUserId, social: SocialServiceDep
) -> list[RecommendationResponse]:
    """Books your friends recommended to you, newest first."""
    found, senders = await social.recommendations(user_id)
    return [_recommendation(r, senders.get(r.sender_id)) for r in found]


@router.post(
    "/social/recommendations/{recommendation_id}/read",
    operation_id="markRecommendationRead",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def mark_read(
    user_id: CurrentUserId, social: SocialServiceDep, recommendation_id: UUID
) -> None:
    await social.mark_read(user_id, recommendation_id)


# ---------------------------------------------------------------- blocks and reports
class ReportRequest(BaseModel):
    handle: Handle
    reason: ReportReason
    note: Annotated[str, Field(max_length=1000)] | None = None


class ReportResponse(BaseModel):
    id: UUID
    reporter: AuthorResponse
    reported: AuthorResponse
    reason: ReportReason
    note: str | None
    created_at: datetime
    resolved: bool


@router.put(
    "/social/blocks/{handle}", operation_id="blockReader", status_code=status.HTTP_204_NO_CONTENT
)
async def block_reader(user_id: CurrentUserId, social: SocialServiceDep, handle: str) -> None:
    """Block a reader: friendship and follows end both ways; neither sees the other."""
    await social.block(user_id, handle)


@router.delete(
    "/social/blocks/{handle}",
    operation_id="unblockReader",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def unblock_reader(user_id: CurrentUserId, social: SocialServiceDep, handle: str) -> None:
    await social.unblock(user_id, handle)


@router.get("/social/blocks", operation_id="getBlocked")
async def get_blocked(user_id: CurrentUserId, social: SocialServiceDep) -> list[AuthorResponse]:
    """Readers you blocked."""
    return [_author(p) for p in await social.blocked(user_id)]


@router.post("/social/reports", operation_id="reportReader", status_code=status.HTTP_204_NO_CONTENT)
async def report_reader(
    user_id: CurrentUserId, social: SocialServiceDep, body: ReportRequest
) -> None:
    """Report a reader to the administrators (the reader is not told)."""
    await social.report(user_id, body.handle, body.reason, body.note)


@router.get("/admin/reports", operation_id="listReports", tags=["admin"])
async def list_reports(_: CurrentAdminId, social: SocialServiceDep) -> list[ReportResponse]:
    """Reports, unresolved first."""
    found, profiles = await social.reports()
    return [
        ReportResponse(
            id=r.id,
            reporter=_author(profiles.get(r.reporter_id)),
            reported=_author(profiles.get(r.reported_id)),
            reason=r.reason,
            note=r.note,
            created_at=r.created_at,
            resolved=r.resolved_at is not None,
        )
        for r in found
    ]


@router.post(
    "/admin/reports/{report_id}/resolve",
    operation_id="resolveReport",
    status_code=status.HTTP_204_NO_CONTENT,
    tags=["admin"],
)
async def resolve_report(_: CurrentAdminId, social: SocialServiceDep, report_id: UUID) -> None:
    await social.resolve_report(report_id)


# ---------------------------------------------------------------- a work
class WorkReviewResponse(BaseModel):
    reader: AuthorResponse
    rating: int | None
    text: str | None
    audience: Audience
    updated_at: datetime
    mine: bool


class WorkNoteResponse(BaseModel):
    reader: AuthorResponse
    quote: str
    note: str | None
    page: int | None
    audience: Audience
    at: datetime
    mine: bool


class WorkReadersResponse(BaseModel):
    """Every reader's reviews and notes on a work, whatever edition or file they read."""

    rating: float | None = Field(description="Average of the ratings shown")
    ratings: int
    reviews: list[WorkReviewResponse]
    notes: list[WorkNoteResponse]


@router.get("/catalog/works/{work_id}/readers", operation_id="getWorkReaders")
async def get_work_readers(
    user_id: CurrentUserId, social: SocialServiceDep, work_id: UUID
) -> WorkReadersResponse:
    """Reviews and notes on all editions of a work that you may see."""
    found = await social.work_readers(user_id, work_id)
    rating, ratings = found.rating
    return WorkReadersResponse(
        rating=round(rating, 2) if rating is not None else None,
        ratings=ratings,
        reviews=[
            WorkReviewResponse(
                reader=_author(found.profiles.get(r.user_id)),
                rating=r.rating,
                text=r.text,
                audience=r.audience,
                updated_at=r.updated_at,
                mine=r.user_id == user_id,
            )
            for r in found.reviews
        ],
        notes=[
            WorkNoteResponse(
                reader=_author(found.profiles.get(n.user_id)),
                quote=n.quote,
                note=n.note,
                page=n.page,
                audience=n.audience,
                at=n.at,
                mine=n.user_id == user_id,
            )
            for n in found.notes
        ],
    )


# ---------------------------------------------------------------- history
# Listed with the library in the contract (it is mostly library data).
history_router = APIRouter(tags=["library"])


class BookNoteResponse(BaseModel):
    """Another reader's note, with what places it in another edition."""

    id: UUID
    reader: AuthorResponse
    quote: str
    note: str | None
    chapter: int = Field(description="Chapter (or page) in the edition it was written in")
    region: str | None
    percent: float | None = Field(description="Where it is in its book, in percent")
    prefix: str | None = Field(description="Words just before the quote")
    suffix: str | None = Field(description="Words just after the quote")
    same_file: bool = Field(description="Written in this very file: chapter and quote match")
    language: str | None = Field(description="Language of the edition it was written in")
    at: datetime


@history_router.get("/library/{item_id}/reader-notes", operation_id="getReaderNotes")
async def get_reader_notes(
    user_id: CurrentUserId, social: SocialServiceDep, item_id: UUID
) -> list[BookNoteResponse]:
    """Other readers' notes you may see on this book, from any edition of its work."""
    notes, profiles = await social.book_notes(user_id, item_id)
    return [
        BookNoteResponse(
            id=n.id,
            reader=_author(profiles.get(n.user_id)),
            quote=n.quote,
            note=n.note,
            chapter=n.chapter,
            region=n.region,
            percent=n.percent,
            prefix=n.prefix,
            suffix=n.suffix,
            same_file=n.same_file,
            language=n.language,
            at=n.at,
        )
        for n in notes
    ]


@history_router.get("/library/history", operation_id="getLibraryHistory")
async def get_history(user_id: CurrentUserId, social: SocialServiceDep) -> list[BookTraceResponse]:
    """Every book the reader has or once had, removed ones included, latest first.

    Removing a book or losing its file never erases the reader's status, review, notes
    and positions; adding the same file again brings the book back with them.
    """
    return [
        BookTraceResponse(
            item=LibraryItemResponse.of(t.item),
            removed_at=t.item.removed_at,
            work_id=t.work_id,
            review=ReviewResponse.of(t.review) if t.review else None,
            notes=t.notes,
            available=t.available,
        )
        for t in await social.history(user_id)
    ]
