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
    # the subject challenges
    "space": "outer_space",
    "sea": "sea",
    "war": "war",
    "magic": "magic",
    "travel": "travel",
    "friendship": "friendship",
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


# playlist key -> Goodreads shelf (https://www.goodreads.com/shelf/show/<slug>): what readers
# shelve most under that name, which ranks the playlist better than a catalog subject does.
GOODREADS_SHELVES: dict[str, str] = {
    "dark_academia": "dark-academia",
    "gothic": "gothic",
    "tragic_romance": "tragic-romance",
    "bottle": "psychological-thriller",
    "classics": "classics",
    "enemies": "enemies-to-lovers",
    "dystopia": "dystopian",
    "mystery": "mystery",
    "horror": "horror",
    "historical": "historical-fiction",
    "coming_of_age": "coming-of-age",
    "fantasy": "fantasy",
    "space": "space",
    "sea": "sea",
    "war": "war",
    "magic": "magic",
    "travel": "travel",
    "friendship": "friendship",
}
