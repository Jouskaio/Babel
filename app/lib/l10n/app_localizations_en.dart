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
  String get removeFromLibrary => 'Remove from library';

  @override
  String removed(String title) {
    return '“$title” was taken out. Your notes and review are kept.';
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
  String get opdsUrlHelp =>
      'For example https://calibre.example.com/opds. Kavita: paste your account\'s OPDS address (Settings › OPDS) as it is; the key in it is encrypted.';

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

  @override
  String get offlineReady => 'Available offline on this device';

  @override
  String get downloadOffline => 'Download to read offline';

  @override
  String get friendAdd => 'Add';

  @override
  String get friendAccept => 'Accept';

  @override
  String get friendRequested => 'Request sent';

  @override
  String get friendsWith => 'Friends ✓';

  @override
  String get friendDecline => 'Decline';

  @override
  String get follow => 'Follow';

  @override
  String get unfollow => 'Unfollow';

  @override
  String friendRemoveConfirm(String name) {
    return 'Remove $name from your friends?';
  }

  @override
  String get friendRemove => 'Remove';

  @override
  String get handleTitle => 'Your handle';

  @override
  String get handleHint =>
      'Your friends find you by it. Without a handle, nobody can find you.';

  @override
  String get handleLabel => 'Handle';

  @override
  String get handleRules => '3 to 30 letters, digits, dots or underscores';

  @override
  String get handleTaken => 'This handle is taken.';

  @override
  String get handleInvalid =>
      'Invalid handle: 3 to 30 letters, digits, dots or underscores.';

  @override
  String readerSince(int year) {
    return 'Member since $year';
  }

  @override
  String get statBooks => 'Books';

  @override
  String get statFriends => 'Friends';

  @override
  String get statFollowers => 'Followers';

  @override
  String get friendsTitle => 'Friends';

  @override
  String get seeAll => 'See all';

  @override
  String get searchReaders => 'A reader\'s handle…';

  @override
  String get noReaderFound => 'No reader with this handle.';

  @override
  String get friendInvitesYou => 'Invites you to be friends';

  @override
  String get noFriendsYet => 'No friends yet: search for a reader\'s handle.';

  @override
  String friendReading(String title, int percent) {
    return 'Reading $title · $percent %';
  }

  @override
  String seeMyFriends(int count) {
    return 'See my $count friends';
  }

  @override
  String get friendRequests => 'Requests received';

  @override
  String get followingTitle => 'Following';

  @override
  String get requestsSent => 'Requests sent';

  @override
  String get readerNotFoundSocial => 'This reader does not exist.';

  @override
  String get followsYou => 'Follows you';

  @override
  String get readingNow => 'Reading now';

  @override
  String get reviewsTitle => 'Reviews';

  @override
  String get sharedNotes => 'Shared notes';

  @override
  String comicPageNote(int page) {
    return 'Note on page $page';
  }

  @override
  String get libraryTitleShared => 'Library';

  @override
  String get nothingShared => 'This reader shares nothing with you yet.';

  @override
  String get recommendationsTitle => 'Recommended for you';

  @override
  String get feedTitle => 'Activity';

  @override
  String get feedEmpty => 'Nothing yet: add friends or follow readers.';

  @override
  String feedReading(String name, String title) {
    return '$name is reading $title';
  }

  @override
  String feedReview(String name, String title) {
    return '$name reviewed $title';
  }

  @override
  String feedNote(String name, String title) {
    return '$name shared a note from $title';
  }

  @override
  String recommendedBy(String name) {
    return 'Recommended by $name';
  }

  @override
  String get markRead => 'Seen';

  @override
  String get audiencePrivate => 'Me';

  @override
  String get audienceFriends => 'Friends';

  @override
  String get audiencePublic => 'Everyone';

  @override
  String get shareReading => 'Who sees what I read';

  @override
  String get shareLibrary => 'Who sees my library';

  @override
  String get publicProfile => 'Public profile';

  @override
  String get myReview => 'My review';

  @override
  String ratingStars(int count) {
    return '$count stars';
  }

  @override
  String get reviewHint => 'What you thought of it…';

  @override
  String get whoSees => 'Who sees it';

  @override
  String get reviewSaved => 'Review saved.';

  @override
  String get reviewDelete => 'Delete my review';

  @override
  String get recommendTitle => 'Recommend';

  @override
  String get recommendAction => 'Recommend';

  @override
  String get recommendNoFriends => 'Add friends first to recommend them books.';

  @override
  String get recommendMessage => 'A word for your friend (optional)';

  @override
  String get recommendSend => 'Send';

  @override
  String get recommendationSent => 'Recommendation sent.';

  @override
  String comicPage(int page) {
    return 'Page $page';
  }

  @override
  String get comicDirection => 'Reading direction';

  @override
  String get directionLtr => 'Left → right (comics)';

  @override
  String get directionRtl => 'Right → left (manga)';

  @override
  String get directionVertical => 'Vertical (webtoon)';

  @override
  String get comicAnnotate => 'Note a panel';

  @override
  String get comicAnnotateHint => 'Draw a frame around the panel to note.';

  @override
  String get kavitaTitle => 'Kavita';

  @override
  String get kavitaCreating => 'Creating your Kavita access…';

  @override
  String get kavitaFollow => 'Follow';

  @override
  String kavitaExists(String host) {
    return 'A Kavita account already uses your email on $host: link it with its user name and password.';
  }

  @override
  String get kavitaFailed => 'Your Kavita access could not be created.';

  @override
  String kavitaLinked(String host, String username) {
    return 'Linked to $host · account $username';
  }

  @override
  String get kavitaManaged =>
      'Account made for you by Babel, with every library.';

  @override
  String get kavitaUnlink => 'Unlink';

  @override
  String get kavitaUnlinkConfirm =>
      'Unlink your Kavita? Books already imported stay in your library.';

  @override
  String get kavitaUnlinkManaged =>
      'Remove the Kavita access Babel made? Books already imported stay in your library.';

  @override
  String get kavitaHint =>
      'Your Kavita libraries in Babel. The password is used once to make a \"Babel\" key on your account; it is not kept.';

  @override
  String get kavitaUrl => 'Your Kavita address';

  @override
  String get kavitaUsername => 'Kavita user name';

  @override
  String get kavitaPassword => 'Kavita password';

  @override
  String get kavitaPasswordHelp => 'Used once, never saved.';

  @override
  String get kavitaWrongCredentials => 'Wrong Kavita user name or password.';

  @override
  String get kavitaNotKavita =>
      'This address does not answer like a Kavita server.';

  @override
  String get kavitaUnreachable => 'Kavita could not be reached.';

  @override
  String get kavitaLink => 'Link my Kavita';

  @override
  String get kavitaCreateMine => 'Create my access on Babel\'s Kavita';

  @override
  String get kavitaSetupTitle => 'Your Kavita access';

  @override
  String kavitaSetupHint(String host) {
    return 'Babel is creating your account on $host and linking your library. You can leave this page.';
  }

  @override
  String get kavitaStepCreating => 'Creating the account';

  @override
  String get kavitaStepLinking => 'Making the Babel key';

  @override
  String get kavitaStepImporting => 'Reading the catalog';

  @override
  String get kavitaStepReady => 'Ready';

  @override
  String get kavitaOpenLibrary => 'See my sources';

  @override
  String get kavitaWait => 'It usually takes a few seconds.';

  @override
  String get adminTitle => 'Administration';

  @override
  String get adminPremiumHint =>
      'Premium accounts: access to Babel\'s Kavita, made automatically.';

  @override
  String get adminRole => 'Admin';

  @override
  String get adminKavitaReady => 'Kavita ready';

  @override
  String get adminKavitaFailed => 'Kavita failed';

  @override
  String get adminKavitaExists => 'Kavita exists';

  @override
  String get adminKavitaCreating => 'Kavita in progress';

  @override
  String get moreActions => 'More actions';

  @override
  String get blockReader => 'Block';

  @override
  String get reportReader => 'Report';

  @override
  String blockConfirm(String name) {
    return 'Block $name? You will no longer be friends or follow each other, and neither of you will see the other.';
  }

  @override
  String blocked(String name) {
    return '$name is blocked.';
  }

  @override
  String reportTitle(String name) {
    return 'Report $name';
  }

  @override
  String get reportHint =>
      'Babel\'s administrators will look at the report. This reader is not told.';

  @override
  String get reasonSpam => 'Spam';

  @override
  String get reasonHarassment => 'Harassment';

  @override
  String get reasonInappropriate => 'Inappropriate content';

  @override
  String get reasonOther => 'Other';

  @override
  String get reportNote => 'What happened (optional)';

  @override
  String get reportSend => 'Send the report';

  @override
  String get reportSent => 'Report sent.';

  @override
  String get blockedTitle => 'Blocked';

  @override
  String get unblock => 'Unblock';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsEmpty => 'No reports.';

  @override
  String reportedBy(String handle) {
    return 'Reported by @$handle';
  }

  @override
  String get reportResolve => 'Handled';

  @override
  String get statusToRead => 'To read';

  @override
  String get statusReading => 'Reading';

  @override
  String get statusFinished => 'Read';

  @override
  String get statusAbandoned => 'Abandoned';

  @override
  String get filterAll => 'All';

  @override
  String get showHidden => 'Show hidden books';

  @override
  String get hiddenBadge => 'Hidden';

  @override
  String get hideBook => 'Hide from the library';

  @override
  String get unhideBook => 'Stop hiding';

  @override
  String bookHidden(String title) {
    return '“$title” is hidden. Find it with “Show hidden books”.';
  }

  @override
  String get removeKeepsData =>
      'Your notes, review and progress are kept: add this book again to find them.';

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressHint => 'For a book read elsewhere (paper, another app).';

  @override
  String progressPercent(int percent) {
    return '$percent%';
  }

  @override
  String get shelvesTitle => 'Shelves';

  @override
  String get shelfNew => 'New shelf';

  @override
  String get shelfName => 'Shelf name';

  @override
  String get shelfRename => 'Rename';

  @override
  String get shelfDelete => 'Delete the shelf';

  @override
  String get shelfDeleteBody => 'The books stay in your library.';

  @override
  String get shelfEmpty => 'No book on this shelf yet.';

  @override
  String shelfBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books',
      one: '1 book',
      zero: 'Empty',
    );
    return '$_temp0';
  }

  @override
  String get create => 'Create';

  @override
  String get traceTitle => 'You and this book';

  @override
  String get traceInLibrary => 'In your library';

  @override
  String traceRemoved(String date) {
    return 'Taken out of your library on $date';
  }

  @override
  String get traceGone => 'The file is no longer available; your data is kept.';

  @override
  String traceNotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes and highlights',
      one: '1 note or highlight',
      zero: 'No notes',
    );
    return '$_temp0';
  }

  @override
  String get traceRestore => 'Put it back in my library';

  @override
  String traceRestored(String title) {
    return '“$title” is back, with your notes.';
  }

  @override
  String traceFinishedOn(String date) {
    return 'Read on $date';
  }

  @override
  String get yourBooks => 'In your books';

  @override
  String get workReaders => 'Readers';

  @override
  String get workReadersEmpty => 'No reviews or notes on this book yet.';

  @override
  String workRating(String rating, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$rating out of 5 · $_temp0';
  }

  @override
  String get workAllEditions => 'All editions together';

  @override
  String get you => 'You';

  @override
  String get linkWork => 'Link to a book page';

  @override
  String get linkWorkHint =>
      'Reviews and notes are shared by all editions of a book: pick the matching page.';

  @override
  String get linkWorkNone => 'None of these';

  @override
  String feedFinished(String name, String title) {
    return '$name finished $title';
  }

  @override
  String get profileFinished => 'Recently read';

  @override
  String get shelfManage => 'Manage the shelf';

  @override
  String get tabReading => 'Reading';

  @override
  String get tabToRead => 'To read';

  @override
  String get tabFinished => 'Read';

  @override
  String get tabAbandoned => 'Abandoned';

  @override
  String shelfFilter(String name) {
    return 'Shelf · $name';
  }

  @override
  String get showAll => 'Show all';

  @override
  String get progressElsewhere => 'Read elsewhere? Set my progress';

  @override
  String get progressAsk => 'Where are you?';

  @override
  String get progressAskHint => 'Percent of the book (0 to 100)';

  @override
  String get readerNotesSetting => 'Other readers\' notes';

  @override
  String get readerNotesSettingHint =>
      'The passages they noted, found in your edition.';

  @override
  String get marginOthers => 'Other readers';

  @override
  String notePlaceNear(int percent) {
    return '≈ $percent% into the book';
  }

  @override
  String get noteNotFound => 'Passage not found in your edition';

  @override
  String get noteOtherEdition => 'Another edition';

  @override
  String noteEditionLanguage(String language) {
    return '$language edition';
  }

  @override
  String noteBy(String name) {
    return 'Note by $name';
  }

  @override
  String get goThere => 'Go there';

  @override
  String get statsTitle => 'My reading year';

  @override
  String get statsBooksRead => 'Books read';

  @override
  String get statsReadingDays => 'Reading days';

  @override
  String get statsLongestStreak => 'Longest streak';

  @override
  String get statsNotes => 'Notes';

  @override
  String get statsByMonth => 'Month by month';

  @override
  String get statsTopAuthors => 'Your authors';

  @override
  String get statsBooksList => 'Your reads';

  @override
  String statsCurrentStreak(String days) {
    return 'Current streak: $days';
  }

  @override
  String statsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String statsFinished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books read',
      one: '1 book read',
      zero: 'No book read',
    );
    return '$_temp0';
  }

  @override
  String get statsEmpty =>
      'Nothing yet this year: the books you finish will show here.';

  @override
  String statsOpenWrap(String year) {
    return 'See my $year wrap-up';
  }

  @override
  String statsAverage(String rating) {
    return 'Average rating $rating / 5';
  }

  @override
  String statsAbandoned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abandoned',
      one: '1 abandoned',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String wrapIntro(String year) {
    return '$year in books';
  }

  @override
  String get wrapIntroSub => 'Your reading year, in a few pages.';

  @override
  String wrapFinished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'books finished',
      one: 'book finished',
    );
    return '$_temp0';
  }

  @override
  String wrapDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days spent reading',
      one: 'day spent reading',
    );
    return '$_temp0';
  }

  @override
  String wrapStreak(String days) {
    return 'Your longest streak: $days in a row.';
  }

  @override
  String get wrapBestMonth => 'Your most-read month';

  @override
  String get wrapAuthor => 'Your author of the year';

  @override
  String wrapNotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'notes and highlights',
      one: 'note or highlight',
      zero: 'No notes this year',
    );
    return '$_temp0';
  }

  @override
  String get wrapOutro => 'See you next year';

  @override
  String get wrapOutroSub => 'Thank you for reading with Babel.';

  @override
  String get wrapTapHint => 'Tap to continue';

  @override
  String get paperBook => 'Paper';

  @override
  String get paperOwned => 'I own it on paper';

  @override
  String get paperOwnedHint =>
      'Follow your reading without a file: status, progress, notes and review.';

  @override
  String paperAdded(String title) {
    return '“$title” is in your library, on paper.';
  }

  @override
  String get attachFile => 'Add the file';

  @override
  String get attachFileHint =>
      'To read on this device too: status, progress, review and notes stay the book\'s.';

  @override
  String get paperNoFile => 'Paper book: add its file to read it here too.';

  @override
  String get attachConflict =>
      'This file is already another book of your library.';

  @override
  String attached(String title) {
    return 'File added: “$title” reads here too.';
  }

  @override
  String get genreFanfiction => 'fanfiction';

  @override
  String get genreComics => 'comics';

  @override
  String get genreManga => 'manga';

  @override
  String get genreScienceFiction => 'science fiction';

  @override
  String get genreFantasy => 'fantasy';

  @override
  String get genreHorror => 'horror';

  @override
  String get genreMystery => 'mystery';

  @override
  String get genreRomance => 'romance';

  @override
  String get genreHistorical => 'historical fiction';

  @override
  String get genreYoung => 'young readers';

  @override
  String get genrePoetry => 'poetry';

  @override
  String get genreTheatre => 'drama';

  @override
  String get genreBiography => 'biography';

  @override
  String get genrePhilosophy => 'philosophy';

  @override
  String get genreNonfiction => 'non-fiction';

  @override
  String get genreLiterary => 'literature';

  @override
  String get statsGenres => 'Your genres';

  @override
  String get wrapGenres => 'Your favourite genres';

  @override
  String genreDominant(String genre, int percent) {
    return 'A decidedly $genre year: $percent% of your reading.';
  }

  @override
  String genreTie(String first, String second) {
    return 'Between $first and $second, your heart wavered.';
  }

  @override
  String genreLead(String first, String second) {
    return 'Your genre of the year: $first, ahead of $second.';
  }

  @override
  String genreOnly(String genre) {
    return 'Your genre of the year: $genre.';
  }

  @override
  String genreEclectic(int count) {
    return '$count genres explored: an eclectic year.';
  }

  @override
  String get genreFaithful => 'A single genre: faithful to what you love.';

  @override
  String genreSome(int count) {
    return '$count genres on the clock.';
  }

  @override
  String genreNewLead(String genre, String previous) {
    return 'A change of course: $genre takes the lead; last year it was $previous.';
  }

  @override
  String genreSameLead(String genre) {
    return 'Faithful to $genre, like last year.';
  }

  @override
  String genreFirstTime(String genre) {
    return 'A first this year: $genre.';
  }

  @override
  String get absTitle => 'Audiobookshelf';

  @override
  String get absIntro =>
      'Link your Audiobookshelf to listen to your audiobooks in Babel, with status, shelves and statistics like your books.';

  @override
  String get absUrl => 'Audiobookshelf address';

  @override
  String get absApiKey => 'API key';

  @override
  String get absApiKeyHelp =>
      'Made in Audiobookshelf: Settings › API Keys. Recommended: it does not expire.';

  @override
  String get absUsePassword => 'Use my user name instead';

  @override
  String get absUseKey => 'Use an API key';

  @override
  String get absUsername => 'User name';

  @override
  String get absPassword => 'Password';

  @override
  String get absPasswordHelp => 'Used once: Babel does not keep it.';

  @override
  String get absLink => 'Link';

  @override
  String absLinked(String host, String user) {
    return 'Linked to $host · $user';
  }

  @override
  String get absExpired =>
      'Audiobookshelf now refuses Babel\'s access: link it again.';

  @override
  String get absUnlink => 'Unlink';

  @override
  String get absBrowse => 'Browse my audiobooks';

  @override
  String get absErrorUnauthorized =>
      'Audiobookshelf refused these credentials.';

  @override
  String get absErrorUnreachable =>
      'Audiobookshelf does not answer at this address.';

  @override
  String get absErrorGeneric => 'Audiobookshelf could not be linked.';

  @override
  String get audiobooksTitle => 'Audiobooks';

  @override
  String get audiobooksSearch => 'Search an audiobook';

  @override
  String get audiobookAdd => 'Add';

  @override
  String get audiobookInLibrary => 'In your library';

  @override
  String audiobookAdded(String title) {
    return '“$title” is in your library.';
  }

  @override
  String get audiobooksEmpty => 'No audiobook here.';

  @override
  String get audiobooksNotLinked =>
      'To add audiobooks, link your Audiobookshelf first: its address and an API key (Audiobookshelf, Settings, Users). Its libraries then show here and each book is added to your library with a tap.';

  @override
  String narratedBy(String names) {
    return 'Read by $names';
  }

  @override
  String get listen => 'Listen';

  @override
  String get audioBadge => 'Audio';

  @override
  String get playerChapters => 'Chapters';

  @override
  String get playerSpeed => 'Speed';

  @override
  String get playerSleep => 'Sleep timer';

  @override
  String get sleepOff => 'Off';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get sleepEndOfChapter => 'End of chapter';

  @override
  String sleepLeft(String time) {
    return 'Stops in $time';
  }

  @override
  String get playerBack30 => 'Back 30 s';

  @override
  String get playerForward30 => 'Forward 30 s';

  @override
  String get playerPlay => 'Play';

  @override
  String get playerPause => 'Pause';

  @override
  String get playerError =>
      'Cannot play: check your connection or your Audiobookshelf.';

  @override
  String get workCovers => 'Covers';

  @override
  String coversCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count covers',
      one: '1 cover',
    );
    return '$_temp0';
  }

  @override
  String get coverUse => 'Show this cover';

  @override
  String get searchClear => 'Clear the search';

  @override
  String get recentRemove => 'Remove from history';

  @override
  String get inMySources => 'In my sources';

  @override
  String get inMySourcesHint =>
      'Books from your sources (Kavita, WebDAV, GitHub…) match this work.';

  @override
  String get noSourceMatch => 'None of your sources has this book.';

  @override
  String get manageSources => 'Manage my sources';

  @override
  String get addToLibrary => 'Add to the library';

  @override
  String sourceMatchImported(String title) {
    return '“$title” is in your library.';
  }

  @override
  String get editDetails => 'Edit details';

  @override
  String get detailsTitle => 'Book details';

  @override
  String get detailsBookTitle => 'Title';

  @override
  String get detailsAuthors => 'Authors, separated by commas';

  @override
  String get detailsSeries => 'Series';

  @override
  String get detailsSeriesHint =>
      'Leave empty if this book is not in a series.';

  @override
  String get detailsVolume => 'Volume';

  @override
  String get detailsCover => 'Cover';

  @override
  String get coverUpload => 'Use my own picture';

  @override
  String get coverInvalid =>
      'Invalid picture (JPEG, PNG or WebP, 5 MB at most).';

  @override
  String get requestAnyLanguage => 'Any language';

  @override
  String searchSagaVolumes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# volumes',
      one: '# volume',
    );
    return '$_temp0';
  }

  @override
  String get requestNoRelease =>
      'Requested, but no version to download has been found yet. The search goes on in the background.';

  @override
  String get requestShelfmark =>
      'Sent to Shelfmark: the book will show up in “In my sources” once it has arrived.';

  @override
  String get requestCancel => 'Cancel the request';

  @override
  String get shelfmarkTitle => 'My Shelfmark';

  @override
  String get shelfmarkHint =>
      'If you have your own Shelfmark, link it: the manga and comics you ask for are searched and downloaded there. Its address and API key (the SHELFMARK_API_KEY setting) are in Shelfmark\'s configuration.';

  @override
  String get shelfmarkHintServer =>
      'Without a Shelfmark of your own, manga go through the server\'s (premium accounts only), then Chaptarr. With yours, you need not be premium.';

  @override
  String get shelfmarkUrl => 'Your Shelfmark\'s address';

  @override
  String get shelfmarkKey => 'API key';

  @override
  String get shelfmarkKeyHelp => 'Kept encrypted on the server, never shown.';

  @override
  String get shelfmarkLink => 'Link my Shelfmark';

  @override
  String get shelfmarkUnlink => 'Unlink my Shelfmark';

  @override
  String shelfmarkLinked(String url) {
    return 'Linked: $url';
  }

  @override
  String get shelfmarkLinkedHint =>
      'Your manga and comics are downloaded at your place.';

  @override
  String get shelfmarkWrongKey => 'Shelfmark refused the API key.';

  @override
  String get shelfmarkNotShelfmark =>
      'This address does not answer like a Shelfmark.';

  @override
  String get shelfmarkBadAddress =>
      'Invalid address or key: the address must start with http:// or https://.';

  @override
  String get shelfmarkUnreachable =>
      'Babel could not reach this Shelfmark. The address must be reachable from the internet.';

  @override
  String get requestSearching => 'Searching…';

  @override
  String get requestShelfmarkSent =>
      'Sent to Shelfmark. The book will show up in “In my sources” once it is downloaded.';

  @override
  String get relatedTitle => 'Adaptations & related works';

  @override
  String get relatedFilm => 'Film';

  @override
  String get relatedSeries => 'Series';

  @override
  String get relatedGame => 'Video game';

  @override
  String get relatedComic => 'Comic / manga';

  @override
  String get relatedStage => 'Stage';

  @override
  String get relatedAudio => 'Audio';

  @override
  String get relatedOther => 'Related work';

  @override
  String get levelLabel => 'Level';

  @override
  String get titleNovice => 'Curious';

  @override
  String get titleReader => 'Reader';

  @override
  String get titleBookworm => 'Bookworm';

  @override
  String get titleScholar => 'Scholar';

  @override
  String get titleArchivist => 'Archivist';

  @override
  String get titleLibrarian => 'Librarian of Babel';

  @override
  String get badgeFinished => 'Books finished';

  @override
  String get badgeStreak => 'Days in a row';

  @override
  String get badgeReadingDays => 'Reading days';

  @override
  String get badgeNotes => 'Notes & highlights';

  @override
  String get badgeReviews => 'Reviews written';

  @override
  String get badgeLibrary => 'Library';

  @override
  String get badgeComplete => 'Every tier reached';

  @override
  String get firstSteps => 'First steps';

  @override
  String get stepAddBook => 'Add a first book';

  @override
  String get stepLinkSource => 'Link a source (Kavita, GitHub…)';

  @override
  String get stepRead => 'Read for a while';

  @override
  String get stepNote => 'Take a note or highlight';

  @override
  String get stepFinish => 'Finish a book';

  @override
  String get stepReview => 'Write a review';

  @override
  String xpOf(int xp, int next) {
    return '$xp / $next XP';
  }

  @override
  String badgeNext(int value, int target) {
    return '$value of $target for the next tier';
  }

  @override
  String get koreaderTitle => 'My e-readers (KOReader)';

  @override
  String get koreaderHint =>
      'On an e-reader running KOReader (Boox, Kobo, Kindle…), reading progress syncs with Babel. In KOReader: Tools › Progress sync › Custom sync server, then enter the address, e-mail and password below.';

  @override
  String get koreaderServer => 'Server address';

  @override
  String get koreaderUser => 'Username (e-mail)';

  @override
  String get koreaderPassword => 'KOReader password';

  @override
  String get koreaderShownOnce => 'Write it down: it will not be shown again.';

  @override
  String get koreaderMake => 'Make a password for KOReader';

  @override
  String get koreaderRenew => 'Replace the password';

  @override
  String get pluginsTitle => 'Plugins';

  @override
  String get pluginsHint =>
      'Sources installed by the administrator: switch on the ones you want, they join your sources.';

  @override
  String get pluginsAdminTitle => 'Source plugins';

  @override
  String get pluginsAdminHint =>
      'Install a source from its manifest address: each reader can switch it on (or not).';

  @override
  String get pluginsName => 'Plugin name';

  @override
  String get pluginsUrl => 'Manifest address';

  @override
  String get pluginsToken => 'Access token (optional)';

  @override
  String get pluginsInstall => 'Install the plugin';

  @override
  String get pluginsRemove => 'Remove the plugin';

  @override
  String get pluginsInstallFailed =>
      'This address does not answer like a Babel manifest.';

  @override
  String get externalTitle => 'Elsewhere';

  @override
  String get reviewSpoilers => 'This review has spoilers · show';

  @override
  String ratingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# ratings',
      one: '# rating',
    );
    return '$_temp0';
  }

  @override
  String get homeReading => 'Reading';

  @override
  String get homeResume => 'Resume';

  @override
  String get homeForYou => 'For you';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homePile => 'Reading pile';

  @override
  String get homeJourney => 'Your path';

  @override
  String get homeBadges => 'Badges';

  @override
  String get homeBorn => 'Born from your readings';

  @override
  String get homeMoods => 'Browse by mood';

  @override
  String get homeDownloads => 'Downloads';

  @override
  String get homeWrapInvite => 'See your Wrap';

  @override
  String get moodDarkAcademia => 'Dark academia';

  @override
  String get moodGothic => 'Gothic';

  @override
  String get moodTragicRomance => 'Tragic romance';

  @override
  String get moodBottle => 'Bottle episode';

  @override
  String get moodClassics => 'Classics';

  @override
  String get moodEnemies => 'Enemies to lovers';

  @override
  String get moodFantasy => 'Fantasy';

  @override
  String get moodFanfiction => 'Fanfiction';

  @override
  String homeBooksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# books',
      one: '# book',
    );
    return '$_temp0';
  }

  @override
  String homeYourMonth(String month) {
    return 'Your $month';
  }

  @override
  String homeMonthBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# books finished',
      one: '# book finished',
    );
    return '$_temp0 this month';
  }

  @override
  String get scanPhoto => 'Photograph the cover (experimental)';

  @override
  String get scanPhotoNone =>
      'No book recognized in this photo. Try the barcode, or search by title.';

  @override
  String get scanPhotoUnavailable =>
      'Cover reading is not available on this server.';

  @override
  String get groupAccount => 'Account';

  @override
  String get groupAccountHint => 'Profile, password, public profile';

  @override
  String get groupDisplay => 'Display & devices';

  @override
  String get groupDisplayHint => 'Language, e-reader mode, devices, KOReader';

  @override
  String get groupConnections => 'Sources & connections';

  @override
  String get groupConnectionsHint =>
      'Your sources and plugins, Kavita, Audiobookshelf';

  @override
  String get groupRequests => 'Book requests';

  @override
  String get groupRequestsHint => 'Shelfmark and Chaptarr, to download books';

  @override
  String get groupData => 'Import';

  @override
  String get groupDataHint => 'Import a reading list';

  @override
  String get devicesHint => 'The devices that sync with your account.';

  @override
  String get devicesEmpty => 'No device yet.';

  @override
  String get deviceThis => 'this device';

  @override
  String get deviceForget => 'Forget';

  @override
  String get deviceForgetBody =>
      'This device stops syncing until you sign in on it again. Your books and progress stay.';

  @override
  String get groupSources => 'Sources';

  @override
  String deviceForgetTitle(String name) {
    return 'Forget $name?';
  }

  @override
  String deviceLastSeen(String when) {
    return 'seen $when';
  }

  @override
  String get mySources => 'My sources';

  @override
  String get pageboundTitle => 'Pagebound';

  @override
  String get pageboundHint =>
      'Link your Pagebound account with your public username (no password): your public reviews can be imported into Babel as private reviews, with their ratings.';

  @override
  String get pageboundUsername => 'Pagebound username';

  @override
  String get pageboundLink => 'Link my Pagebound account';

  @override
  String get pageboundUnlink => 'Unlink';

  @override
  String get pageboundImport => 'Import my Pagebound reviews';

  @override
  String get pageboundNotFound => 'No reader with that name on Pagebound.';

  @override
  String pageboundLinked(String name) {
    return 'Linked: $name';
  }

  @override
  String pageboundImported(int imported, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(
      imported,
      locale: localeName,
      other: '# reviews imported',
      one: '# review imported',
    );
    return '$_temp0, $skipped already in your library';
  }

  @override
  String get themeClassics => 'Great classics';

  @override
  String get badgeClassics => 'Classics devourer';

  @override
  String get themeRomance => 'Love stories';

  @override
  String get badgeRomance => 'Heartbeat';

  @override
  String get themeScifi => 'Journeys to the future';

  @override
  String get badgeScifi => 'Time traveler';

  @override
  String get themeMystery => 'Mysteries and crime';

  @override
  String get badgeMystery => 'Sharp sleuth';

  @override
  String get themeFantasy => 'Imaginary worlds';

  @override
  String get badgeFantasy => 'Spellmaster';

  @override
  String get themeComics => 'Comics and manga';

  @override
  String get badgeComics => 'Panel hunter';

  @override
  String get themeYoung => 'Young adult reads';

  @override
  String get badgeYoung => 'Young sprout';

  @override
  String get themeHistory => 'A dive into history';

  @override
  String get badgeHistory => 'Chronicler';

  @override
  String get themeStage => 'Theatre and poetry';

  @override
  String get badgeStage => 'Voice of the stage';

  @override
  String get themeGothic => 'Gothic reads';

  @override
  String get badgeGothic => 'Dark soul';

  @override
  String get themeEssays => 'Essays and ideas';

  @override
  String get badgeEssays => 'Curious mind';

  @override
  String get themeWinter => 'Winter tales';

  @override
  String get badgeWinter => 'Snow watcher';

  @override
  String challengeTitle(String theme) {
    return 'Challenge of the month · $theme';
  }

  @override
  String challengeProgress(int done, int target, String badge) {
    return '$done / $target books — badge “$badge”';
  }

  @override
  String challengeWon(String badge) {
    return 'Challenge won — badge “$badge” earned';
  }

  @override
  String get playlistDystopia => 'Dystopias';

  @override
  String get playlistMystery => 'Mystery & crime';

  @override
  String get playlistHorror => 'Chills';

  @override
  String get playlistHistorical => 'Historical fiction';

  @override
  String get playlistComingOfAge => 'Coming of age';

  @override
  String get playlistHint =>
      'The most read books of this theme, from Open Library.';

  @override
  String get homePlaylists => 'Playlists';

  @override
  String suggestionGenre(String genre) {
    return 'Because you read $genre';
  }

  @override
  String suggestionAuthor(String author) {
    return 'More by $author';
  }

  @override
  String get coverDefault => 'Default';

  @override
  String get coverLinkFirst =>
      'Link this book to a book page first to choose among its editions\' covers.';

  @override
  String volumeNumber(String number) {
    return 'Volume $number';
  }

  @override
  String seriesVolumes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count volumes',
      one: '1 volume',
    );
    return '$_temp0';
  }

  @override
  String seriesRead(int count) {
    return '$count read';
  }

  @override
  String get detailsSaved => 'Details saved.';

  @override
  String seriesOf(String series, String number) {
    return '$series · volume $number';
  }

  @override
  String get goalSet => 'Set a goal';

  @override
  String get goalEdit => 'Change';

  @override
  String get goalAsk => 'How many books this year?';

  @override
  String get goalAskHint => 'Books to finish each year';

  @override
  String get goalRemove => 'Remove the goal';

  @override
  String goalProgress(int done, int goal) {
    return '$done of $goal books';
  }

  @override
  String get goalReached => 'Goal reached, well done!';

  @override
  String goalLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books to go',
      one: '1 book to go',
    );
    return '$_temp0';
  }

  @override
  String get importTitle => 'Import a reading history';

  @override
  String get importIntro =>
      'Goodreads, StoryGraph or Babelio: export your list as CSV and Babel takes it with statuses, ratings and dates (paper books, no file).';

  @override
  String get importChoose => 'Choose the CSV file';

  @override
  String csvImportDone(int imported, int skipped, int failed) {
    return '$imported imported · $skipped already there · $failed without a title';
  }

  @override
  String get importNotList => 'This file is not a reading list Babel knows.';

  @override
  String get likeReview => 'Like';

  @override
  String get commentsTitle => 'Comments';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
      zero: 'Comment',
    );
    return '$_temp0';
  }

  @override
  String get commentHint => 'Your comment';

  @override
  String get commentSend => 'Post';

  @override
  String get commentDelete => 'Delete';

  @override
  String get commentsEmpty => 'No comments yet.';

  @override
  String get audioDownload => 'Listen offline';

  @override
  String get audioDownloading => 'Downloading…';

  @override
  String get audioOffline => 'Available offline';

  @override
  String get sagaTitle => 'Saga';

  @override
  String get sagaSee => 'See the whole saga';

  @override
  String sagaOf(String series, String number) {
    return '$series · volume $number';
  }

  @override
  String sagaCount(int count, int owned) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count volumes',
      one: '1 volume',
    );
    return '$_temp0 in the catalog · $owned in your library';
  }

  @override
  String get sagaMissing => 'Not found in the catalog';

  @override
  String get sagaNotOwned => 'Not in your library';

  @override
  String get sagaEmpty => 'No volume found for this saga.';

  @override
  String get sagaHint =>
      'Volumes come from the catalog: open one to add it, or to look for it in your sources.';

  @override
  String get progressAskPageHint => 'Page number';

  @override
  String cleanFinished(int count) {
    return 'Remove finished books ($count)';
  }

  @override
  String cleanFinishedAsk(int count) {
    return 'Remove $count finished books from the library?';
  }

  @override
  String get cleanFinishedBody =>
      'The files go, not your notes, reviews or progress: add a book back and you get them again.';

  @override
  String cleanFinishedDone(int count) {
    return '$count books removed.';
  }

  @override
  String monthWrapBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'books finished',
      one: 'book finished',
      zero: 'books finished',
    );
    return '$_temp0';
  }

  @override
  String get monthWrapEmpty => 'No book finished this month.';

  @override
  String get monthWrapShare => 'Share the image';

  @override
  String statsOpenMonth(String month) {
    return '$month recap';
  }

  @override
  String get scanBurst => 'Burst: add each book as paper';

  @override
  String scanBurstAdded(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books added',
      one: '1 book added',
    );
    return '$_temp0: $titles';
  }

  @override
  String get adminConnectors => 'Connectors';

  @override
  String get adminSourcesHealth => 'Source health';

  @override
  String get adminNoSources => 'No source connected.';

  @override
  String adminScanned(String date) {
    return 'scanned $date';
  }

  @override
  String get adminNeverScanned => 'never scanned';

  @override
  String adminQuota(String value) {
    return 'Sources: $value';
  }

  @override
  String adminQuotaDefault(int count) {
    return 'default ($count)';
  }

  @override
  String get adminQuotaAsk => 'How many sources?';

  @override
  String get adminQuotaHint => 'Empty: back to the server default';

  @override
  String get requestBook => 'Request this book';

  @override
  String get requestHint =>
      'Babel looks for it and downloads it for you. It shows up here once it has arrived.';

  @override
  String get requestPending =>
      'Requested: being searched. Come back in a while.';

  @override
  String get requestAvailable =>
      'Downloaded: it shows up here after the next scan.';

  @override
  String get requestNotFound => 'Not found for now.';

  @override
  String get requestFailed => 'The request could not be sent. Try again later.';

  @override
  String get addSourceHint =>
      'This book is in none of your sources. Add one (Kavita, WebDAV, GitHub…) to find it here, or link your Chaptarr in Account to ask for it.';

  @override
  String get sourceScanning =>
      'Scanning… a big account can take several minutes.';

  @override
  String get sagaOpenKnown =>
      'Not in the catalog: open it to look in your sources or ask for it.';

  @override
  String get chaptarrTitle => 'My Chaptarr';

  @override
  String get chaptarrHint =>
      'If you run your own Chaptarr, link it: the books you ask for in Babel are searched and downloaded there. Its address and API key are in Chaptarr, Settings, General.';

  @override
  String get chaptarrHintServer =>
      'Without a Chaptarr of your own, requests go through the server\'s (premium accounts only). With yours you can ask without being premium: its address and API key are in Chaptarr, Settings, General.';

  @override
  String get chaptarrUrl => 'Your Chaptarr\'s address';

  @override
  String get chaptarrKey => 'API key';

  @override
  String get chaptarrKeyHelp => 'Kept encrypted on the server, never shown.';

  @override
  String get chaptarrLink => 'Link my Chaptarr';

  @override
  String get chaptarrUnlink => 'Unlink my Chaptarr';

  @override
  String chaptarrLinked(String url) {
    return 'Linked: $url';
  }

  @override
  String get chaptarrLinkedHint => 'Your book requests go to yours.';

  @override
  String get chaptarrWrongKey => 'Chaptarr refused the API key.';

  @override
  String get chaptarrNotChaptarr =>
      'This address does not answer like a Chaptarr.';

  @override
  String get chaptarrBadAddress =>
      'Invalid address or key: the address must start with http:// or https://.';

  @override
  String get chaptarrUnreachable =>
      'Babel could not reach this Chaptarr. The address must be reachable from the internet.';

  @override
  String requestDownloading(int percent) {
    return 'Downloading: $percent%';
  }

  @override
  String sourceScanDone(int total, int added, int removed) {
    return 'Scan finished: $total books (+$added, −$removed)';
  }

  @override
  String get librarySearchHint => 'Search my library';

  @override
  String get libraryNoMatch => 'No book in your library matches.';

  @override
  String get audiobooksLinkNow => 'Link my Audiobookshelf';

  @override
  String get fanficSummary => 'Summary';

  @override
  String get fanficFandoms => 'Fandoms';

  @override
  String get fanficRelationships => 'Relationships';

  @override
  String get fanficCharacters => 'Characters';

  @override
  String get fanficTags => 'Tags';

  @override
  String get fanficWarnings => 'Warnings';

  @override
  String fanficWords(int count) {
    return '$count words';
  }

  @override
  String fanficKudos(int count) {
    return '$count kudos';
  }

  @override
  String fanficHits(int count) {
    return '$count hits';
  }

  @override
  String fanficChapters(String chapters) {
    return '$chapters chapters';
  }

  @override
  String fanficUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String fanficPublished(String date) {
    return 'Published $date';
  }

  @override
  String get fanficOnAo3 => 'View on AO3';

  @override
  String get fanficUnavailable =>
      'AO3 could not give the details of this fanfiction (members only, or unreachable for now).';
}
