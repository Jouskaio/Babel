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

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navScan => 'Scan';

  @override
  String get navLibrary => 'Library';

  @override
  String get navProfile => 'Profile';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Title, author, ISBN…';

  @override
  String get recentTitle => 'Recent';

  @override
  String get clear => 'Clear';

  @override
  String get trendingTitle => 'Trending';

  @override
  String noResults(String query) {
    return 'No results for “$query”.';
  }

  @override
  String get searchFailed =>
      'The search did not go through. Try again in a moment.';

  @override
  String get libraryTitle => 'Library';

  @override
  String libraryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titles',
      one: '1 title',
      zero: 'No titles',
    );
    return '$_temp0';
  }

  @override
  String get libraryEmpty => 'Your library is empty for now.';

  @override
  String get addOwnBooksTitle => 'Add your own books';

  @override
  String get addOwnBooksBody =>
      'EPUB, PDF, CBZ or CBR: your files follow you on all your devices.';

  @override
  String get importFile => 'Import a file';

  @override
  String importing(String name) {
    return 'Importing “$name”…';
  }

  @override
  String imported(String title) {
    return '“$title” joined your library.';
  }

  @override
  String importDeduplicated(String title) {
    return '“$title” was already on Babel: added without uploading it again.';
  }

  @override
  String get importUnsupported => 'This file is not an EPUB, PDF, CBZ or CBR.';

  @override
  String get importTooLarge => 'This file is too large.';

  @override
  String get importBlocked =>
      'This file was withdrawn from Babel and cannot be imported.';

  @override
  String get download => 'Download';

  @override
  String get downloading => 'Downloading…';

  @override
  String get downloaded => 'Downloaded to this device.';

  @override
  String get downloadedWeb => 'Download started.';

  @override
  String get onDevice => 'On this device';

  @override
  String get removeFromLibrary => 'Remove from library';

  @override
  String removed(String title) {
    return '“$title” was removed from your library.';
  }

  @override
  String get workSummary => 'Summary';

  @override
  String get readMore => 'Read more';

  @override
  String get readLess => 'Show less';

  @override
  String get workEditions => 'Editions & languages';

  @override
  String editionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count editions',
      one: '1 edition',
    );
    return '$_temp0';
  }

  @override
  String pages(int count) {
    return '$count p.';
  }

  @override
  String get getThisBook => 'Get this book';

  @override
  String get importOwnCopy =>
      'Import your own file (EPUB, PDF…): it will join your library.';

  @override
  String get scanTitle => 'Scan a book';

  @override
  String get scanHint => 'Place the barcode inside the frame';

  @override
  String scanFound(String isbn) {
    return 'Found · ISBN $isbn';
  }

  @override
  String get seeWork => 'See the book';

  @override
  String get isbnManualHint => 'Enter an ISBN';

  @override
  String get isbnLookup => 'Search';

  @override
  String get isbnNotFound => 'No book found for this ISBN.';

  @override
  String get isbnInvalid => 'This ISBN is not valid.';

  @override
  String get cameraUnavailable => 'Camera unavailable: enter the ISBN below.';

  @override
  String get retry => 'Retry';

  @override
  String get offline => 'Offline';

  @override
  String pendingOps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes waiting',
      one: '1 change waiting',
    );
    return '$_temp0';
  }

  @override
  String get pendingTitle => 'Waiting';

  @override
  String get searchQueued =>
      'Offline: the search will run when the network is back.';

  @override
  String get scanQueued =>
      'Offline: this ISBN will be looked up when the network is back.';

  @override
  String get lookupWaiting => 'Waiting for the network';

  @override
  String lookupResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get lookupNotFound => 'Not found';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get sourcesTitle => 'Sources';

  @override
  String get sourcesIntro =>
      'Connect the places where you already keep your books. Babel browses them read-only and offers to import what is missing.';

  @override
  String get sourcesEmpty => 'No source yet.';

  @override
  String get addSource => 'Add a source';

  @override
  String get sourcesPrivacy =>
      'Your access tokens are encrypted on the server and never shown again. Deleting a source does not delete the books already imported.';

  @override
  String sourceGitHubFolder(String folder) {
    return 'GitHub · folder /$folder';
  }

  @override
  String get sourceGitHubRoot => 'GitHub · whole repository';

  @override
  String get sourceNeverScanned => 'Not scanned yet';

  @override
  String get sourceUnreachable => 'Cannot be reached';

  @override
  String scannedAgo(String when) {
    return 'scanned $when';
  }

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: 'yesterday',
    );
    return '$_temp0';
  }

  @override
  String get newSourceTitle => 'New source';

  @override
  String get newSourceQuestion => 'Where are your books?';

  @override
  String get kindGitHubDescription =>
      'A repository (or a folder) of EPUB, PDF, CBZ, CBR';

  @override
  String get kindOpds => 'OPDS catalog';

  @override
  String get kindOpdsDescription => 'Calibre-Web, Kavita, Komga, COPS…';

  @override
  String get kindWebdav => 'Nextcloud / WebDAV';

  @override
  String get kindWebdavDescription => 'A folder on your cloud or your NAS';

  @override
  String get kindAo3 => 'Fanfictions';

  @override
  String get kindAo3Description =>
      'Your AO3 account, with your bookmarks and subscriptions';

  @override
  String get kindCustom => 'Custom connector';

  @override
  String get kindCustomDescription =>
      'Any address returning a Babel manifest (JSON)';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get githubTitle => 'GitHub repository';

  @override
  String get githubSubtitle => 'Read-only · EPUB, PDF, CBZ, CBR';

  @override
  String get githubRepository => 'Repository';

  @override
  String get githubRepositoryInvalid =>
      'Use the owner/name form, e.g. jouskaio/ebooks.';

  @override
  String get githubFolder => 'Folder (optional)';

  @override
  String get githubToken => 'Access token (optional)';

  @override
  String get githubTokenHelp =>
      'Needed for a private repository. Create a fine-grained token limited to this repository, read-only (Contents: Read).';

  @override
  String get githubCreateToken => 'Create a token on GitHub';

  @override
  String get paste => 'Paste';

  @override
  String get testSource => 'Test';

  @override
  String sourceTestOk(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Connection successful · $count files found',
      one: 'Connection successful · 1 file found',
      zero: 'Connection successful · no book found',
    );
    return '$_temp0';
  }

  @override
  String get sourceErrorUnreachable =>
      'Babel could not open this repository. Check its name and, if it is private, the token.';

  @override
  String get sourceErrorTooMany =>
      'You have reached the maximum number of sources.';

  @override
  String get sourceErrorTokens =>
      'Private repositories are not available on this server yet.';

  @override
  String sourceBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books',
      one: '1 book',
      zero: 'No book',
    );
    return '$_temp0';
  }

  @override
  String sourceNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new',
      one: '1 new',
      zero: 'nothing new',
    );
    return '$_temp0';
  }

  @override
  String get rescan => 'Rescan';

  @override
  String importAllNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import the $count new',
      one: 'Import the new one',
    );
    return '$_temp0';
  }

  @override
  String get sectionNew => 'New';

  @override
  String get sectionInLibrary => 'In the library';

  @override
  String get importEntry => 'Import';

  @override
  String get addEntry => 'Add';

  @override
  String get onBabelBadge => 'Already on Babel · direct download';

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books imported',
      one: '1 book imported',
      zero: 'Nothing imported',
    );
    return '$_temp0';
  }

  @override
  String importFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files could not be imported',
      one: '1 file could not be imported',
    );
    return '$_temp0';
  }

  @override
  String get importEntryFailed => 'This file could not be imported.';

  @override
  String get deleteSource => 'Delete this source';

  @override
  String get deleteSourceTitle => 'Delete this source?';

  @override
  String get deleteSourceBody =>
      'Babel forgets the source and its token. Books already imported stay in your library.';

  @override
  String get sourceScanFailed =>
      'The last scan failed: the source could not be reached.';

  @override
  String get accountSourcesHint =>
      'GitHub repositories and other places that hold your books';

  @override
  String unitKb(String size) {
    return '$size KB';
  }

  @override
  String unitMb(String size) {
    return '$size MB';
  }

  @override
  String get sectionUnreadable => 'Unreadable files';

  @override
  String get unreadableHint =>
      'Babel could not read these files as books. They will be tried again if they change.';

  @override
  String get unreadable => 'Unreadable';

  @override
  String get sourceErrorRateLimited =>
      'GitHub limits requests without a token (60 per hour for your connection). Try again in a few minutes, or add an access token.';

  @override
  String deleteSourceBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Also remove the $count books imported from it',
      one: 'Also remove the book imported from it',
    );
    return '$_temp0';
  }

  @override
  String get deleteSourceBodyWithBooks =>
      'Babel forgets the source and its token, and removes its books from your library. Other readers keep their copies.';

  @override
  String get opdsTitle => 'OPDS catalog';

  @override
  String get opdsSubtitle => 'Read-only · Calibre-Web, Kavita, Komga, COPS…';

  @override
  String get opdsUrl => 'Catalog address';

  @override
  String get opdsUrlHelp => 'For example https://calibre.example.com/opds';

  @override
  String get webdavTitle => 'WebDAV folder';

  @override
  String get webdavSubtitle => 'Read-only · Nextcloud, ownCloud, NAS';

  @override
  String get webdavUrl => 'Folder address';

  @override
  String get webdavUrlHelp =>
      'Nextcloud: Files → Settings → WebDAV address, followed by the folder of your books.';

  @override
  String get webdavPassword => 'App password';

  @override
  String get webdavPasswordHelp =>
      'Create a dedicated app password (Nextcloud: Settings → Security) rather than using your main password.';

  @override
  String get ao3Title => 'AO3 fanfiction';

  @override
  String get ao3Subtitle => 'Archive of Our Own · your bookmarks';

  @override
  String get ao3Username => 'AO3 username';

  @override
  String get ao3Password => 'AO3 password (optional)';

  @override
  String get ao3PasswordHelp =>
      'Without it, only your public bookmarks are visible. With it, Babel also sees your private bookmarks, your subscriptions and works restricted to members. It is encrypted on the server.';

  @override
  String get ao3SlowHint =>
      'Babel reads AO3 slowly, out of politeness: scanning can take a minute.';

  @override
  String get sourceUsernameOptional => 'Username (optional)';

  @override
  String get sourceUsername => 'Username';

  @override
  String get sourcePasswordOptional => 'Password (optional)';

  @override
  String get urlInvalid => 'Enter an address starting with https:// or http://';

  @override
  String get usernameInvalid => 'Enter your username';

  @override
  String get sourceErrorUnreachableGeneric =>
      'Babel could not open this source. Check the address and the credentials.';

  @override
  String get sourceErrorPrivate =>
      'This address is on a private network: the server administrator must allow it first.';

  @override
  String get sourceErrorRateLimitedGeneric =>
      'The source limits requests for now. Try again in a few minutes.';

  @override
  String sourceOpdsAt(String host) {
    return 'OPDS catalog · $host';
  }

  @override
  String sourceWebdavAt(String host) {
    return 'WebDAV · $host';
  }

  @override
  String sourceAo3Of(String username) {
    return 'AO3 · bookmarks of $username';
  }

  @override
  String get readBook => 'Read';

  @override
  String get readerOpening => 'Opening the book…';

  @override
  String get readerNotFound => 'This book is not in your library.';

  @override
  String get readerUnsupported =>
      'Babel cannot show this format yet. Download the file to read it in another app.';

  @override
  String get readerBroken => 'This file could not be opened.';

  @override
  String chapterNumber(int number) {
    return 'Chapter $number';
  }

  @override
  String chapterOf(int number, int total) {
    return 'Chapter $number / $total';
  }

  @override
  String get nextChapter => 'Next chapter';

  @override
  String get textSize => 'Text size';

  @override
  String pageOf(int page, int total) {
    return 'Page $page / $total';
  }

  @override
  String get importPaused =>
      'the source asked for a pause: continue in a few minutes';

  @override
  String get linkTitle => 'Import a link';

  @override
  String get linkHeading => 'From a link';

  @override
  String get linkSubtitle => 'AO3, Gutenberg or a link to a file';

  @override
  String get linkField => 'Link';

  @override
  String get linkHelp =>
      'A book already on Babel is added without downloading it again.';

  @override
  String get linkShareTip => 'Tip: in your browser, Share → Babel';

  @override
  String get linkChecking => 'Looking at the link…';

  @override
  String get linkAo3 => 'AO3 fanfiction';

  @override
  String get linkGutenberg => 'Gutenberg book';

  @override
  String get linkFile => 'File';

  @override
  String get linkOnBabel => 'already on Babel';

  @override
  String get linkImport => 'Import into my library';

  @override
  String get linkImporting => 'Importing…';

  @override
  String get linkAo3Waiting =>
      'AO3 spaces downloads: this can take a few seconds, nothing to do';

  @override
  String get linkDone => 'Added to your library';

  @override
  String get readNow => 'Read now';

  @override
  String get linkRateLimited =>
      'AO3 asks for a pause: try again in a few minutes.';

  @override
  String get linkNotABook =>
      'This link does not lead to an EPUB, PDF or CBZ book.';

  @override
  String get linkUnsupported => 'Babel cannot import from this link.';

  @override
  String get linkUnreachable =>
      'This page could not be reached, or it is restricted to signed-in members.';

  @override
  String get genericUrl => 'Manifest address';

  @override
  String get genericUrlHelp =>
      'Any address serving a Babel manifest (JSON): a static file is enough.';

  @override
  String get genericToken => 'Access token (optional)';

  @override
  String get genericDocs => 'The manifest format';

  @override
  String get genericSubtitle => 'Read-only · your own list of books';

  @override
  String sourceGenericAt(String host) {
    return 'Custom connector · $host';
  }

  @override
  String get noteHint => 'Write in the margin…';

  @override
  String get removeAnnotation => 'Remove';

  @override
  String get marginTitle => 'In the margin';

  @override
  String marginCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '1 note',
      zero: 'No note',
    );
    return '$_temp0';
  }

  @override
  String get marginEmpty =>
      'Select text while reading to highlight it or write a note.';

  @override
  String get highlightNote => 'Note';

  @override
  String get copy => 'Copy';

  @override
  String followActive(String chapters) {
    return 'New chapters checked every day · $chapters';
  }

  @override
  String followComplete(String chapters) {
    return 'Finished work · $chapters';
  }

  @override
  String get followHint =>
      'When the author posts a chapter, the book is updated on all your devices; your place and notes stay.';

  @override
  String get followCheckNow => 'Check now';

  @override
  String get followStop => 'Stop following';

  @override
  String followNewChapters(String chapters) {
    return 'New version: $chapters';
  }

  @override
  String get followNothingNew => 'No new chapter for now';

  @override
  String get linkFollowed => 'new chapters will arrive by themselves';

  @override
  String get linkKindsTitle => 'What Babel can import';

  @override
  String get linkKindAo3 =>
      'archiveofourown.org/works/…: the fanfiction as an EPUB. If it is not finished, Babel checks for new chapters every day and updates the book.';

  @override
  String get linkKindGutenberg =>
      'gutenberg.org/ebooks/…: the public-domain book as an EPUB, with its illustrations.';

  @override
  String get linkKindFile =>
      'A direct link to an EPUB, PDF or CBZ file, on any website.';

  @override
  String get linkKindsElse =>
      'Other pages (online reading sites, shops) are not supported.';

  @override
  String get linkWillFollow => 'ongoing: new chapters checked every day';

  @override
  String get libraryNewChapters => 'New chapter';

  @override
  String get readerSettings => 'Reading settings';

  @override
  String get readerTheme => 'Theme';

  @override
  String get readerThemeEink => 'E-reader: black on white, for electronic ink.';

  @override
  String get themeNight => 'Night';

  @override
  String get themeDay => 'Day';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get readerFont => 'Font';

  @override
  String get fontSans => 'Sans serif';

  @override
  String get fontLexend => 'Lexend · designed for dyslexia';

  @override
  String get fontAtkinson => 'Atkinson Hyperlegible · low vision';

  @override
  String get readerSpacing => 'Line spacing';

  @override
  String get spacingCompact => 'Compact';

  @override
  String get spacingNormal => 'Normal';

  @override
  String get spacingAiry => 'Airy';

  @override
  String get readerLayout => 'Reading';

  @override
  String get layoutScroll => 'Scrolling';

  @override
  String get layoutPages => 'Pages';

  @override
  String get layoutPagesHint =>
      'Tap the right or left edge, or swipe, to turn the page.';

  @override
  String get einkTitle => 'E-reader (electronic ink)';

  @override
  String get einkHint =>
      'Black on white, no animations, page by page reading and page keys.';

  @override
  String get einkAuto => 'Automatic';

  @override
  String get einkOn => 'On';

  @override
  String get einkOff => 'Off';

  @override
  String get einkDetected => 'This device is an e-reader.';
}
