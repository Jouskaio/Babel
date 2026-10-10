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
