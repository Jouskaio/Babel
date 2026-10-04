import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @brand.
  ///
  /// In fr, this message translates to:
  /// **'BABEL'**
  String get brand;

  /// No description provided for @navFeatures.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionnalités'**
  String get navFeatures;

  /// No description provided for @navDevices.
  ///
  /// In fr, this message translates to:
  /// **'Appareils'**
  String get navDevices;

  /// No description provided for @navPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get navPrivacy;

  /// No description provided for @signIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccount;

  /// No description provided for @heroEyebrow.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèque · Lecture · Annotations'**
  String get heroEyebrow;

  /// No description provided for @heroTitleLead.
  ///
  /// In fr, this message translates to:
  /// **'Toute votre bibliothèque, '**
  String get heroTitleLead;

  /// No description provided for @heroTitleEmphasis.
  ///
  /// In fr, this message translates to:
  /// **'au même endroit.'**
  String get heroTitleEmphasis;

  /// No description provided for @heroLede.
  ///
  /// In fr, this message translates to:
  /// **'Livres papier ou numériques, BD, audio et fanfictions : rangez toute votre bibliothèque, suivez vos lectures et partagez-les avec vos amis. Importez vos propres fichiers pour les lire où que vous soyez.'**
  String get heroLede;

  /// No description provided for @startFree.
  ///
  /// In fr, this message translates to:
  /// **'Commencer — c’est gratuit'**
  String get startFree;

  /// No description provided for @haveAccount.
  ///
  /// In fr, this message translates to:
  /// **'J’ai déjà un compte'**
  String get haveAccount;

  /// No description provided for @heroNote.
  ///
  /// In fr, this message translates to:
  /// **'Sans publicité. Vos données restent les vôtres.'**
  String get heroNote;

  /// No description provided for @trendingLabel.
  ///
  /// In fr, this message translates to:
  /// **'Tendance cette semaine'**
  String get trendingLabel;

  /// No description provided for @featuresEyebrow.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionnalités'**
  String get featuresEyebrow;

  /// No description provided for @featuresTitle.
  ///
  /// In fr, this message translates to:
  /// **'Une bibliothèque qui vous ressemble, pas un catalogue.'**
  String get featuresTitle;

  /// No description provided for @featureAllTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tout au même endroit'**
  String get featureAllTitle;

  /// No description provided for @featureAllBody.
  ///
  /// In fr, this message translates to:
  /// **'Scannez vos livres papier, importez vos fichiers, téléchargez vos fanfictions depuis AO3 et retrouvez vos lectures en cours, à lire et terminées.'**
  String get featureAllBody;

  /// No description provided for @featureSyncTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos fichiers, partout'**
  String get featureSyncTitle;

  /// No description provided for @featureSyncBody.
  ///
  /// In fr, this message translates to:
  /// **'Importez vos EPUB et reprenez à la bonne page sur liseuse, téléphone ou ordinateur, même hors ligne.'**
  String get featureSyncBody;

  /// No description provided for @featureNotesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annotez en marge'**
  String get featureNotesTitle;

  /// No description provided for @featureNotesBody.
  ///
  /// In fr, this message translates to:
  /// **'Surlignez, commentez, retrouvez vos passages préférés et ceux de vos amis.'**
  String get featureNotesBody;

  /// No description provided for @featureStatsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos lectures, en chiffres'**
  String get featureStatsTitle;

  /// No description provided for @featureStatsBody.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques, objectifs et un bilan de fin d’année que vous aurez envie de partager.'**
  String get featureStatsBody;

  /// No description provided for @devicesEyebrow.
  ///
  /// In fr, this message translates to:
  /// **'Appareils'**
  String get devicesEyebrow;

  /// No description provided for @devicesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lisez où vous voulez. Babel suit.'**
  String get devicesTitle;

  /// No description provided for @devicesBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre progression, vos notes et vos étagères se synchronisent entre vos appareils. Commencez un chapitre au lit sur votre liseuse, finissez-le dans le métro.'**
  String get devicesBody;

  /// No description provided for @deviceChapter.
  ///
  /// In fr, this message translates to:
  /// **'Chapitre XII'**
  String get deviceChapter;

  /// No description provided for @deviceExcerpt.
  ///
  /// In fr, this message translates to:
  /// **'Marguerite ouvrit la fenêtre. La lune, au-dessus des toits, éclairait la rue d’une lumière blanche et nette, comme si quelqu’un avait tendu un drap sur toute la ville…'**
  String get deviceExcerpt;

  /// No description provided for @deviceSynced.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisé'**
  String get deviceSynced;

  /// No description provided for @quote.
  ///
  /// In fr, this message translates to:
  /// **'« Quoi que nos âmes soient faites, la sienne et la mienne sont pareilles. »'**
  String get quote;

  /// No description provided for @quoteAuthor.
  ///
  /// In fr, this message translates to:
  /// **'Emily Brontë · Les Hauts de Hurle-Vent'**
  String get quoteAuthor;

  /// No description provided for @ctaTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez votre bibliothèque.'**
  String get ctaTitle;

  /// No description provided for @ctaBody.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre compte en une minute.'**
  String get ctaBody;

  /// No description provided for @footerPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get footerPrivacy;

  /// No description provided for @footerTerms.
  ///
  /// In fr, this message translates to:
  /// **'Conditions'**
  String get footerTerms;

  /// No description provided for @footerContact.
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get footerContact;

  /// No description provided for @authQuote.
  ///
  /// In fr, this message translates to:
  /// **'« Un lecteur vit mille vies avant de mourir. »'**
  String get authQuote;

  /// No description provided for @authQuoteAuthor.
  ///
  /// In fr, this message translates to:
  /// **'George R. R. Martin'**
  String get authQuoteAuthor;

  /// No description provided for @loginEyebrow.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get loginEyebrow;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour parmi nous.'**
  String get loginTitle;

  /// No description provided for @loginLede.
  ///
  /// In fr, this message translates to:
  /// **'Reprenez votre lecture là où vous l’aviez laissée.'**
  String get loginLede;

  /// No description provided for @signupEyebrow.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get signupEyebrow;

  /// No description provided for @signupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez votre bibliothèque.'**
  String get signupTitle;

  /// No description provided for @signupLede.
  ///
  /// In fr, this message translates to:
  /// **'Un compte pour retrouver vos livres, vos notes et vos amis sur tous vos appareils.'**
  String get signupLede;

  /// No description provided for @continueWithApple.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get continueWithGoogle;

  /// No description provided for @or.
  ///
  /// In fr, this message translates to:
  /// **'ou'**
  String get or;

  /// No description provided for @displayNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom affiché'**
  String get displayNameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordLabel;

  /// No description provided for @showPassword.
  ///
  /// In fr, this message translates to:
  /// **'Afficher'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In fr, this message translates to:
  /// **'Masquer'**
  String get hidePassword;

  /// No description provided for @passwordHelp.
  ///
  /// In fr, this message translates to:
  /// **'10 caractères minimum. Une phrase de passe est idéale.'**
  String get passwordHelp;

  /// No description provided for @termsNotice.
  ///
  /// In fr, this message translates to:
  /// **'En créant un compte, vous acceptez les Conditions d’utilisation et la Politique de confidentialité.'**
  String get termsNotice;

  /// No description provided for @createMyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get createMyAccount;

  /// No description provided for @noAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get noAccount;

  /// No description provided for @alreadyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ?'**
  String get alreadyAccount;

  /// No description provided for @errorRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est requis.'**
  String get errorRequired;

  /// No description provided for @errorEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email invalide.'**
  String get errorEmail;

  /// No description provided for @errorPasswordLength.
  ///
  /// In fr, this message translates to:
  /// **'10 caractères minimum.'**
  String get errorPasswordLength;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Email ou mot de passe incorrect.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorEmailTaken.
  ///
  /// In fr, this message translates to:
  /// **'Un compte existe déjà avec cet email.'**
  String get errorEmailTaken;

  /// No description provided for @errorWrongPassword.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe actuel est incorrect.'**
  String get errorWrongPassword;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre Babel. Vérifiez votre connexion.'**
  String get errorNetwork;

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez.'**
  String get errorGeneric;

  /// No description provided for @apiConnected.
  ///
  /// In fr, this message translates to:
  /// **'API connectée · v{version}'**
  String apiConnected(String version);

  /// No description provided for @apiConnecting.
  ///
  /// In fr, this message translates to:
  /// **'Connexion à l’API…'**
  String get apiConnecting;

  /// No description provided for @apiUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'API injoignable'**
  String get apiUnreachable;

  /// No description provided for @accountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get accountTitle;

  /// No description provided for @accountProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get accountProfile;

  /// No description provided for @accountSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get accountSecurity;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In fr, this message translates to:
  /// **'Enregistré.'**
  String get saved;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get newPasswordLabel;

  /// No description provided for @setPassword.
  ///
  /// In fr, this message translates to:
  /// **'Définir un mot de passe'**
  String get setPassword;

  /// No description provided for @changePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get changePassword;

  /// No description provided for @passwordChanged.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe modifié. Vos autres appareils ont été déconnectés.'**
  String get passwordChanged;

  /// No description provided for @signedInWith.
  ///
  /// In fr, this message translates to:
  /// **'Connecté avec {providers}'**
  String signedInWith(String providers);

  /// No description provided for @signOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer votre compte ?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre bibliothèque, vos notes et vos statistiques seront définitivement effacées. Cette action est irréversible.'**
  String get deleteAccountBody;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @greetingMorning.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour, {name}.'**
  String greetingMorning(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In fr, this message translates to:
  /// **'Bonsoir, {name}.'**
  String greetingEvening(String name);

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @languageName.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageName;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgotPassword;

  /// No description provided for @forgotEyebrow.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get forgotEyebrow;

  /// No description provided for @forgotTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retrouvez l’accès à votre bibliothèque.'**
  String get forgotTitle;

  /// No description provided for @forgotLede.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez l’email de votre compte : nous vous enverrons un lien pour choisir un nouveau mot de passe.'**
  String get forgotLede;

  /// No description provided for @sendResetLink.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le lien'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In fr, this message translates to:
  /// **'Si un compte existe pour {email}, un email vient de lui être envoyé. Le lien est valable une heure.'**
  String resetLinkSent(String email);

  /// No description provided for @resetEyebrow.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get resetEyebrow;

  /// No description provided for @resetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un nouveau mot de passe.'**
  String get resetTitle;

  /// No description provided for @resetLede.
  ///
  /// In fr, this message translates to:
  /// **'Vos autres appareils seront déconnectés.'**
  String get resetLede;

  /// No description provided for @resetPasswordAction.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le mot de passe'**
  String get resetPasswordAction;

  /// No description provided for @resetDone.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe enregistré. Vous pouvez vous connecter.'**
  String get resetDone;

  /// No description provided for @errorResetLink.
  ///
  /// In fr, this message translates to:
  /// **'Ce lien n’est plus valable. Demandez-en un nouveau.'**
  String get errorResetLink;

  /// No description provided for @backToSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Retour à la connexion'**
  String get backToSignIn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
