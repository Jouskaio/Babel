import '../../l10n.dart';

/// "Good morning" from 5:00 to 17:59 local time, "Good evening" otherwise.
String greeting(AppLocalizations l10n, String name, DateTime now) =>
    now.hour >= 5 && now.hour < 18
        ? l10n.greetingMorning(name)
        : l10n.greetingEvening(name);
