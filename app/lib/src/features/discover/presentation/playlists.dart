import 'package:flutter/material.dart';

import '../../../l10n.dart';

/// The playlists there are, in the order they are shown.
const playlistKeys = [
  'dark_academia',
  'gothic',
  'tragic_romance',
  'bottle',
  'classics',
  'enemies',
  'dystopia',
  'mystery',
  'horror',
  'historical',
  'coming_of_age',
  'fantasy',
  'space',
  'sea',
  'war',
  'magic',
  'travel',
  'friendship',
];

String playlistName(AppLocalizations l10n, String key) => switch (key) {
  'dark_academia' => l10n.moodDarkAcademia,
  'gothic' => l10n.moodGothic,
  'tragic_romance' => l10n.moodTragicRomance,
  'bottle' => l10n.moodBottle,
  'classics' => l10n.moodClassics,
  'enemies' => l10n.moodEnemies,
  'dystopia' => l10n.playlistDystopia,
  'mystery' => l10n.playlistMystery,
  'horror' => l10n.playlistHorror,
  'historical' => l10n.playlistHistorical,
  'coming_of_age' => l10n.playlistComingOfAge,
  'space' => l10n.playlistSpace,
  'sea' => l10n.playlistSea,
  'war' => l10n.playlistWar,
  'magic' => l10n.playlistMagic,
  'travel' => l10n.playlistTravel,
  'friendship' => l10n.playlistFriendship,
  _ => l10n.moodFantasy,
};

IconData playlistIcon(String key) => switch (key) {
  'dark_academia' => Icons.history_edu_rounded,
  'gothic' => Icons.castle_outlined,
  'tragic_romance' => Icons.heart_broken_outlined,
  'bottle' => Icons.lock_outline_rounded,
  'classics' => Icons.account_balance_outlined,
  'enemies' => Icons.local_fire_department_outlined,
  'dystopia' => Icons.public_off_outlined,
  'mystery' => Icons.search_rounded,
  'horror' => Icons.dark_mode_outlined,
  'historical' => Icons.hourglass_empty_rounded,
  'coming_of_age' => Icons.park_outlined,
  'space' => Icons.rocket_launch_outlined,
  'sea' => Icons.sailing_outlined,
  'war' => Icons.shield_outlined,
  'magic' => Icons.auto_awesome_outlined,
  'travel' => Icons.explore_outlined,
  'friendship' => Icons.diversity_1_outlined,
  _ => Icons.auto_fix_high_rounded,
};
