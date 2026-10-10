"""Playlists of books: a theme, and the Open Library subject whose popular works fill it.

The names are the app's (localized there); here are only the keys and where the books come from.
"""

from babel_api.domain.genres import Genre

# key -> Open Library subject (https://openlibrary.org/subjects/<slug>)
PLAYLISTS: dict[str, str] = {
    "dark_academia": "dark_academia",
    "gothic": "gothic_fiction",
    "tragic_romance": "love_stories",
    "bottle": "psychological_fiction",
    "classics": "classic_literature",
    "enemies": "enemies_to_lovers",
    "dystopia": "dystopian_fiction",
    "mystery": "mystery_and_detective_stories",
    "horror": "horror_fiction",
    "historical": "historical_fiction",
    "coming_of_age": "coming_of_age",
    "fantasy": "fantasy_fiction",
}

# What to suggest to a reader who finished many books of a genre.
GENRE_PLAYLISTS: dict[Genre, str] = {
    Genre.SCIENCE_FICTION: "dystopia",
    Genre.FANTASY: "fantasy",
    Genre.HORROR: "gothic",
    Genre.MYSTERY: "mystery",
    Genre.ROMANCE: "tragic_romance",
    Genre.HISTORICAL: "historical",
    Genre.YOUNG: "coming_of_age",
    Genre.LITERARY: "classics",
    Genre.PHILOSOPHY: "bottle",
}
