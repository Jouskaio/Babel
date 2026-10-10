from babel_api.domain.progression import Activity, compute, level_of


def test_levels_start_at_50_n_n_minus_1() -> None:
    assert [level_of(x) for x in (0, 99, 100, 299, 300, 599, 600, 1000, 5000)] == [
        1,
        1,
        2,
        2,
        3,
        3,
        4,
        5,
        10,
    ]


def test_points_badges_and_first_steps() -> None:
    nothing = compute(Activity())
    assert (nothing.xp, nothing.level, nothing.title) == (0, 1, "novice")
    assert not any(step.done for step in nothing.steps)
    assert all(b.tier == 0 for b in nothing.badges)

    busy = compute(
        Activity(
            finished=6, library=10, notes=12, reviews=2, reading_days=8, longest_streak=4, sources=1
        )
    )
    # 6 books, 10 added, 12 notes, 2 reviews, 8 days of reading.
    assert busy.xp == 6 * 100 + 10 * 10 + 12 * 5 + 2 * 20 + 8 * 10
    by_key = {b.key: b for b in busy.badges}
    assert (by_key["finished"].tier, by_key["finished"].next_target) == (2, 10)
    assert (by_key["streak"].tier, by_key["streak"].next_target) == (1, 7)
    assert all(step.done for step in busy.steps)
    assert busy.level_start <= busy.xp < busy.next_level


def test_the_challenge_of_the_month_counts_books_of_its_theme() -> None:
    from datetime import UTC, datetime

    from babel_api.domain.challenges import books_in, months_won
    from babel_api.domain.genres import Genre

    def at(month: int, day: int = 5) -> datetime:
        return datetime(2026, month, day, tzinfo=UTC)

    finished = [
        (at(10, 1), (Genre.HORROR,)),
        (at(10, 9), (Genre.HORROR, Genre.MYSTERY)),
        (at(10, 20), (Genre.ROMANCE,)),  # not the theme of October
        (at(9, 3), (Genre.HORROR,)),  # September's theme is the stage
        (at(11, 2), (Genre.NONFICTION,)),
    ]
    assert books_in(finished, 2026, 10) == 2
    assert books_in(finished, 2026, 9) == 0
    assert months_won(finished) == 0
    finished.append((at(10, 28), (Genre.HORROR,)))
    assert months_won(finished) == 1

    done = compute(Activity(challenge_books=4, challenge_month=10, challenges_won=1))
    assert (done.challenge.theme, done.challenge.progress, done.challenge.done) == (
        "gothic",
        3,
        True,
    )
    assert done.xp == 50  # the won month's bonus
