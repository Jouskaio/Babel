// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get brand => 'BABEL';

  @override
  String get navFeatures => 'Features';

  @override
  String get navDevices => 'Devices';

  @override
  String get navPrivacy => 'Privacy';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create an account';

  @override
  String get heroEyebrow => 'Library · Reading · Notes';

  @override
  String get heroTitleLead => 'Your whole library, ';

  @override
  String get heroTitleEmphasis => 'in one place.';

  @override
  String get heroLede =>
      'Paper or digital books, comics, audiobooks and fanfiction: organise your whole library, track your reading and share it with your friends. Import your own files to read them wherever you are.';

  @override
  String get startFree => 'Get started — it’s free';

  @override
  String get haveAccount => 'I already have an account';

  @override
  String get heroNote => 'No ads. Your data stays yours.';

  @override
  String get trendingLabel => 'Trending this week';

  @override
  String get featuresEyebrow => 'Features';

  @override
  String get featuresTitle =>
      'A library that feels like yours, not a catalogue.';

  @override
  String get featureAllTitle => 'Everything in one place';

  @override
  String get featureAllBody =>
      'Scan your paper books, import your files, download your fanfiction from AO3 and find what you are reading, want to read and have finished.';

  @override
  String get featureSyncTitle => 'Your sources, everywhere';

  @override
  String get featureSyncBody =>
      'Import your EPUBs or connect your own sources — GitHub, OPDS catalogs, Nextcloud — and pick up at the right page on your e-reader, phone or computer.';

  @override
  String get featureNotesTitle => 'Notes in the margin';

  @override
  String get featureNotesBody =>
      'Highlight, comment, and find your favourite passages and your friends’.';

  @override
  String get featureStatsTitle => 'Your reading, in numbers';

  @override
  String get featureStatsBody =>
      'Statistics, goals and a year in review you will want to share.';

  @override
  String get devicesEyebrow => 'Devices';

  @override
  String get devicesTitle => 'Read wherever you like. Babel follows.';

  @override
  String get devicesBody =>
      'Your progress, notes and shelves sync across your devices. Start a chapter in bed on your e-reader, finish it on the train.';

  @override
  String get deviceChapter => 'Chapter XII';

  @override
  String get deviceExcerpt =>
      'Margarita opened the window. Above the roofs, the moon lit the street with a clean white light, as if someone had stretched a sheet over the whole city…';

  @override
  String get deviceSynced => 'Synced';

  @override
  String get quote =>
      '“Whatever our souls are made of, his and mine are the same.”';

  @override
  String get quoteAuthor => 'Emily Brontë · Wuthering Heights';

  @override
  String get ctaTitle => 'Open your library.';

  @override
  String get ctaBody => 'Create your account in a minute.';

  @override
  String get footerPrivacy => 'Privacy';

  @override
  String get footerTerms => 'Terms';

  @override
  String get footerContact => 'Contact';

  @override
  String get authQuote => '“A reader lives a thousand lives before he dies.”';

  @override
  String get authQuoteAuthor => 'George R. R. Martin';

  @override
  String get loginEyebrow => 'Sign in';

  @override
  String get loginTitle => 'Welcome back.';

  @override
  String get loginLede => 'Pick up your reading where you left off.';

  @override
  String get signupEyebrow => 'Sign up';

  @override
  String get signupTitle => 'Open your library.';

  @override
  String get signupLede =>
      'One account to find your books, notes and friends on all your devices.';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get or => 'or';

  @override
  String get displayNameLabel => 'Display name';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get showPassword => 'Show';

  @override
  String get hidePassword => 'Hide';

  @override
  String get passwordHelp => 'At least 10 characters. A passphrase is ideal.';

  @override
  String get termsNotice =>
      'By creating an account, you accept the Terms of use and the Privacy policy.';

  @override
  String get createMyAccount => 'Create my account';

  @override
  String get noAccount => 'No account yet?';

  @override
  String get alreadyAccount => 'Already have an account?';

  @override
  String get errorRequired => 'This field is required.';

  @override
  String get errorEmail => 'Invalid email address.';

  @override
  String get errorPasswordLength => 'At least 10 characters.';

  @override
  String get errorInvalidCredentials => 'Wrong email or password.';

  @override
  String get errorEmailTaken => 'An account already uses this email.';

  @override
  String get errorWrongPassword => 'The current password is incorrect.';

  @override
  String get errorNetwork => 'Babel cannot be reached. Check your connection.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String apiConnected(String version) {
    return 'API connected · v$version';
  }

  @override
  String get apiConnecting => 'Connecting to the API…';

  @override
  String get apiUnreachable => 'API unreachable';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountProfile => 'Profile';

  @override
  String get accountSecurity => 'Security';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved.';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get setPassword => 'Set a password';

  @override
  String get changePassword => 'Change password';

  @override
  String get passwordChanged =>
      'Password changed. Your other devices have been signed out.';

  @override
  String signedInWith(String providers) {
    return 'Signed in with $providers';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccount => 'Delete my account';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountBody =>
      'Your library, notes and statistics will be permanently erased. This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String greetingMorning(String name) {
    return 'Good morning, $name.';
  }

  @override
  String greetingEvening(String name) {
    return 'Good evening, $name.';
  }

  @override
  String get language => 'Language';

  @override
  String get languageName => 'English';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get forgotEyebrow => 'Forgot password';

  @override
  String get forgotTitle => 'Get back into your library.';

  @override
  String get forgotLede =>
      'Enter your account email: we will send you a link to choose a new password.';

  @override
  String get sendResetLink => 'Send the link';

  @override
  String resetLinkSent(String email) {
    return 'If an account exists for $email, an email is on its way. The link is valid for one hour.';
  }

  @override
  String get resetEyebrow => 'New password';

  @override
  String get resetTitle => 'Choose a new password.';

  @override
  String get resetLede => 'Your other devices will be signed out.';

  @override
  String get resetPasswordAction => 'Save the password';

  @override
  String get resetDone => 'Password saved. You can now sign in.';

  @override
  String get errorResetLink =>
      'This link is no longer valid. Ask for a new one.';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get verifyEyebrow => 'Confirmation';

  @override
  String get verifyTitle => 'Confirming your address';

  @override
  String get verifyChecking => 'Checking the link…';

  @override
  String get verifyDone => 'Your address is confirmed. Thank you!';

  @override
  String get continueAction => 'Continue';

  @override
  String get verifyBanner => 'Confirm your email address: we sent you a link.';

  @override
  String get verifyResend => 'Resend';

  @override
  String get verifyResent => 'Link sent. Check your spam folder too.';
}
