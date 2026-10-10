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
    Locale('fr'),
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
  /// **'Vos sources, partout'**
  String get featureSyncTitle;

  /// No description provided for @featureSyncBody.
  ///
  /// In fr, this message translates to:
  /// **'Importez vos EPUB ou branchez vos propres sources — GitHub, catalogue OPDS, Nextcloud — et reprenez à la bonne page sur liseuse, téléphone ou ordinateur.'**
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

  /// No description provided for @verifyEyebrow.
  ///
  /// In fr, this message translates to:
  /// **'Confirmation'**
  String get verifyEyebrow;

  /// No description provided for @verifyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmation de votre adresse'**
  String get verifyTitle;

  /// No description provided for @verifyChecking.
  ///
  /// In fr, this message translates to:
  /// **'Vérification du lien…'**
  String get verifyChecking;

  /// No description provided for @verifyDone.
  ///
  /// In fr, this message translates to:
  /// **'Votre adresse est confirmée. Merci !'**
  String get verifyDone;

  /// No description provided for @continueAction.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueAction;

  /// No description provided for @verifyBanner.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez votre adresse email : nous vous avons envoyé un lien.'**
  String get verifyBanner;

  /// No description provided for @verifyResend.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer'**
  String get verifyResend;

  /// No description provided for @verifyResent.
  ///
  /// In fr, this message translates to:
  /// **'Lien envoyé. Pensez à vérifier vos spams.'**
  String get verifyResent;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In fr, this message translates to:
  /// **'Chercher'**
  String get navSearch;

  /// No description provided for @navScan.
  ///
  /// In fr, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Biblio'**
  String get navLibrary;

  /// No description provided for @navProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @searchTitle.
  ///
  /// In fr, this message translates to:
  /// **'Chercher'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Titre, auteur, ISBN…'**
  String get searchHint;

  /// No description provided for @recentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Récemment'**
  String get recentTitle;

  /// No description provided for @clear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get clear;

  /// No description provided for @trendingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tendances'**
  String get trendingTitle;

  /// No description provided for @noResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat pour « {query} ».'**
  String noResults(String query);

  /// No description provided for @searchFailed.
  ///
  /// In fr, this message translates to:
  /// **'La recherche n’a pas abouti. Réessayez dans un instant.'**
  String get searchFailed;

  /// No description provided for @libraryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèque'**
  String get libraryTitle;

  /// No description provided for @libraryCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun titre} =1{1 titre} other{{count} titres}}'**
  String libraryCount(int count);

  /// No description provided for @libraryEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Votre bibliothèque est vide pour l’instant.'**
  String get libraryEmpty;

  /// No description provided for @addOwnBooksTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter vos propres livres'**
  String get addOwnBooksTitle;

  /// No description provided for @addOwnBooksBody.
  ///
  /// In fr, this message translates to:
  /// **'EPUB, PDF, CBZ ou CBR : vos fichiers vous suivent sur tous vos appareils.'**
  String get addOwnBooksBody;

  /// No description provided for @importFile.
  ///
  /// In fr, this message translates to:
  /// **'Importer un fichier'**
  String get importFile;

  /// No description provided for @importing.
  ///
  /// In fr, this message translates to:
  /// **'Import de « {name} »…'**
  String importing(String name);

  /// No description provided for @imported.
  ///
  /// In fr, this message translates to:
  /// **'« {title} » a rejoint votre bibliothèque.'**
  String imported(String title);

  /// No description provided for @importDeduplicated.
  ///
  /// In fr, this message translates to:
  /// **'« {title} » était déjà sur Babel : ajouté sans le renvoyer.'**
  String importDeduplicated(String title);

  /// No description provided for @importUnsupported.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier n’est pas un EPUB, PDF, CBZ ou CBR.'**
  String get importUnsupported;

  /// No description provided for @importTooLarge.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier est trop volumineux.'**
  String get importTooLarge;

  /// No description provided for @importBlocked.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier a été retiré de Babel et ne peut pas être importé.'**
  String get importBlocked;

  /// No description provided for @download.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get download;

  /// No description provided for @downloading.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement…'**
  String get downloading;

  /// No description provided for @downloaded.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargé sur cet appareil.'**
  String get downloaded;

  /// No description provided for @downloadedWeb.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement lancé.'**
  String get downloadedWeb;

  /// No description provided for @removeFromLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Retirer de la bibliothèque'**
  String get removeFromLibrary;

  /// No description provided for @removed.
  ///
  /// In fr, this message translates to:
  /// **'« {title} » a été retiré. Vos notes et votre avis sont gardés.'**
  String removed(String title);

  /// No description provided for @workSummary.
  ///
  /// In fr, this message translates to:
  /// **'Résumé'**
  String get workSummary;

  /// No description provided for @readMore.
  ///
  /// In fr, this message translates to:
  /// **'Lire la suite'**
  String get readMore;

  /// No description provided for @readLess.
  ///
  /// In fr, this message translates to:
  /// **'Réduire'**
  String get readLess;

  /// No description provided for @workEditions.
  ///
  /// In fr, this message translates to:
  /// **'Éditions & langues'**
  String get workEditions;

  /// No description provided for @editionsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 édition} other{{count} éditions}}'**
  String editionsCount(int count);

  /// No description provided for @pages.
  ///
  /// In fr, this message translates to:
  /// **'{count} p.'**
  String pages(int count);

  /// No description provided for @getThisBook.
  ///
  /// In fr, this message translates to:
  /// **'Obtenir ce livre'**
  String get getThisBook;

  /// No description provided for @importOwnCopy.
  ///
  /// In fr, this message translates to:
  /// **'Importez votre propre fichier (EPUB, PDF…) : il rejoindra votre bibliothèque.'**
  String get importOwnCopy;

  /// No description provided for @scanTitle.
  ///
  /// In fr, this message translates to:
  /// **'Scanner un livre'**
  String get scanTitle;

  /// No description provided for @scanHint.
  ///
  /// In fr, this message translates to:
  /// **'Placez le code-barres dans le cadre'**
  String get scanHint;

  /// No description provided for @scanFound.
  ///
  /// In fr, this message translates to:
  /// **'Trouvé · ISBN {isbn}'**
  String scanFound(String isbn);

  /// No description provided for @seeWork.
  ///
  /// In fr, this message translates to:
  /// **'Voir la fiche'**
  String get seeWork;

  /// No description provided for @isbnManualHint.
  ///
  /// In fr, this message translates to:
  /// **'Saisir un ISBN'**
  String get isbnManualHint;

  /// No description provided for @isbnLookup.
  ///
  /// In fr, this message translates to:
  /// **'Chercher'**
  String get isbnLookup;

  /// No description provided for @isbnNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livre trouvé pour cet ISBN.'**
  String get isbnNotFound;

  /// No description provided for @isbnInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Cet ISBN n’est pas valide.'**
  String get isbnInvalid;

  /// No description provided for @cameraUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Caméra indisponible : saisissez l’ISBN ci-dessous.'**
  String get cameraUnavailable;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @offline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get offline;

  /// No description provided for @pendingOps.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 changement en attente} other{{count} changements en attente}}'**
  String pendingOps(int count);

  /// No description provided for @pendingTitle.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get pendingTitle;

  /// No description provided for @searchQueued.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne : la recherche sera lancée au retour du réseau.'**
  String get searchQueued;

  /// No description provided for @scanQueued.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne : cet ISBN sera recherché au retour du réseau.'**
  String get scanQueued;

  /// No description provided for @lookupWaiting.
  ///
  /// In fr, this message translates to:
  /// **'En attente du réseau'**
  String get lookupWaiting;

  /// No description provided for @lookupResults.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun résultat} =1{1 résultat} other{{count} résultats}}'**
  String lookupResults(int count);

  /// No description provided for @lookupNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Introuvable'**
  String get lookupNotFound;

  /// No description provided for @dismiss.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get dismiss;

  /// No description provided for @sourcesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sources'**
  String get sourcesTitle;

  /// No description provided for @sourcesIntro.
  ///
  /// In fr, this message translates to:
  /// **'Branchez les endroits où vous rangez déjà vos livres. Babel les parcourt en lecture seule et vous propose d\'importer ce qui manque.'**
  String get sourcesIntro;

  /// No description provided for @sourcesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune source pour l\'instant.'**
  String get sourcesEmpty;

  /// No description provided for @addSource.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une source'**
  String get addSource;

  /// No description provided for @sourcesPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Vos jetons d\'accès sont chiffrés sur le serveur et ne sont jamais réaffichés. Supprimer une source ne supprime pas les livres déjà importés.'**
  String get sourcesPrivacy;

  /// No description provided for @sourceGitHubFolder.
  ///
  /// In fr, this message translates to:
  /// **'GitHub · dossier /{folder}'**
  String sourceGitHubFolder(String folder);

  /// No description provided for @sourceGitHubRoot.
  ///
  /// In fr, this message translates to:
  /// **'GitHub · dépôt entier'**
  String get sourceGitHubRoot;

  /// No description provided for @sourceNeverScanned.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore parcourue'**
  String get sourceNeverScanned;

  /// No description provided for @sourceUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Injoignable'**
  String get sourceUnreachable;

  /// No description provided for @scannedAgo.
  ///
  /// In fr, this message translates to:
  /// **'scanné {when}'**
  String scannedAgo(String when);

  /// No description provided for @justNow.
  ///
  /// In fr, this message translates to:
  /// **'à l\'instant'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count} min'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count} h'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{hier} other{il y a {count} jours}}'**
  String daysAgo(int count);

  /// No description provided for @newSourceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle source'**
  String get newSourceTitle;

  /// No description provided for @newSourceQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Où sont vos livres ?'**
  String get newSourceQuestion;

  /// No description provided for @kindGitHubDescription.
  ///
  /// In fr, this message translates to:
  /// **'Un dépôt (ou un dossier) d\'EPUB, PDF, CBZ, CBR'**
  String get kindGitHubDescription;

  /// No description provided for @kindOpds.
  ///
  /// In fr, this message translates to:
  /// **'Catalogue OPDS'**
  String get kindOpds;

  /// No description provided for @kindOpdsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Calibre-Web, Kavita, Komga, COPS…'**
  String get kindOpdsDescription;

  /// No description provided for @kindWebdav.
  ///
  /// In fr, this message translates to:
  /// **'Nextcloud / WebDAV'**
  String get kindWebdav;

  /// No description provided for @kindWebdavDescription.
  ///
  /// In fr, this message translates to:
  /// **'Un dossier de votre cloud ou de votre NAS'**
  String get kindWebdavDescription;

  /// No description provided for @kindAo3.
  ///
  /// In fr, this message translates to:
  /// **'Fanfictions'**
  String get kindAo3;

  /// No description provided for @kindAo3Description.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte AO3, avec vos favoris et abonnements'**
  String get kindAo3Description;

  /// No description provided for @kindCustom.
  ///
  /// In fr, this message translates to:
  /// **'Connecteur personnalisé'**
  String get kindCustom;

  /// No description provided for @kindCustomDescription.
  ///
  /// In fr, this message translates to:
  /// **'Toute adresse qui renvoie un manifeste Babel (JSON)'**
  String get kindCustomDescription;

  /// No description provided for @comingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt'**
  String get comingSoon;

  /// No description provided for @githubTitle.
  ///
  /// In fr, this message translates to:
  /// **'Dépôt GitHub'**
  String get githubTitle;

  /// No description provided for @githubSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Lecture seule · EPUB, PDF, CBZ, CBR'**
  String get githubSubtitle;

  /// No description provided for @githubRepository.
  ///
  /// In fr, this message translates to:
  /// **'Dépôt'**
  String get githubRepository;

  /// No description provided for @githubRepositoryInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Utilisez la forme propriétaire/nom, par exemple jouskaio/ebooks.'**
  String get githubRepositoryInvalid;

  /// No description provided for @githubFolder.
  ///
  /// In fr, this message translates to:
  /// **'Dossier (facultatif)'**
  String get githubFolder;

  /// No description provided for @githubToken.
  ///
  /// In fr, this message translates to:
  /// **'Jeton d\'accès (facultatif)'**
  String get githubToken;

  /// No description provided for @githubTokenHelp.
  ///
  /// In fr, this message translates to:
  /// **'Nécessaire pour un dépôt privé. Créez un jeton « fine-grained » limité à ce dépôt, en lecture seule (Contents : Read).'**
  String get githubTokenHelp;

  /// No description provided for @githubCreateToken.
  ///
  /// In fr, this message translates to:
  /// **'Créer un jeton sur GitHub'**
  String get githubCreateToken;

  /// No description provided for @paste.
  ///
  /// In fr, this message translates to:
  /// **'Coller'**
  String get paste;

  /// No description provided for @testSource.
  ///
  /// In fr, this message translates to:
  /// **'Tester'**
  String get testSource;

  /// No description provided for @sourceTestOk.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Connexion réussie · aucun livre trouvé} =1{Connexion réussie · 1 fichier trouvé} other{Connexion réussie · {count} fichiers trouvés}}'**
  String sourceTestOk(int count);

  /// No description provided for @sourceErrorUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Babel n\'a pas pu ouvrir ce dépôt. Vérifiez son nom et, s\'il est privé, le jeton.'**
  String get sourceErrorUnreachable;

  /// No description provided for @sourceErrorTooMany.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez atteint le nombre maximal de sources.'**
  String get sourceErrorTooMany;

  /// No description provided for @sourceErrorTokens.
  ///
  /// In fr, this message translates to:
  /// **'Les dépôts privés ne sont pas encore disponibles sur ce serveur.'**
  String get sourceErrorTokens;

  /// No description provided for @sourceBookCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun livre} =1{1 livre} other{{count} livres}}'**
  String sourceBookCount(int count);

  /// No description provided for @sourceNewCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{rien de nouveau} =1{1 nouveau} other{{count} nouveaux}}'**
  String sourceNewCount(int count);

  /// No description provided for @rescan.
  ///
  /// In fr, this message translates to:
  /// **'Rescanner'**
  String get rescan;

  /// No description provided for @importAllNew.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Importer le nouveau} other{Importer les {count} nouveaux}}'**
  String importAllNew(int count);

  /// No description provided for @sectionNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux'**
  String get sectionNew;

  /// No description provided for @sectionInLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Dans la bibliothèque'**
  String get sectionInLibrary;

  /// No description provided for @importEntry.
  ///
  /// In fr, this message translates to:
  /// **'Importer'**
  String get importEntry;

  /// No description provided for @addEntry.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get addEntry;

  /// No description provided for @onBabelBadge.
  ///
  /// In fr, this message translates to:
  /// **'Déjà sur Babel · téléchargement direct'**
  String get onBabelBadge;

  /// No description provided for @importDone.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Rien d\'importé} =1{1 livre importé} other{{count} livres importés}}'**
  String importDone(int count);

  /// No description provided for @importFailed.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 fichier n\'a pas pu être importé} other{{count} fichiers n\'ont pas pu être importés}}'**
  String importFailed(int count);

  /// No description provided for @importEntryFailed.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier n\'a pas pu être importé.'**
  String get importEntryFailed;

  /// No description provided for @deleteSource.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette source'**
  String get deleteSource;

  /// No description provided for @deleteSourceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette source ?'**
  String get deleteSourceTitle;

  /// No description provided for @deleteSourceBody.
  ///
  /// In fr, this message translates to:
  /// **'Babel oublie la source et son jeton. Les livres déjà importés restent dans votre bibliothèque.'**
  String get deleteSourceBody;

  /// No description provided for @sourceScanFailed.
  ///
  /// In fr, this message translates to:
  /// **'Le dernier scan a échoué : la source était injoignable.'**
  String get sourceScanFailed;

  /// No description provided for @accountSourcesHint.
  ///
  /// In fr, this message translates to:
  /// **'Dépôts GitHub et autres endroits qui contiennent vos livres'**
  String get accountSourcesHint;

  /// No description provided for @unitKb.
  ///
  /// In fr, this message translates to:
  /// **'{size} Ko'**
  String unitKb(String size);

  /// No description provided for @unitMb.
  ///
  /// In fr, this message translates to:
  /// **'{size} Mo'**
  String unitMb(String size);

  /// No description provided for @sectionUnreadable.
  ///
  /// In fr, this message translates to:
  /// **'Fichiers illisibles'**
  String get sectionUnreadable;

  /// No description provided for @unreadableHint.
  ///
  /// In fr, this message translates to:
  /// **'Babel n\'a pas pu lire ces fichiers comme des livres. Ils seront retentés s\'ils changent.'**
  String get unreadableHint;

  /// No description provided for @unreadable.
  ///
  /// In fr, this message translates to:
  /// **'Illisible'**
  String get unreadable;

  /// No description provided for @sourceErrorRateLimited.
  ///
  /// In fr, this message translates to:
  /// **'GitHub limite les requêtes sans jeton (60 par heure pour votre connexion). Réessayez dans quelques minutes, ou ajoutez un jeton d\'accès.'**
  String get sourceErrorRateLimited;

  /// No description provided for @deleteSourceBooks.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Retirer aussi le livre importé} other{Retirer aussi les {count} livres importés}}'**
  String deleteSourceBooks(int count);

  /// No description provided for @deleteSourceBodyWithBooks.
  ///
  /// In fr, this message translates to:
  /// **'Babel oublie la source et son jeton, et retire ses livres de votre bibliothèque. Les autres lecteurs gardent leurs exemplaires.'**
  String get deleteSourceBodyWithBooks;

  /// No description provided for @opdsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Catalogue OPDS'**
  String get opdsTitle;

  /// No description provided for @opdsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Lecture seule · Calibre-Web, Kavita, Komga, COPS…'**
  String get opdsSubtitle;

  /// No description provided for @opdsUrl.
  ///
  /// In fr, this message translates to:
  /// **'Adresse du catalogue'**
  String get opdsUrl;

  /// No description provided for @opdsUrlHelp.
  ///
  /// In fr, this message translates to:
  /// **'Par exemple https://calibre.example.com/opds. Kavita : collez l\'adresse OPDS de votre compte (Paramètres › OPDS) telle quelle, la clé qu\'elle contient est chiffrée.'**
  String get opdsUrlHelp;

  /// No description provided for @webdavTitle.
  ///
  /// In fr, this message translates to:
  /// **'Dossier WebDAV'**
  String get webdavTitle;

  /// No description provided for @webdavSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Lecture seule · Nextcloud, ownCloud, NAS'**
  String get webdavSubtitle;

  /// No description provided for @webdavUrl.
  ///
  /// In fr, this message translates to:
  /// **'Adresse du dossier'**
  String get webdavUrl;

  /// No description provided for @webdavUrlHelp.
  ///
  /// In fr, this message translates to:
  /// **'Nextcloud : Fichiers → Paramètres → adresse WebDAV, suivie du dossier de vos livres.'**
  String get webdavUrlHelp;

  /// No description provided for @webdavPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe d\'application'**
  String get webdavPassword;

  /// No description provided for @webdavPasswordHelp.
  ///
  /// In fr, this message translates to:
  /// **'Créez un mot de passe d\'application dédié (Nextcloud : Paramètres → Sécurité) plutôt que votre mot de passe principal.'**
  String get webdavPasswordHelp;

  /// No description provided for @ao3Title.
  ///
  /// In fr, this message translates to:
  /// **'Fanfictions AO3'**
  String get ao3Title;

  /// No description provided for @ao3Subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Archive of Our Own · vos favoris'**
  String get ao3Subtitle;

  /// No description provided for @ao3Username.
  ///
  /// In fr, this message translates to:
  /// **'Pseudo AO3'**
  String get ao3Username;

  /// No description provided for @ao3Password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe AO3 (facultatif)'**
  String get ao3Password;

  /// No description provided for @ao3PasswordHelp.
  ///
  /// In fr, this message translates to:
  /// **'Sans mot de passe, seuls vos favoris publics sont visibles. Avec, Babel voit aussi vos favoris privés, vos abonnements et les œuvres réservées aux membres. Il est chiffré sur le serveur.'**
  String get ao3PasswordHelp;

  /// No description provided for @ao3SlowHint.
  ///
  /// In fr, this message translates to:
  /// **'Babel lit AO3 lentement, par politesse : le scan peut prendre une minute.'**
  String get ao3SlowHint;

  /// No description provided for @sourceUsernameOptional.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant (facultatif)'**
  String get sourceUsernameOptional;

  /// No description provided for @sourceUsername.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant'**
  String get sourceUsername;

  /// No description provided for @sourcePasswordOptional.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe (facultatif)'**
  String get sourcePasswordOptional;

  /// No description provided for @urlInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez une adresse commençant par https:// ou http://'**
  String get urlInvalid;

  /// No description provided for @usernameInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre pseudo'**
  String get usernameInvalid;

  /// No description provided for @sourceErrorUnreachableGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Babel n\'a pas pu ouvrir cette source. Vérifiez l\'adresse et les identifiants.'**
  String get sourceErrorUnreachableGeneric;

  /// No description provided for @sourceErrorPrivate.
  ///
  /// In fr, this message translates to:
  /// **'Cette adresse est sur un réseau privé : l\'administrateur du serveur doit d\'abord l\'autoriser.'**
  String get sourceErrorPrivate;

  /// No description provided for @sourceErrorRateLimitedGeneric.
  ///
  /// In fr, this message translates to:
  /// **'La source limite les requêtes pour l\'instant. Réessayez dans quelques minutes.'**
  String get sourceErrorRateLimitedGeneric;

  /// No description provided for @sourceOpdsAt.
  ///
  /// In fr, this message translates to:
  /// **'Catalogue OPDS · {host}'**
  String sourceOpdsAt(String host);

  /// No description provided for @sourceWebdavAt.
  ///
  /// In fr, this message translates to:
  /// **'WebDAV · {host}'**
  String sourceWebdavAt(String host);

  /// No description provided for @sourceAo3Of.
  ///
  /// In fr, this message translates to:
  /// **'AO3 · favoris de {username}'**
  String sourceAo3Of(String username);

  /// No description provided for @readBook.
  ///
  /// In fr, this message translates to:
  /// **'Lire'**
  String get readBook;

  /// No description provided for @readerOpening.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture du livre…'**
  String get readerOpening;

  /// No description provided for @readerNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Ce livre n\'est pas dans votre bibliothèque.'**
  String get readerNotFound;

  /// No description provided for @readerUnsupported.
  ///
  /// In fr, this message translates to:
  /// **'Babel ne sait pas encore afficher ce format. Téléchargez le fichier pour le lire dans une autre application.'**
  String get readerUnsupported;

  /// No description provided for @readerBroken.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier n\'a pas pu être ouvert.'**
  String get readerBroken;

  /// No description provided for @chapterNumber.
  ///
  /// In fr, this message translates to:
  /// **'Chapitre {number}'**
  String chapterNumber(int number);

  /// No description provided for @chapterOf.
  ///
  /// In fr, this message translates to:
  /// **'Chapitre {number} / {total}'**
  String chapterOf(int number, int total);

  /// No description provided for @nextChapter.
  ///
  /// In fr, this message translates to:
  /// **'Chapitre suivant'**
  String get nextChapter;

  /// No description provided for @textSize.
  ///
  /// In fr, this message translates to:
  /// **'Taille du texte'**
  String get textSize;

  /// No description provided for @pageOf.
  ///
  /// In fr, this message translates to:
  /// **'Page {page} / {total}'**
  String pageOf(int page, int total);

  /// No description provided for @importPaused.
  ///
  /// In fr, this message translates to:
  /// **'la source demande une pause : reprenez dans quelques minutes'**
  String get importPaused;

  /// No description provided for @linkTitle.
  ///
  /// In fr, this message translates to:
  /// **'Importer un lien'**
  String get linkTitle;

  /// No description provided for @linkHeading.
  ///
  /// In fr, this message translates to:
  /// **'Par lien'**
  String get linkHeading;

  /// No description provided for @linkSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'AO3, Gutenberg ou lien vers un fichier'**
  String get linkSubtitle;

  /// No description provided for @linkField.
  ///
  /// In fr, this message translates to:
  /// **'Lien'**
  String get linkField;

  /// No description provided for @linkHelp.
  ///
  /// In fr, this message translates to:
  /// **'Un livre déjà sur Babel est ajouté sans être retéléchargé.'**
  String get linkHelp;

  /// No description provided for @linkShareTip.
  ///
  /// In fr, this message translates to:
  /// **'Astuce : depuis le navigateur, Partager → Babel'**
  String get linkShareTip;

  /// No description provided for @linkChecking.
  ///
  /// In fr, this message translates to:
  /// **'Lecture du lien…'**
  String get linkChecking;

  /// No description provided for @linkAo3.
  ///
  /// In fr, this message translates to:
  /// **'Fanfiction AO3'**
  String get linkAo3;

  /// No description provided for @linkGutenberg.
  ///
  /// In fr, this message translates to:
  /// **'Livre Gutenberg'**
  String get linkGutenberg;

  /// No description provided for @linkFile.
  ///
  /// In fr, this message translates to:
  /// **'Fichier'**
  String get linkFile;

  /// No description provided for @linkOnBabel.
  ///
  /// In fr, this message translates to:
  /// **'déjà sur Babel'**
  String get linkOnBabel;

  /// No description provided for @linkImport.
  ///
  /// In fr, this message translates to:
  /// **'Importer dans ma bibliothèque'**
  String get linkImport;

  /// No description provided for @linkImporting.
  ///
  /// In fr, this message translates to:
  /// **'Importation…'**
  String get linkImporting;

  /// No description provided for @linkAo3Waiting.
  ///
  /// In fr, this message translates to:
  /// **'AO3 espace les téléchargements : cela peut prendre quelques secondes, rien à faire'**
  String get linkAo3Waiting;

  /// No description provided for @linkDone.
  ///
  /// In fr, this message translates to:
  /// **'Ajouté à votre bibliothèque'**
  String get linkDone;

  /// No description provided for @readNow.
  ///
  /// In fr, this message translates to:
  /// **'Lire maintenant'**
  String get readNow;

  /// No description provided for @linkRateLimited.
  ///
  /// In fr, this message translates to:
  /// **'AO3 demande une pause : réessayez dans quelques minutes.'**
  String get linkRateLimited;

  /// No description provided for @linkNotABook.
  ///
  /// In fr, this message translates to:
  /// **'Ce lien ne mène pas à un livre EPUB, PDF ou CBZ.'**
  String get linkNotABook;

  /// No description provided for @linkUnsupported.
  ///
  /// In fr, this message translates to:
  /// **'Babel ne sait pas importer depuis ce lien.'**
  String get linkUnsupported;

  /// No description provided for @linkUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Cette page est injoignable, ou réservée aux membres connectés.'**
  String get linkUnreachable;

  /// No description provided for @genericUrl.
  ///
  /// In fr, this message translates to:
  /// **'Adresse du manifeste'**
  String get genericUrl;

  /// No description provided for @genericUrlHelp.
  ///
  /// In fr, this message translates to:
  /// **'Toute adresse qui renvoie un manifeste Babel (JSON) : un simple fichier statique suffit.'**
  String get genericUrlHelp;

  /// No description provided for @genericToken.
  ///
  /// In fr, this message translates to:
  /// **'Jeton d\'accès (facultatif)'**
  String get genericToken;

  /// No description provided for @genericDocs.
  ///
  /// In fr, this message translates to:
  /// **'Le format du manifeste'**
  String get genericDocs;

  /// No description provided for @genericSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Lecture seule · votre propre liste de livres'**
  String get genericSubtitle;

  /// No description provided for @sourceGenericAt.
  ///
  /// In fr, this message translates to:
  /// **'Connecteur · {host}'**
  String sourceGenericAt(String host);

  /// No description provided for @noteHint.
  ///
  /// In fr, this message translates to:
  /// **'Écrire en marge…'**
  String get noteHint;

  /// No description provided for @removeAnnotation.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get removeAnnotation;

  /// No description provided for @marginTitle.
  ///
  /// In fr, this message translates to:
  /// **'En marge'**
  String get marginTitle;

  /// No description provided for @marginCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune note} =1{1 note} other{{count} notes}}'**
  String marginCount(int count);

  /// No description provided for @marginEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez du texte pendant la lecture pour le surligner ou écrire une note.'**
  String get marginEmpty;

  /// No description provided for @highlightNote.
  ///
  /// In fr, this message translates to:
  /// **'Note'**
  String get highlightNote;

  /// No description provided for @copy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get copy;

  /// No description provided for @followActive.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux chapitres vérifiés chaque jour · {chapters}'**
  String followActive(String chapters);

  /// No description provided for @followComplete.
  ///
  /// In fr, this message translates to:
  /// **'Œuvre terminée · {chapters}'**
  String followComplete(String chapters);

  /// No description provided for @followHint.
  ///
  /// In fr, this message translates to:
  /// **'Quand l\'autrice publie un chapitre, le livre est mis à jour sur tous vos appareils ; votre position et vos notes restent.'**
  String get followHint;

  /// No description provided for @followCheckNow.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier maintenant'**
  String get followCheckNow;

  /// No description provided for @followStop.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter le suivi'**
  String get followStop;

  /// No description provided for @followNewChapters.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle version : {chapters}'**
  String followNewChapters(String chapters);

  /// No description provided for @followNothingNew.
  ///
  /// In fr, this message translates to:
  /// **'Pas de nouveau chapitre pour l\'instant'**
  String get followNothingNew;

  /// No description provided for @linkFollowed.
  ///
  /// In fr, this message translates to:
  /// **'les nouveaux chapitres arriveront tout seuls'**
  String get linkFollowed;

  /// No description provided for @linkKindsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce que Babel sait importer'**
  String get linkKindsTitle;

  /// No description provided for @linkKindAo3.
  ///
  /// In fr, this message translates to:
  /// **'archiveofourown.org/works/… : la fanfiction en EPUB. Si elle n\'est pas terminée, Babel vérifie chaque jour les nouveaux chapitres et met le livre à jour.'**
  String get linkKindAo3;

  /// No description provided for @linkKindGutenberg.
  ///
  /// In fr, this message translates to:
  /// **'gutenberg.org/ebooks/… : le livre du domaine public en EPUB, avec ses illustrations.'**
  String get linkKindGutenberg;

  /// No description provided for @linkKindFile.
  ///
  /// In fr, this message translates to:
  /// **'Un lien direct vers un fichier EPUB, PDF ou CBZ, sur n\'importe quel site.'**
  String get linkKindFile;

  /// No description provided for @linkKindsElse.
  ///
  /// In fr, this message translates to:
  /// **'Les autres pages (sites de lecture en ligne, boutiques) ne sont pas prises en charge.'**
  String get linkKindsElse;

  /// No description provided for @linkWillFollow.
  ///
  /// In fr, this message translates to:
  /// **'en cours : nouveaux chapitres vérifiés chaque jour'**
  String get linkWillFollow;

  /// No description provided for @libraryNewChapters.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau chapitre'**
  String get libraryNewChapters;

  /// No description provided for @readerSettings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages de lecture'**
  String get readerSettings;

  /// No description provided for @readerTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get readerTheme;

  /// No description provided for @readerThemeEink.
  ///
  /// In fr, this message translates to:
  /// **'Liseuse : noir sur blanc, pour l\'encre électronique.'**
  String get readerThemeEink;

  /// No description provided for @themeNight.
  ///
  /// In fr, this message translates to:
  /// **'Nuit'**
  String get themeNight;

  /// No description provided for @themeDay.
  ///
  /// In fr, this message translates to:
  /// **'Jour'**
  String get themeDay;

  /// No description provided for @themeSepia.
  ///
  /// In fr, this message translates to:
  /// **'Sépia'**
  String get themeSepia;

  /// No description provided for @readerFont.
  ///
  /// In fr, this message translates to:
  /// **'Police'**
  String get readerFont;

  /// No description provided for @fontSans.
  ///
  /// In fr, this message translates to:
  /// **'Sans empattement'**
  String get fontSans;

  /// No description provided for @fontLexend.
  ///
  /// In fr, this message translates to:
  /// **'Lexend · conçue pour la dyslexie'**
  String get fontLexend;

  /// No description provided for @fontAtkinson.
  ///
  /// In fr, this message translates to:
  /// **'Atkinson Hyperlegible · malvoyance'**
  String get fontAtkinson;

  /// No description provided for @readerSpacing.
  ///
  /// In fr, this message translates to:
  /// **'Interligne'**
  String get readerSpacing;

  /// No description provided for @spacingCompact.
  ///
  /// In fr, this message translates to:
  /// **'Serré'**
  String get spacingCompact;

  /// No description provided for @spacingNormal.
  ///
  /// In fr, this message translates to:
  /// **'Normal'**
  String get spacingNormal;

  /// No description provided for @spacingAiry.
  ///
  /// In fr, this message translates to:
  /// **'Aéré'**
  String get spacingAiry;

  /// No description provided for @readerLayout.
  ///
  /// In fr, this message translates to:
  /// **'Lecture'**
  String get readerLayout;

  /// No description provided for @layoutScroll.
  ///
  /// In fr, this message translates to:
  /// **'Défilement'**
  String get layoutScroll;

  /// No description provided for @layoutPages.
  ///
  /// In fr, this message translates to:
  /// **'Pages'**
  String get layoutPages;

  /// No description provided for @layoutPagesHint.
  ///
  /// In fr, this message translates to:
  /// **'Touchez le bord droit ou gauche, ou balayez, pour tourner la page.'**
  String get layoutPagesHint;

  /// No description provided for @einkTitle.
  ///
  /// In fr, this message translates to:
  /// **'Liseuse (encre électronique)'**
  String get einkTitle;

  /// No description provided for @einkHint.
  ///
  /// In fr, this message translates to:
  /// **'Noir sur blanc, sans animations, lecture page par page et touches de page.'**
  String get einkHint;

  /// No description provided for @einkAuto.
  ///
  /// In fr, this message translates to:
  /// **'Automatique'**
  String get einkAuto;

  /// No description provided for @einkOn.
  ///
  /// In fr, this message translates to:
  /// **'Activé'**
  String get einkOn;

  /// No description provided for @einkOff.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get einkOff;

  /// No description provided for @einkDetected.
  ///
  /// In fr, this message translates to:
  /// **'Cet appareil est une liseuse.'**
  String get einkDetected;

  /// No description provided for @offlineReady.
  ///
  /// In fr, this message translates to:
  /// **'Disponible hors ligne sur cet appareil'**
  String get offlineReady;

  /// No description provided for @downloadOffline.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger pour lire hors ligne'**
  String get downloadOffline;

  /// No description provided for @friendAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get friendAdd;

  /// No description provided for @friendAccept.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get friendAccept;

  /// No description provided for @friendRequested.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée'**
  String get friendRequested;

  /// No description provided for @friendsWith.
  ///
  /// In fr, this message translates to:
  /// **'Amis ✓'**
  String get friendsWith;

  /// No description provided for @friendDecline.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get friendDecline;

  /// No description provided for @follow.
  ///
  /// In fr, this message translates to:
  /// **'Suivre'**
  String get follow;

  /// No description provided for @unfollow.
  ///
  /// In fr, this message translates to:
  /// **'Ne plus suivre'**
  String get unfollow;

  /// No description provided for @friendRemoveConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Retirer {name} de vos amis ?'**
  String friendRemoveConfirm(String name);

  /// No description provided for @friendRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get friendRemove;

  /// No description provided for @handleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre pseudo'**
  String get handleTitle;

  /// No description provided for @handleHint.
  ///
  /// In fr, this message translates to:
  /// **'Vos amis vous trouvent grâce à lui. Sans pseudo, personne ne peut vous trouver.'**
  String get handleHint;

  /// No description provided for @handleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pseudo'**
  String get handleLabel;

  /// No description provided for @handleRules.
  ///
  /// In fr, this message translates to:
  /// **'3 à 30 lettres, chiffres, points ou tirets bas'**
  String get handleRules;

  /// No description provided for @handleTaken.
  ///
  /// In fr, this message translates to:
  /// **'Ce pseudo est déjà pris.'**
  String get handleTaken;

  /// No description provided for @handleInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Pseudo invalide : 3 à 30 lettres, chiffres, points ou tirets bas.'**
  String get handleInvalid;

  /// No description provided for @readerSince.
  ///
  /// In fr, this message translates to:
  /// **'Membre depuis {year}'**
  String readerSince(int year);

  /// No description provided for @statBooks.
  ///
  /// In fr, this message translates to:
  /// **'Livres'**
  String get statBooks;

  /// No description provided for @statFriends.
  ///
  /// In fr, this message translates to:
  /// **'Amis'**
  String get statFriends;

  /// No description provided for @statFollowers.
  ///
  /// In fr, this message translates to:
  /// **'Abonnés'**
  String get statFollowers;

  /// No description provided for @friendsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Amis'**
  String get friendsTitle;

  /// No description provided for @seeAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout voir'**
  String get seeAll;

  /// No description provided for @searchReaders.
  ///
  /// In fr, this message translates to:
  /// **'Pseudo d\'un lecteur…'**
  String get searchReaders;

  /// No description provided for @noReaderFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun lecteur avec ce pseudo.'**
  String get noReaderFound;

  /// No description provided for @friendInvitesYou.
  ///
  /// In fr, this message translates to:
  /// **'Vous invite à devenir amis'**
  String get friendInvitesYou;

  /// No description provided for @noFriendsYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore d\'amis : cherchez le pseudo d\'un lecteur.'**
  String get noFriendsYet;

  /// No description provided for @friendReading.
  ///
  /// In fr, this message translates to:
  /// **'Lit {title} · {percent} %'**
  String friendReading(String title, int percent);

  /// No description provided for @seeMyFriends.
  ///
  /// In fr, this message translates to:
  /// **'Voir mes {count} amis'**
  String seeMyFriends(int count);

  /// No description provided for @friendRequests.
  ///
  /// In fr, this message translates to:
  /// **'Demandes reçues'**
  String get friendRequests;

  /// No description provided for @followingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Abonnements'**
  String get followingTitle;

  /// No description provided for @requestsSent.
  ///
  /// In fr, this message translates to:
  /// **'Demandes envoyées'**
  String get requestsSent;

  /// No description provided for @readerNotFoundSocial.
  ///
  /// In fr, this message translates to:
  /// **'Ce lecteur n\'existe pas.'**
  String get readerNotFoundSocial;

  /// No description provided for @followsYou.
  ///
  /// In fr, this message translates to:
  /// **'Vous suit'**
  String get followsYou;

  /// No description provided for @readingNow.
  ///
  /// In fr, this message translates to:
  /// **'En cours de lecture'**
  String get readingNow;

  /// No description provided for @reviewsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Avis'**
  String get reviewsTitle;

  /// No description provided for @sharedNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes partagées'**
  String get sharedNotes;

  /// No description provided for @comicPageNote.
  ///
  /// In fr, this message translates to:
  /// **'Note sur la page {page}'**
  String comicPageNote(int page);

  /// No description provided for @libraryTitleShared.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèque'**
  String get libraryTitleShared;

  /// No description provided for @nothingShared.
  ///
  /// In fr, this message translates to:
  /// **'Ce lecteur ne partage rien avec vous pour l\'instant.'**
  String get nothingShared;

  /// No description provided for @recommendationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Recommandé pour vous'**
  String get recommendationsTitle;

  /// No description provided for @feedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Activité'**
  String get feedTitle;

  /// No description provided for @feedEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Rien pour l\'instant : ajoutez des amis ou suivez des lecteurs.'**
  String get feedEmpty;

  /// No description provided for @feedReading.
  ///
  /// In fr, this message translates to:
  /// **'{name} lit {title}'**
  String feedReading(String name, String title);

  /// No description provided for @feedReview.
  ///
  /// In fr, this message translates to:
  /// **'{name} a donné son avis sur {title}'**
  String feedReview(String name, String title);

  /// No description provided for @feedNote.
  ///
  /// In fr, this message translates to:
  /// **'{name} a partagé une note de {title}'**
  String feedNote(String name, String title);

  /// No description provided for @recommendedBy.
  ///
  /// In fr, this message translates to:
  /// **'Recommandé par {name}'**
  String recommendedBy(String name);

  /// No description provided for @markRead.
  ///
  /// In fr, this message translates to:
  /// **'Vu'**
  String get markRead;

  /// No description provided for @audiencePrivate.
  ///
  /// In fr, this message translates to:
  /// **'Moi'**
  String get audiencePrivate;

  /// No description provided for @audienceFriends.
  ///
  /// In fr, this message translates to:
  /// **'Amis'**
  String get audienceFriends;

  /// No description provided for @audiencePublic.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get audiencePublic;

  /// No description provided for @shareReading.
  ///
  /// In fr, this message translates to:
  /// **'Qui voit ce que je lis'**
  String get shareReading;

  /// No description provided for @shareLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Qui voit ma bibliothèque'**
  String get shareLibrary;

  /// No description provided for @publicProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil public'**
  String get publicProfile;

  /// No description provided for @myReview.
  ///
  /// In fr, this message translates to:
  /// **'Mon avis'**
  String get myReview;

  /// No description provided for @ratingStars.
  ///
  /// In fr, this message translates to:
  /// **'{count} étoiles'**
  String ratingStars(int count);

  /// No description provided for @reviewHint.
  ///
  /// In fr, this message translates to:
  /// **'Ce que vous en avez pensé…'**
  String get reviewHint;

  /// No description provided for @whoSees.
  ///
  /// In fr, this message translates to:
  /// **'Qui le voit'**
  String get whoSees;

  /// No description provided for @reviewSaved.
  ///
  /// In fr, this message translates to:
  /// **'Avis enregistré.'**
  String get reviewSaved;

  /// No description provided for @reviewDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon avis'**
  String get reviewDelete;

  /// No description provided for @recommendTitle.
  ///
  /// In fr, this message translates to:
  /// **'Recommander'**
  String get recommendTitle;

  /// No description provided for @recommendAction.
  ///
  /// In fr, this message translates to:
  /// **'Recommander'**
  String get recommendAction;

  /// No description provided for @recommendNoFriends.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez d\'abord des amis pour leur recommander des livres.'**
  String get recommendNoFriends;

  /// No description provided for @recommendMessage.
  ///
  /// In fr, this message translates to:
  /// **'Un mot pour votre ami (facultatif)'**
  String get recommendMessage;

  /// No description provided for @recommendSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get recommendSend;

  /// No description provided for @recommendationSent.
  ///
  /// In fr, this message translates to:
  /// **'Recommandation envoyée.'**
  String get recommendationSent;

  /// No description provided for @comicPage.
  ///
  /// In fr, this message translates to:
  /// **'Page {page}'**
  String comicPage(int page);

  /// No description provided for @comicDirection.
  ///
  /// In fr, this message translates to:
  /// **'Sens de lecture'**
  String get comicDirection;

  /// No description provided for @directionLtr.
  ///
  /// In fr, this message translates to:
  /// **'Gauche → droite (BD)'**
  String get directionLtr;

  /// No description provided for @directionRtl.
  ///
  /// In fr, this message translates to:
  /// **'Droite → gauche (manga)'**
  String get directionRtl;

  /// No description provided for @directionVertical.
  ///
  /// In fr, this message translates to:
  /// **'Vertical (webtoon)'**
  String get directionVertical;

  /// No description provided for @comicAnnotate.
  ///
  /// In fr, this message translates to:
  /// **'Annoter une case'**
  String get comicAnnotate;

  /// No description provided for @comicAnnotateHint.
  ///
  /// In fr, this message translates to:
  /// **'Tracez un cadre autour de la case à annoter.'**
  String get comicAnnotateHint;

  /// No description provided for @kavitaTitle.
  ///
  /// In fr, this message translates to:
  /// **'Kavita'**
  String get kavitaTitle;

  /// No description provided for @kavitaCreating.
  ///
  /// In fr, this message translates to:
  /// **'Création de votre accès Kavita…'**
  String get kavitaCreating;

  /// No description provided for @kavitaFollow.
  ///
  /// In fr, this message translates to:
  /// **'Suivre'**
  String get kavitaFollow;

  /// No description provided for @kavitaExists.
  ///
  /// In fr, this message translates to:
  /// **'Un compte Kavita existe déjà avec votre e-mail sur {host} : liez-le avec son identifiant et son mot de passe.'**
  String kavitaExists(String host);

  /// No description provided for @kavitaFailed.
  ///
  /// In fr, this message translates to:
  /// **'La création de votre accès Kavita n\'a pas abouti.'**
  String get kavitaFailed;

  /// No description provided for @kavitaLinked.
  ///
  /// In fr, this message translates to:
  /// **'Lié à {host} · compte {username}'**
  String kavitaLinked(String host, String username);

  /// No description provided for @kavitaManaged.
  ///
  /// In fr, this message translates to:
  /// **'Compte créé pour vous par Babel, avec accès à toutes les bibliothèques.'**
  String get kavitaManaged;

  /// No description provided for @kavitaUnlink.
  ///
  /// In fr, this message translates to:
  /// **'Délier'**
  String get kavitaUnlink;

  /// No description provided for @kavitaUnlinkConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Délier votre Kavita ? Les livres déjà importés restent dans votre bibliothèque.'**
  String get kavitaUnlinkConfirm;

  /// No description provided for @kavitaUnlinkManaged.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'accès Kavita créé par Babel ? Les livres déjà importés restent dans votre bibliothèque.'**
  String get kavitaUnlinkManaged;

  /// No description provided for @kavitaHint.
  ///
  /// In fr, this message translates to:
  /// **'Vos bibliothèques Kavita dans Babel. Le mot de passe sert une seule fois à créer une clé « Babel » sur votre compte, il n\'est pas conservé.'**
  String get kavitaHint;

  /// No description provided for @kavitaUrl.
  ///
  /// In fr, this message translates to:
  /// **'Adresse de votre Kavita'**
  String get kavitaUrl;

  /// No description provided for @kavitaUsername.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant Kavita'**
  String get kavitaUsername;

  /// No description provided for @kavitaPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe Kavita'**
  String get kavitaPassword;

  /// No description provided for @kavitaPasswordHelp.
  ///
  /// In fr, this message translates to:
  /// **'Utilisé une seule fois, jamais enregistré.'**
  String get kavitaPasswordHelp;

  /// No description provided for @kavitaWrongCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant ou mot de passe Kavita incorrect.'**
  String get kavitaWrongCredentials;

  /// No description provided for @kavitaNotKavita.
  ///
  /// In fr, this message translates to:
  /// **'Cette adresse ne répond pas comme un serveur Kavita.'**
  String get kavitaNotKavita;

  /// No description provided for @kavitaUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Kavita n\'a pas pu être joint.'**
  String get kavitaUnreachable;

  /// No description provided for @kavitaLink.
  ///
  /// In fr, this message translates to:
  /// **'Lier mon Kavita'**
  String get kavitaLink;

  /// No description provided for @kavitaCreateMine.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon accès sur le Kavita de Babel'**
  String get kavitaCreateMine;

  /// No description provided for @kavitaSetupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre accès Kavita'**
  String get kavitaSetupTitle;

  /// No description provided for @kavitaSetupHint.
  ///
  /// In fr, this message translates to:
  /// **'Babel crée votre compte sur {host} et y relie votre bibliothèque. Vous pouvez quitter cette page.'**
  String kavitaSetupHint(String host);

  /// No description provided for @kavitaStepCreating.
  ///
  /// In fr, this message translates to:
  /// **'Création du compte'**
  String get kavitaStepCreating;

  /// No description provided for @kavitaStepLinking.
  ///
  /// In fr, this message translates to:
  /// **'Création de la clé Babel'**
  String get kavitaStepLinking;

  /// No description provided for @kavitaStepImporting.
  ///
  /// In fr, this message translates to:
  /// **'Lecture du catalogue'**
  String get kavitaStepImporting;

  /// No description provided for @kavitaStepReady.
  ///
  /// In fr, this message translates to:
  /// **'Prêt'**
  String get kavitaStepReady;

  /// No description provided for @kavitaOpenLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Voir mes sources'**
  String get kavitaOpenLibrary;

  /// No description provided for @kavitaWait.
  ///
  /// In fr, this message translates to:
  /// **'Quelques secondes suffisent en général.'**
  String get kavitaWait;

  /// No description provided for @adminTitle.
  ///
  /// In fr, this message translates to:
  /// **'Administration'**
  String get adminTitle;

  /// No description provided for @adminPremiumHint.
  ///
  /// In fr, this message translates to:
  /// **'Comptes premium : accès au Kavita de Babel, créé automatiquement.'**
  String get adminPremiumHint;

  /// No description provided for @adminRole.
  ///
  /// In fr, this message translates to:
  /// **'Admin'**
  String get adminRole;

  /// No description provided for @adminKavitaReady.
  ///
  /// In fr, this message translates to:
  /// **'Kavita prêt'**
  String get adminKavitaReady;

  /// No description provided for @adminKavitaFailed.
  ///
  /// In fr, this message translates to:
  /// **'Kavita en échec'**
  String get adminKavitaFailed;

  /// No description provided for @adminKavitaExists.
  ///
  /// In fr, this message translates to:
  /// **'Kavita existant'**
  String get adminKavitaExists;

  /// No description provided for @adminKavitaCreating.
  ///
  /// In fr, this message translates to:
  /// **'Kavita en cours'**
  String get adminKavitaCreating;

  /// No description provided for @moreActions.
  ///
  /// In fr, this message translates to:
  /// **'Plus d\'actions'**
  String get moreActions;

  /// No description provided for @blockReader.
  ///
  /// In fr, this message translates to:
  /// **'Bloquer'**
  String get blockReader;

  /// No description provided for @reportReader.
  ///
  /// In fr, this message translates to:
  /// **'Signaler'**
  String get reportReader;

  /// No description provided for @blockConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Bloquer {name} ? Vous ne serez plus amis ni abonnés, et aucun de vous deux ne verra l\'autre.'**
  String blockConfirm(String name);

  /// No description provided for @blocked.
  ///
  /// In fr, this message translates to:
  /// **'{name} est bloqué.'**
  String blocked(String name);

  /// No description provided for @reportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signaler {name}'**
  String reportTitle(String name);

  /// No description provided for @reportHint.
  ///
  /// In fr, this message translates to:
  /// **'Les administrateurs de Babel examineront le signalement. Ce lecteur n\'est pas prévenu.'**
  String get reportHint;

  /// No description provided for @reasonSpam.
  ///
  /// In fr, this message translates to:
  /// **'Spam'**
  String get reasonSpam;

  /// No description provided for @reasonHarassment.
  ///
  /// In fr, this message translates to:
  /// **'Harcèlement'**
  String get reasonHarassment;

  /// No description provided for @reasonInappropriate.
  ///
  /// In fr, this message translates to:
  /// **'Contenu inapproprié'**
  String get reasonInappropriate;

  /// No description provided for @reasonOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get reasonOther;

  /// No description provided for @reportNote.
  ///
  /// In fr, this message translates to:
  /// **'Ce qui s\'est passé (facultatif)'**
  String get reportNote;

  /// No description provided for @reportSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le signalement'**
  String get reportSend;

  /// No description provided for @reportSent.
  ///
  /// In fr, this message translates to:
  /// **'Signalement envoyé.'**
  String get reportSent;

  /// No description provided for @blockedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bloqués'**
  String get blockedTitle;

  /// No description provided for @unblock.
  ///
  /// In fr, this message translates to:
  /// **'Débloquer'**
  String get unblock;

  /// No description provided for @reportsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signalements'**
  String get reportsTitle;

  /// No description provided for @reportsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun signalement.'**
  String get reportsEmpty;

  /// No description provided for @reportedBy.
  ///
  /// In fr, this message translates to:
  /// **'Signalé par @{handle}'**
  String reportedBy(String handle);

  /// No description provided for @reportResolve.
  ///
  /// In fr, this message translates to:
  /// **'Traité'**
  String get reportResolve;

  /// No description provided for @statusToRead.
  ///
  /// In fr, this message translates to:
  /// **'À lire'**
  String get statusToRead;

  /// No description provided for @statusReading.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get statusReading;

  /// No description provided for @statusFinished.
  ///
  /// In fr, this message translates to:
  /// **'Lu'**
  String get statusFinished;

  /// No description provided for @statusAbandoned.
  ///
  /// In fr, this message translates to:
  /// **'Abandonné'**
  String get statusAbandoned;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get filterAll;

  /// No description provided for @showHidden.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les livres masqués'**
  String get showHidden;

  /// No description provided for @hiddenBadge.
  ///
  /// In fr, this message translates to:
  /// **'Masqué'**
  String get hiddenBadge;

  /// No description provided for @hideBook.
  ///
  /// In fr, this message translates to:
  /// **'Masquer de la bibliothèque'**
  String get hideBook;

  /// No description provided for @unhideBook.
  ///
  /// In fr, this message translates to:
  /// **'Ne plus masquer'**
  String get unhideBook;

  /// No description provided for @bookHidden.
  ///
  /// In fr, this message translates to:
  /// **'« {title} » est masqué. Retrouvez-le avec « Afficher les livres masqués ».'**
  String bookHidden(String title);

  /// No description provided for @removeKeepsData.
  ///
  /// In fr, this message translates to:
  /// **'Vos notes, votre avis et votre progression sont gardés : en remettant ce livre, vous les retrouvez.'**
  String get removeKeepsData;

  /// No description provided for @progressTitle.
  ///
  /// In fr, this message translates to:
  /// **'Progression'**
  String get progressTitle;

  /// No description provided for @progressHint.
  ///
  /// In fr, this message translates to:
  /// **'Pour un livre lu ailleurs (papier, autre appli).'**
  String get progressHint;

  /// No description provided for @progressPercent.
  ///
  /// In fr, this message translates to:
  /// **'{percent} %'**
  String progressPercent(int percent);

  /// No description provided for @shelvesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Étagères'**
  String get shelvesTitle;

  /// No description provided for @shelfNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle étagère'**
  String get shelfNew;

  /// No description provided for @shelfName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'étagère'**
  String get shelfName;

  /// No description provided for @shelfRename.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get shelfRename;

  /// No description provided for @shelfDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'étagère'**
  String get shelfDelete;

  /// No description provided for @shelfDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'Les livres restent dans votre bibliothèque.'**
  String get shelfDeleteBody;

  /// No description provided for @shelfEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livre sur cette étagère pour l\'instant.'**
  String get shelfEmpty;

  /// No description provided for @shelfBooks.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Vide} =1{1 livre} other{{count} livres}}'**
  String shelfBooks(int count);

  /// No description provided for @create.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get create;

  /// No description provided for @traceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vous et ce livre'**
  String get traceTitle;

  /// No description provided for @traceInLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Dans votre bibliothèque'**
  String get traceInLibrary;

  /// No description provided for @traceRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Retiré de votre bibliothèque le {date}'**
  String traceRemoved(String date);

  /// No description provided for @traceGone.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier n\'est plus disponible ; vos données sont gardées.'**
  String get traceGone;

  /// No description provided for @traceNotes.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune note} =1{1 note ou surlignage} other{{count} notes et surlignages}}'**
  String traceNotes(int count);

  /// No description provided for @traceRestore.
  ///
  /// In fr, this message translates to:
  /// **'Remettre dans ma bibliothèque'**
  String get traceRestore;

  /// No description provided for @traceRestored.
  ///
  /// In fr, this message translates to:
  /// **'« {title} » est de retour, avec vos notes.'**
  String traceRestored(String title);

  /// No description provided for @traceFinishedOn.
  ///
  /// In fr, this message translates to:
  /// **'Lu le {date}'**
  String traceFinishedOn(String date);

  /// No description provided for @yourBooks.
  ///
  /// In fr, this message translates to:
  /// **'Dans vos livres'**
  String get yourBooks;

  /// No description provided for @workReaders.
  ///
  /// In fr, this message translates to:
  /// **'Les lecteurs'**
  String get workReaders;

  /// No description provided for @workReadersEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore d\'avis ni de note sur ce livre.'**
  String get workReadersEmpty;

  /// No description provided for @workRating.
  ///
  /// In fr, this message translates to:
  /// **'{rating} sur 5 · {count, plural, =1{1 avis} other{{count} avis}}'**
  String workRating(String rating, int count);

  /// No description provided for @workAllEditions.
  ///
  /// In fr, this message translates to:
  /// **'Toutes éditions confondues'**
  String get workAllEditions;

  /// No description provided for @you.
  ///
  /// In fr, this message translates to:
  /// **'Vous'**
  String get you;

  /// No description provided for @linkWork.
  ///
  /// In fr, this message translates to:
  /// **'Associer à une fiche'**
  String get linkWork;

  /// No description provided for @linkWorkHint.
  ///
  /// In fr, this message translates to:
  /// **'Avis et notes sont partagés entre toutes les éditions d\'un même livre : choisissez la fiche qui correspond.'**
  String get linkWorkHint;

  /// No description provided for @linkWorkNone.
  ///
  /// In fr, this message translates to:
  /// **'Ce n\'est aucun de ces livres'**
  String get linkWorkNone;

  /// No description provided for @feedFinished.
  ///
  /// In fr, this message translates to:
  /// **'{name} a terminé {title}'**
  String feedFinished(String name, String title);

  /// No description provided for @profileFinished.
  ///
  /// In fr, this message translates to:
  /// **'Lus récemment'**
  String get profileFinished;

  /// No description provided for @shelfManage.
  ///
  /// In fr, this message translates to:
  /// **'Gérer l\'étagère'**
  String get shelfManage;

  /// No description provided for @tabReading.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get tabReading;

  /// No description provided for @tabToRead.
  ///
  /// In fr, this message translates to:
  /// **'À lire'**
  String get tabToRead;

  /// No description provided for @tabFinished.
  ///
  /// In fr, this message translates to:
  /// **'Lus'**
  String get tabFinished;

  /// No description provided for @tabAbandoned.
  ///
  /// In fr, this message translates to:
  /// **'Abandonnés'**
  String get tabAbandoned;

  /// No description provided for @shelfFilter.
  ///
  /// In fr, this message translates to:
  /// **'Étagère · {name}'**
  String shelfFilter(String name);

  /// No description provided for @showAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout afficher'**
  String get showAll;

  /// No description provided for @progressElsewhere.
  ///
  /// In fr, this message translates to:
  /// **'Lu ailleurs ? Indiquer ma progression'**
  String get progressElsewhere;

  /// No description provided for @progressAsk.
  ///
  /// In fr, this message translates to:
  /// **'Où en êtes-vous ?'**
  String get progressAsk;

  /// No description provided for @progressAskHint.
  ///
  /// In fr, this message translates to:
  /// **'Pourcentage du livre (0 à 100)'**
  String get progressAskHint;

  /// No description provided for @readerNotesSetting.
  ///
  /// In fr, this message translates to:
  /// **'Notes des autres lecteurs'**
  String get readerNotesSetting;

  /// No description provided for @readerNotesSettingHint.
  ///
  /// In fr, this message translates to:
  /// **'Les passages qu\'ils ont annotés, retrouvés dans votre édition.'**
  String get readerNotesSettingHint;

  /// No description provided for @marginOthers.
  ///
  /// In fr, this message translates to:
  /// **'Les autres lecteurs'**
  String get marginOthers;

  /// No description provided for @notePlaceNear.
  ///
  /// In fr, this message translates to:
  /// **'≈ {percent} % du livre'**
  String notePlaceNear(int percent);

  /// No description provided for @noteNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Passage introuvable dans votre édition'**
  String get noteNotFound;

  /// No description provided for @noteOtherEdition.
  ///
  /// In fr, this message translates to:
  /// **'Autre édition'**
  String get noteOtherEdition;

  /// No description provided for @noteEditionLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Édition {language}'**
  String noteEditionLanguage(String language);

  /// No description provided for @noteBy.
  ///
  /// In fr, this message translates to:
  /// **'Note de {name}'**
  String noteBy(String name);

  /// No description provided for @goThere.
  ///
  /// In fr, this message translates to:
  /// **'Y aller'**
  String get goThere;

  /// No description provided for @statsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon année de lecture'**
  String get statsTitle;

  /// No description provided for @statsBooksRead.
  ///
  /// In fr, this message translates to:
  /// **'Livres lus'**
  String get statsBooksRead;

  /// No description provided for @statsReadingDays.
  ///
  /// In fr, this message translates to:
  /// **'Jours de lecture'**
  String get statsReadingDays;

  /// No description provided for @statsLongestStreak.
  ///
  /// In fr, this message translates to:
  /// **'Plus longue série'**
  String get statsLongestStreak;

  /// No description provided for @statsNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get statsNotes;

  /// No description provided for @statsByMonth.
  ///
  /// In fr, this message translates to:
  /// **'Mois par mois'**
  String get statsByMonth;

  /// No description provided for @statsTopAuthors.
  ///
  /// In fr, this message translates to:
  /// **'Vos auteurs'**
  String get statsTopAuthors;

  /// No description provided for @statsBooksList.
  ///
  /// In fr, this message translates to:
  /// **'Vos lectures'**
  String get statsBooksList;

  /// No description provided for @statsCurrentStreak.
  ///
  /// In fr, this message translates to:
  /// **'Série en cours : {days}'**
  String statsCurrentStreak(String days);

  /// No description provided for @statsDays.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 jour} other{{count} jours}}'**
  String statsDays(int count);

  /// No description provided for @statsFinished.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun livre lu} =1{1 livre lu} other{{count} livres lus}}'**
  String statsFinished(int count);

  /// No description provided for @statsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Rien encore cette année : vos livres terminés apparaîtront ici.'**
  String get statsEmpty;

  /// No description provided for @statsOpenWrap.
  ///
  /// In fr, this message translates to:
  /// **'Voir mon récap {year}'**
  String statsOpenWrap(String year);

  /// No description provided for @statsAverage.
  ///
  /// In fr, this message translates to:
  /// **'Note moyenne {rating} / 5'**
  String statsAverage(String rating);

  /// No description provided for @statsAbandoned.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{} =1{1 abandonné} other{{count} abandonnés}}'**
  String statsAbandoned(int count);

  /// No description provided for @wrapIntro.
  ///
  /// In fr, this message translates to:
  /// **'{year} en livres'**
  String wrapIntro(String year);

  /// No description provided for @wrapIntroSub.
  ///
  /// In fr, this message translates to:
  /// **'Votre année de lecture, en quelques pages.'**
  String get wrapIntroSub;

  /// No description provided for @wrapFinished.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{livre terminé} other{livres terminés}}'**
  String wrapFinished(int count);

  /// No description provided for @wrapDays.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{jour passé à lire} other{jours passés à lire}}'**
  String wrapDays(int count);

  /// No description provided for @wrapStreak.
  ///
  /// In fr, this message translates to:
  /// **'Votre plus longue série : {days} d\'affilée.'**
  String wrapStreak(String days);

  /// No description provided for @wrapBestMonth.
  ///
  /// In fr, this message translates to:
  /// **'Votre mois le plus lu'**
  String get wrapBestMonth;

  /// No description provided for @wrapAuthor.
  ///
  /// In fr, this message translates to:
  /// **'Votre auteur·rice de l\'année'**
  String get wrapAuthor;

  /// No description provided for @wrapNotes.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Pas de note cette année} =1{note ou surlignage} other{notes et surlignages}}'**
  String wrapNotes(int count);

  /// No description provided for @wrapOutro.
  ///
  /// In fr, this message translates to:
  /// **'À l\'année prochaine'**
  String get wrapOutro;

  /// No description provided for @wrapOutroSub.
  ///
  /// In fr, this message translates to:
  /// **'Merci d\'avoir lu avec Babel.'**
  String get wrapOutroSub;

  /// No description provided for @wrapTapHint.
  ///
  /// In fr, this message translates to:
  /// **'Touchez pour continuer'**
  String get wrapTapHint;

  /// No description provided for @paperBook.
  ///
  /// In fr, this message translates to:
  /// **'Papier'**
  String get paperBook;

  /// No description provided for @paperOwned.
  ///
  /// In fr, this message translates to:
  /// **'Je l\'ai en papier'**
  String get paperOwned;

  /// No description provided for @paperOwnedHint.
  ///
  /// In fr, this message translates to:
  /// **'Suivez votre lecture sans fichier : statut, progression, notes et avis.'**
  String get paperOwnedHint;

  /// No description provided for @paperAdded.
  ///
  /// In fr, this message translates to:
  /// **'« {title} » est dans votre bibliothèque, en papier.'**
  String paperAdded(String title);

  /// No description provided for @attachFile.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter le fichier'**
  String get attachFile;

  /// No description provided for @attachFileHint.
  ///
  /// In fr, this message translates to:
  /// **'Pour lire aussi sur cet appareil : statut, progression, avis et notes restent ceux du livre.'**
  String get attachFileHint;

  /// No description provided for @paperNoFile.
  ///
  /// In fr, this message translates to:
  /// **'Livre papier : ajoutez son fichier pour le lire aussi ici.'**
  String get paperNoFile;

  /// No description provided for @attachConflict.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier est déjà un autre livre de votre bibliothèque.'**
  String get attachConflict;

  /// No description provided for @attached.
  ///
  /// In fr, this message translates to:
  /// **'Fichier ajouté : « {title} » se lit aussi ici.'**
  String attached(String title);

  /// No description provided for @genreFanfiction.
  ///
  /// In fr, this message translates to:
  /// **'fanfiction'**
  String get genreFanfiction;

  /// No description provided for @genreComics.
  ///
  /// In fr, this message translates to:
  /// **'BD'**
  String get genreComics;

  /// No description provided for @genreManga.
  ///
  /// In fr, this message translates to:
  /// **'manga'**
  String get genreManga;

  /// No description provided for @genreScienceFiction.
  ///
  /// In fr, this message translates to:
  /// **'science-fiction'**
  String get genreScienceFiction;

  /// No description provided for @genreFantasy.
  ///
  /// In fr, this message translates to:
  /// **'fantasy'**
  String get genreFantasy;

  /// No description provided for @genreHorror.
  ///
  /// In fr, this message translates to:
  /// **'horreur'**
  String get genreHorror;

  /// No description provided for @genreMystery.
  ///
  /// In fr, this message translates to:
  /// **'polar'**
  String get genreMystery;

  /// No description provided for @genreRomance.
  ///
  /// In fr, this message translates to:
  /// **'romance'**
  String get genreRomance;

  /// No description provided for @genreHistorical.
  ///
  /// In fr, this message translates to:
  /// **'roman historique'**
  String get genreHistorical;

  /// No description provided for @genreYoung.
  ///
  /// In fr, this message translates to:
  /// **'jeunesse'**
  String get genreYoung;

  /// No description provided for @genrePoetry.
  ///
  /// In fr, this message translates to:
  /// **'poésie'**
  String get genrePoetry;

  /// No description provided for @genreTheatre.
  ///
  /// In fr, this message translates to:
  /// **'théâtre'**
  String get genreTheatre;

  /// No description provided for @genreBiography.
  ///
  /// In fr, this message translates to:
  /// **'biographie'**
  String get genreBiography;

  /// No description provided for @genrePhilosophy.
  ///
  /// In fr, this message translates to:
  /// **'philosophie'**
  String get genrePhilosophy;

  /// No description provided for @genreNonfiction.
  ///
  /// In fr, this message translates to:
  /// **'essais et documents'**
  String get genreNonfiction;

  /// No description provided for @genreLiterary.
  ///
  /// In fr, this message translates to:
  /// **'littérature'**
  String get genreLiterary;

  /// No description provided for @statsGenres.
  ///
  /// In fr, this message translates to:
  /// **'Vos genres'**
  String get statsGenres;

  /// No description provided for @wrapGenres.
  ///
  /// In fr, this message translates to:
  /// **'Vos genres favoris'**
  String get wrapGenres;

  /// No description provided for @genreDominant.
  ///
  /// In fr, this message translates to:
  /// **'Une année résolument {genre} : {percent} % de vos lectures.'**
  String genreDominant(String genre, int percent);

  /// No description provided for @genreTie.
  ///
  /// In fr, this message translates to:
  /// **'Entre {first} et {second}, votre cœur a balancé.'**
  String genreTie(String first, String second);

  /// No description provided for @genreLead.
  ///
  /// In fr, this message translates to:
  /// **'Votre genre de l\'année : {first}, devant {second}.'**
  String genreLead(String first, String second);

  /// No description provided for @genreOnly.
  ///
  /// In fr, this message translates to:
  /// **'Votre genre de l\'année : {genre}.'**
  String genreOnly(String genre);

  /// No description provided for @genreEclectic.
  ///
  /// In fr, this message translates to:
  /// **'{count} genres explorés : une année éclectique.'**
  String genreEclectic(int count);

  /// No description provided for @genreFaithful.
  ///
  /// In fr, this message translates to:
  /// **'Un seul genre : fidèle à vos amours.'**
  String get genreFaithful;

  /// No description provided for @genreSome.
  ///
  /// In fr, this message translates to:
  /// **'{count} genres au compteur.'**
  String genreSome(int count);

  /// No description provided for @genreNewLead.
  ///
  /// In fr, this message translates to:
  /// **'Changement de cap : {genre} prend la tête, l\'an dernier c\'était {previous}.'**
  String genreNewLead(String genre, String previous);

  /// No description provided for @genreSameLead.
  ///
  /// In fr, this message translates to:
  /// **'Fidèle à {genre}, comme l\'an dernier.'**
  String genreSameLead(String genre);

  /// No description provided for @genreFirstTime.
  ///
  /// In fr, this message translates to:
  /// **'Première incursion cette année : {genre}.'**
  String genreFirstTime(String genre);

  /// No description provided for @absTitle.
  ///
  /// In fr, this message translates to:
  /// **'Audiobookshelf'**
  String get absTitle;

  /// No description provided for @absIntro.
  ///
  /// In fr, this message translates to:
  /// **'Liez votre Audiobookshelf pour écouter vos livres audio dans Babel, avec statut, étagères et statistiques comme vos livres.'**
  String get absIntro;

  /// No description provided for @absUrl.
  ///
  /// In fr, this message translates to:
  /// **'Adresse d\'Audiobookshelf'**
  String get absUrl;

  /// No description provided for @absApiKey.
  ///
  /// In fr, this message translates to:
  /// **'Clé d\'API'**
  String get absApiKey;

  /// No description provided for @absApiKeyHelp.
  ///
  /// In fr, this message translates to:
  /// **'Créée dans Audiobookshelf : Paramètres › Clés d\'API. Recommandé : elle n\'expire pas.'**
  String get absApiKeyHelp;

  /// No description provided for @absUsePassword.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser mon identifiant à la place'**
  String get absUsePassword;

  /// No description provided for @absUseKey.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser une clé d\'API'**
  String get absUseKey;

  /// No description provided for @absUsername.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant'**
  String get absUsername;

  /// No description provided for @absPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get absPassword;

  /// No description provided for @absPasswordHelp.
  ///
  /// In fr, this message translates to:
  /// **'Utilisé une seule fois : Babel ne le garde pas.'**
  String get absPasswordHelp;

  /// No description provided for @absLink.
  ///
  /// In fr, this message translates to:
  /// **'Lier'**
  String get absLink;

  /// No description provided for @absLinked.
  ///
  /// In fr, this message translates to:
  /// **'Lié à {host} · {user}'**
  String absLinked(String host, String user);

  /// No description provided for @absExpired.
  ///
  /// In fr, this message translates to:
  /// **'Audiobookshelf refuse désormais l\'accès de Babel : liez-le à nouveau.'**
  String get absExpired;

  /// No description provided for @absUnlink.
  ///
  /// In fr, this message translates to:
  /// **'Délier'**
  String get absUnlink;

  /// No description provided for @absBrowse.
  ///
  /// In fr, this message translates to:
  /// **'Parcourir mes livres audio'**
  String get absBrowse;

  /// No description provided for @absErrorUnauthorized.
  ///
  /// In fr, this message translates to:
  /// **'Identifiants refusés par Audiobookshelf.'**
  String get absErrorUnauthorized;

  /// No description provided for @absErrorUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Audiobookshelf ne répond pas à cette adresse.'**
  String get absErrorUnreachable;

  /// No description provided for @absErrorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Audiobookshelf n\'a pas pu être lié.'**
  String get absErrorGeneric;

  /// No description provided for @audiobooksTitle.
  ///
  /// In fr, this message translates to:
  /// **'Livres audio'**
  String get audiobooksTitle;

  /// No description provided for @audiobooksSearch.
  ///
  /// In fr, this message translates to:
  /// **'Chercher un livre audio'**
  String get audiobooksSearch;

  /// No description provided for @audiobookAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get audiobookAdd;

  /// No description provided for @audiobookInLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Dans votre bibliothèque'**
  String get audiobookInLibrary;

  /// No description provided for @audiobookAdded.
  ///
  /// In fr, this message translates to:
  /// **'« {title} » est dans votre bibliothèque.'**
  String audiobookAdded(String title);

  /// No description provided for @audiobooksEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livre audio ici.'**
  String get audiobooksEmpty;

  /// No description provided for @audiobooksNotLinked.
  ///
  /// In fr, this message translates to:
  /// **'Pour ajouter des livres audio, liez d\'abord votre Audiobookshelf : son adresse et une clé d\'API (Audiobookshelf, Réglages, Utilisateurs). Ensuite, ses bibliothèques s\'affichent ici et chaque livre s\'ajoute à votre bibliothèque d\'un appui.'**
  String get audiobooksNotLinked;

  /// No description provided for @narratedBy.
  ///
  /// In fr, this message translates to:
  /// **'Lu par {names}'**
  String narratedBy(String names);

  /// No description provided for @listen.
  ///
  /// In fr, this message translates to:
  /// **'Écouter'**
  String get listen;

  /// No description provided for @audioBadge.
  ///
  /// In fr, this message translates to:
  /// **'Audio'**
  String get audioBadge;

  /// No description provided for @playerChapters.
  ///
  /// In fr, this message translates to:
  /// **'Chapitres'**
  String get playerChapters;

  /// No description provided for @playerSpeed.
  ///
  /// In fr, this message translates to:
  /// **'Vitesse'**
  String get playerSpeed;

  /// No description provided for @playerSleep.
  ///
  /// In fr, this message translates to:
  /// **'Minuterie'**
  String get playerSleep;

  /// No description provided for @sleepOff.
  ///
  /// In fr, this message translates to:
  /// **'Désactivée'**
  String get sleepOff;

  /// No description provided for @sleepMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{minutes} min'**
  String sleepMinutes(int minutes);

  /// No description provided for @sleepEndOfChapter.
  ///
  /// In fr, this message translates to:
  /// **'Fin du chapitre'**
  String get sleepEndOfChapter;

  /// No description provided for @sleepLeft.
  ///
  /// In fr, this message translates to:
  /// **'Arrêt dans {time}'**
  String sleepLeft(String time);

  /// No description provided for @playerBack30.
  ///
  /// In fr, this message translates to:
  /// **'Reculer de 30 s'**
  String get playerBack30;

  /// No description provided for @playerForward30.
  ///
  /// In fr, this message translates to:
  /// **'Avancer de 30 s'**
  String get playerForward30;

  /// No description provided for @playerPlay.
  ///
  /// In fr, this message translates to:
  /// **'Lecture'**
  String get playerPlay;

  /// No description provided for @playerPause.
  ///
  /// In fr, this message translates to:
  /// **'Pause'**
  String get playerPause;

  /// No description provided for @playerError.
  ///
  /// In fr, this message translates to:
  /// **'Lecture impossible : vérifiez votre connexion ou votre Audiobookshelf.'**
  String get playerError;

  /// No description provided for @workCovers.
  ///
  /// In fr, this message translates to:
  /// **'Couvertures'**
  String get workCovers;

  /// No description provided for @coversCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 couverture} other{{count} couvertures}}'**
  String coversCount(int count);

  /// No description provided for @coverUse.
  ///
  /// In fr, this message translates to:
  /// **'Voir cette couverture'**
  String get coverUse;

  /// No description provided for @searchClear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer la recherche'**
  String get searchClear;

  /// No description provided for @recentRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer de l\'historique'**
  String get recentRemove;

  /// No description provided for @inMySources.
  ///
  /// In fr, this message translates to:
  /// **'Dans mes sources'**
  String get inMySources;

  /// No description provided for @inMySourcesHint.
  ///
  /// In fr, this message translates to:
  /// **'Des livres de vos sources (Kavita, WebDAV, GitHub…) correspondent à cette œuvre.'**
  String get inMySourcesHint;

  /// No description provided for @noSourceMatch.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livre de vos sources ne correspond.'**
  String get noSourceMatch;

  /// No description provided for @manageSources.
  ///
  /// In fr, this message translates to:
  /// **'Gérer mes sources'**
  String get manageSources;

  /// No description provided for @addToLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter à la bibliothèque'**
  String get addToLibrary;

  /// No description provided for @sourceMatchImported.
  ///
  /// In fr, this message translates to:
  /// **'« {title} » est dans votre bibliothèque.'**
  String sourceMatchImported(String title);

  /// No description provided for @editDetails.
  ///
  /// In fr, this message translates to:
  /// **'Modifier les informations'**
  String get editDetails;

  /// No description provided for @detailsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Informations du livre'**
  String get detailsTitle;

  /// No description provided for @detailsBookTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get detailsBookTitle;

  /// No description provided for @detailsAuthors.
  ///
  /// In fr, this message translates to:
  /// **'Auteurs, séparés par des virgules'**
  String get detailsAuthors;

  /// No description provided for @detailsSeries.
  ///
  /// In fr, this message translates to:
  /// **'Série'**
  String get detailsSeries;

  /// No description provided for @detailsSeriesHint.
  ///
  /// In fr, this message translates to:
  /// **'Laissez vide si ce livre n\'est pas dans une série.'**
  String get detailsSeriesHint;

  /// No description provided for @detailsVolume.
  ///
  /// In fr, this message translates to:
  /// **'Tome'**
  String get detailsVolume;

  /// No description provided for @detailsCover.
  ///
  /// In fr, this message translates to:
  /// **'Couverture'**
  String get detailsCover;

  /// No description provided for @coverUpload.
  ///
  /// In fr, this message translates to:
  /// **'Importer ma propre image'**
  String get coverUpload;

  /// No description provided for @coverInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Image invalide (JPEG, PNG ou WebP, 5 Mo maximum).'**
  String get coverInvalid;

  /// No description provided for @requestAnyLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Toutes langues'**
  String get requestAnyLanguage;

  /// No description provided for @searchSagaVolumes.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{# tome} other{# tomes}}'**
  String searchSagaVolumes(int count);

  /// No description provided for @requestNoRelease.
  ///
  /// In fr, this message translates to:
  /// **'Demandé, mais aucune version à télécharger n\'a été trouvée pour l\'instant. La recherche continue en arrière-plan.'**
  String get requestNoRelease;

  /// No description provided for @requestShelfmark.
  ///
  /// In fr, this message translates to:
  /// **'Envoyé à Shelfmark : le livre apparaîtra dans « Dans mes sources » dès qu\'il sera arrivé.'**
  String get requestShelfmark;

  /// No description provided for @requestCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la demande'**
  String get requestCancel;

  /// No description provided for @shelfmarkTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon Shelfmark'**
  String get shelfmarkTitle;

  /// No description provided for @shelfmarkHint.
  ///
  /// In fr, this message translates to:
  /// **'Si vous avez votre propre Shelfmark, liez-le : les mangas et BD que vous demandez y sont cherchés et téléchargés. Adresse et clé d\'API (variable SHELFMARK_API_KEY) sont dans la configuration de Shelfmark.'**
  String get shelfmarkHint;

  /// No description provided for @shelfmarkHintServer.
  ///
  /// In fr, this message translates to:
  /// **'Sans Shelfmark à vous, les mangas passent par celui du serveur (réservé aux comptes premium), puis par Chaptarr. Avec le vôtre, vous n\'avez pas besoin d\'être premium.'**
  String get shelfmarkHintServer;

  /// No description provided for @shelfmarkUrl.
  ///
  /// In fr, this message translates to:
  /// **'Adresse de votre Shelfmark'**
  String get shelfmarkUrl;

  /// No description provided for @shelfmarkKey.
  ///
  /// In fr, this message translates to:
  /// **'Clé d\'API'**
  String get shelfmarkKey;

  /// No description provided for @shelfmarkKeyHelp.
  ///
  /// In fr, this message translates to:
  /// **'Gardée chiffrée sur le serveur, jamais affichée.'**
  String get shelfmarkKeyHelp;

  /// No description provided for @shelfmarkLink.
  ///
  /// In fr, this message translates to:
  /// **'Lier mon Shelfmark'**
  String get shelfmarkLink;

  /// No description provided for @shelfmarkUnlink.
  ///
  /// In fr, this message translates to:
  /// **'Délier mon Shelfmark'**
  String get shelfmarkUnlink;

  /// No description provided for @shelfmarkLinked.
  ///
  /// In fr, this message translates to:
  /// **'Lié : {url}'**
  String shelfmarkLinked(String url);

  /// No description provided for @shelfmarkLinkedHint.
  ///
  /// In fr, this message translates to:
  /// **'Vos mangas et BD sont téléchargés chez vous.'**
  String get shelfmarkLinkedHint;

  /// No description provided for @shelfmarkWrongKey.
  ///
  /// In fr, this message translates to:
  /// **'Shelfmark a refusé la clé d\'API.'**
  String get shelfmarkWrongKey;

  /// No description provided for @shelfmarkNotShelfmark.
  ///
  /// In fr, this message translates to:
  /// **'Cette adresse ne répond pas comme un Shelfmark.'**
  String get shelfmarkNotShelfmark;

  /// No description provided for @shelfmarkBadAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse ou clé invalide : l\'adresse doit commencer par http:// ou https://.'**
  String get shelfmarkBadAddress;

  /// No description provided for @shelfmarkUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Babel n\'a pas pu joindre ce Shelfmark. L\'adresse doit être joignable depuis internet.'**
  String get shelfmarkUnreachable;

  /// No description provided for @requestSearching.
  ///
  /// In fr, this message translates to:
  /// **'Recherche en cours…'**
  String get requestSearching;

  /// No description provided for @requestShelfmarkSent.
  ///
  /// In fr, this message translates to:
  /// **'Envoyé à Shelfmark. Le livre arrivera dans « Dans mes sources » dès qu\'il sera téléchargé.'**
  String get requestShelfmarkSent;

  /// No description provided for @relatedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Adaptations & œuvres liées'**
  String get relatedTitle;

  /// No description provided for @relatedFilm.
  ///
  /// In fr, this message translates to:
  /// **'Film'**
  String get relatedFilm;

  /// No description provided for @relatedSeries.
  ///
  /// In fr, this message translates to:
  /// **'Série'**
  String get relatedSeries;

  /// No description provided for @relatedGame.
  ///
  /// In fr, this message translates to:
  /// **'Jeu vidéo'**
  String get relatedGame;

  /// No description provided for @relatedComic.
  ///
  /// In fr, this message translates to:
  /// **'BD / manga'**
  String get relatedComic;

  /// No description provided for @relatedStage.
  ///
  /// In fr, this message translates to:
  /// **'Scène'**
  String get relatedStage;

  /// No description provided for @relatedAudio.
  ///
  /// In fr, this message translates to:
  /// **'Audio'**
  String get relatedAudio;

  /// No description provided for @relatedOther.
  ///
  /// In fr, this message translates to:
  /// **'Œuvre liée'**
  String get relatedOther;

  /// No description provided for @levelLabel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau'**
  String get levelLabel;

  /// No description provided for @titleNovice.
  ///
  /// In fr, this message translates to:
  /// **'Curieux'**
  String get titleNovice;

  /// No description provided for @titleReader.
  ///
  /// In fr, this message translates to:
  /// **'Lecteur'**
  String get titleReader;

  /// No description provided for @titleBookworm.
  ///
  /// In fr, this message translates to:
  /// **'Rat de bibliothèque'**
  String get titleBookworm;

  /// No description provided for @titleScholar.
  ///
  /// In fr, this message translates to:
  /// **'Érudit'**
  String get titleScholar;

  /// No description provided for @titleArchivist.
  ///
  /// In fr, this message translates to:
  /// **'Archiviste'**
  String get titleArchivist;

  /// No description provided for @titleLibrarian.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothécaire de Babel'**
  String get titleLibrarian;

  /// No description provided for @badgeFinished.
  ///
  /// In fr, this message translates to:
  /// **'Livres terminés'**
  String get badgeFinished;

  /// No description provided for @badgeStreak.
  ///
  /// In fr, this message translates to:
  /// **'Jours de suite'**
  String get badgeStreak;

  /// No description provided for @badgeReadingDays.
  ///
  /// In fr, this message translates to:
  /// **'Jours de lecture'**
  String get badgeReadingDays;

  /// No description provided for @badgeNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes et surlignages'**
  String get badgeNotes;

  /// No description provided for @badgeReviews.
  ///
  /// In fr, this message translates to:
  /// **'Avis écrits'**
  String get badgeReviews;

  /// No description provided for @badgeLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèque'**
  String get badgeLibrary;

  /// No description provided for @badgeComplete.
  ///
  /// In fr, this message translates to:
  /// **'Tous les paliers atteints'**
  String get badgeComplete;

  /// No description provided for @firstSteps.
  ///
  /// In fr, this message translates to:
  /// **'Premiers pas'**
  String get firstSteps;

  /// No description provided for @stepAddBook.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un premier livre'**
  String get stepAddBook;

  /// No description provided for @stepLinkSource.
  ///
  /// In fr, this message translates to:
  /// **'Lier une source (Kavita, GitHub…)'**
  String get stepLinkSource;

  /// No description provided for @stepRead.
  ///
  /// In fr, this message translates to:
  /// **'Lire un moment'**
  String get stepRead;

  /// No description provided for @stepNote.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une note ou surligner'**
  String get stepNote;

  /// No description provided for @stepFinish.
  ///
  /// In fr, this message translates to:
  /// **'Terminer un livre'**
  String get stepFinish;

  /// No description provided for @stepReview.
  ///
  /// In fr, this message translates to:
  /// **'Donner son avis'**
  String get stepReview;

  /// No description provided for @xpOf.
  ///
  /// In fr, this message translates to:
  /// **'{xp} / {next} XP'**
  String xpOf(int xp, int next);

  /// No description provided for @badgeNext.
  ///
  /// In fr, this message translates to:
  /// **'{value} sur {target} pour le prochain palier'**
  String badgeNext(int value, int target);

  /// No description provided for @koreaderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes liseuses (KOReader)'**
  String get koreaderTitle;

  /// No description provided for @koreaderHint.
  ///
  /// In fr, this message translates to:
  /// **'Sur une liseuse avec KOReader (Boox, Kobo, Kindle…), la progression se synchronise avec Babel. Dans KOReader : Outils › Synchronisation de la progression › Serveur personnalisé, puis entre l\'adresse, l\'e-mail et le mot de passe ci-dessous.'**
  String get koreaderHint;

  /// No description provided for @koreaderServer.
  ///
  /// In fr, this message translates to:
  /// **'Adresse du serveur'**
  String get koreaderServer;

  /// No description provided for @koreaderUser.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant (e-mail)'**
  String get koreaderUser;

  /// No description provided for @koreaderPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe KOReader'**
  String get koreaderPassword;

  /// No description provided for @koreaderShownOnce.
  ///
  /// In fr, this message translates to:
  /// **'Notez-le : il ne sera plus affiché.'**
  String get koreaderShownOnce;

  /// No description provided for @koreaderMake.
  ///
  /// In fr, this message translates to:
  /// **'Créer un mot de passe pour KOReader'**
  String get koreaderMake;

  /// No description provided for @koreaderRenew.
  ///
  /// In fr, this message translates to:
  /// **'Remplacer le mot de passe'**
  String get koreaderRenew;

  /// No description provided for @pluginsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plugins'**
  String get pluginsTitle;

  /// No description provided for @pluginsHint.
  ///
  /// In fr, this message translates to:
  /// **'Des sources installées par l\'administrateur : active celles que tu veux, elles s\'ajoutent à tes sources.'**
  String get pluginsHint;

  /// No description provided for @pluginsAdminTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plugins de sources'**
  String get pluginsAdminTitle;

  /// No description provided for @pluginsAdminHint.
  ///
  /// In fr, this message translates to:
  /// **'Installe une source à partir de l\'adresse de son manifeste : chaque lecteur pourra l\'activer (ou non).'**
  String get pluginsAdminHint;

  /// No description provided for @pluginsName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du plugin'**
  String get pluginsName;

  /// No description provided for @pluginsUrl.
  ///
  /// In fr, this message translates to:
  /// **'Adresse du manifeste'**
  String get pluginsUrl;

  /// No description provided for @pluginsToken.
  ///
  /// In fr, this message translates to:
  /// **'Jeton d\'accès (facultatif)'**
  String get pluginsToken;

  /// No description provided for @pluginsInstall.
  ///
  /// In fr, this message translates to:
  /// **'Installer le plugin'**
  String get pluginsInstall;

  /// No description provided for @pluginsRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer le plugin'**
  String get pluginsRemove;

  /// No description provided for @pluginsInstallFailed.
  ///
  /// In fr, this message translates to:
  /// **'Cette adresse ne répond pas comme un manifeste Babel.'**
  String get pluginsInstallFailed;

  /// No description provided for @externalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ailleurs'**
  String get externalTitle;

  /// No description provided for @reviewSpoilers.
  ///
  /// In fr, this message translates to:
  /// **'Cet avis contient des spoilers · afficher'**
  String get reviewSpoilers;

  /// No description provided for @ratingsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{# note} other{# notes}}'**
  String ratingsCount(int count);

  /// No description provided for @homeReading.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get homeReading;

  /// No description provided for @homeResume.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get homeResume;

  /// No description provided for @homeForYou.
  ///
  /// In fr, this message translates to:
  /// **'Pour vous'**
  String get homeForYou;

  /// No description provided for @homeSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout voir'**
  String get homeSeeAll;

  /// No description provided for @homePile.
  ///
  /// In fr, this message translates to:
  /// **'Pile à lire'**
  String get homePile;

  /// No description provided for @homeJourney.
  ///
  /// In fr, this message translates to:
  /// **'Votre parcours'**
  String get homeJourney;

  /// No description provided for @homeBadges.
  ///
  /// In fr, this message translates to:
  /// **'Badges'**
  String get homeBadges;

  /// No description provided for @homeBorn.
  ///
  /// In fr, this message translates to:
  /// **'Né de vos lectures'**
  String get homeBorn;

  /// No description provided for @homeMoods.
  ///
  /// In fr, this message translates to:
  /// **'Explorer par ambiance'**
  String get homeMoods;

  /// No description provided for @homeDownloads.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargements'**
  String get homeDownloads;

  /// No description provided for @homeWrapInvite.
  ///
  /// In fr, this message translates to:
  /// **'Découvrez votre Wrap'**
  String get homeWrapInvite;

  /// No description provided for @moodDarkAcademia.
  ///
  /// In fr, this message translates to:
  /// **'Dark academia'**
  String get moodDarkAcademia;

  /// No description provided for @moodGothic.
  ///
  /// In fr, this message translates to:
  /// **'Gothique'**
  String get moodGothic;

  /// No description provided for @moodTragicRomance.
  ///
  /// In fr, this message translates to:
  /// **'Romance tragique'**
  String get moodTragicRomance;

  /// No description provided for @moodBottle.
  ///
  /// In fr, this message translates to:
  /// **'Huis clos'**
  String get moodBottle;

  /// No description provided for @moodClassics.
  ///
  /// In fr, this message translates to:
  /// **'Classiques'**
  String get moodClassics;

  /// No description provided for @moodEnemies.
  ///
  /// In fr, this message translates to:
  /// **'Enemies to lovers'**
  String get moodEnemies;

  /// No description provided for @moodFantasy.
  ///
  /// In fr, this message translates to:
  /// **'Fantastique'**
  String get moodFantasy;

  /// No description provided for @moodFanfiction.
  ///
  /// In fr, this message translates to:
  /// **'Fanfictions'**
  String get moodFanfiction;

  /// No description provided for @homeBooksCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{# livre} other{# livres}}'**
  String homeBooksCount(int count);

  /// No description provided for @homeYourMonth.
  ///
  /// In fr, this message translates to:
  /// **'Votre {month}'**
  String homeYourMonth(String month);

  /// No description provided for @homeMonthBooks.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{# livre terminé} other{# livres terminés}} ce mois-ci'**
  String homeMonthBooks(int count);

  /// No description provided for @scanPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photographier la couverture (expérimental)'**
  String get scanPhoto;

  /// No description provided for @scanPhotoNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livre reconnu sur cette photo. Essaie avec un code-barres, ou cherche par titre.'**
  String get scanPhotoNone;

  /// No description provided for @scanPhotoUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'La lecture de couverture n\'est pas disponible sur ce serveur.'**
  String get scanPhotoUnavailable;

  /// No description provided for @groupAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get groupAccount;

  /// No description provided for @groupAccountHint.
  ///
  /// In fr, this message translates to:
  /// **'Profil, mot de passe, profil public'**
  String get groupAccountHint;

  /// No description provided for @groupDisplay.
  ///
  /// In fr, this message translates to:
  /// **'Affichage & appareils'**
  String get groupDisplay;

  /// No description provided for @groupDisplayHint.
  ///
  /// In fr, this message translates to:
  /// **'Langue, mode liseuse, appareils, KOReader'**
  String get groupDisplayHint;

  /// No description provided for @groupConnections.
  ///
  /// In fr, this message translates to:
  /// **'Sources & connexions'**
  String get groupConnections;

  /// No description provided for @groupConnectionsHint.
  ///
  /// In fr, this message translates to:
  /// **'Tes sources et plugins, Kavita, Audiobookshelf'**
  String get groupConnectionsHint;

  /// No description provided for @groupRequests.
  ///
  /// In fr, this message translates to:
  /// **'Demandes de livres'**
  String get groupRequests;

  /// No description provided for @groupRequestsHint.
  ///
  /// In fr, this message translates to:
  /// **'Shelfmark et Chaptarr, pour télécharger les livres'**
  String get groupRequestsHint;

  /// No description provided for @groupData.
  ///
  /// In fr, this message translates to:
  /// **'Import'**
  String get groupData;

  /// No description provided for @groupDataHint.
  ///
  /// In fr, this message translates to:
  /// **'Importer une liste de lecture'**
  String get groupDataHint;

  /// No description provided for @devicesHint.
  ///
  /// In fr, this message translates to:
  /// **'Les appareils qui se synchronisent avec ton compte.'**
  String get devicesHint;

  /// No description provided for @devicesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun appareil pour l\'instant.'**
  String get devicesEmpty;

  /// No description provided for @deviceThis.
  ///
  /// In fr, this message translates to:
  /// **'cet appareil'**
  String get deviceThis;

  /// No description provided for @deviceForget.
  ///
  /// In fr, this message translates to:
  /// **'Oublier'**
  String get deviceForget;

  /// No description provided for @deviceForgetBody.
  ///
  /// In fr, this message translates to:
  /// **'Cet appareil ne sera plus synchronisé tant que tu ne t\'y reconnectes pas. Tes livres et ta progression restent.'**
  String get deviceForgetBody;

  /// No description provided for @groupSources.
  ///
  /// In fr, this message translates to:
  /// **'Sources'**
  String get groupSources;

  /// No description provided for @deviceForgetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Oublier {name} ?'**
  String deviceForgetTitle(String name);

  /// No description provided for @deviceLastSeen.
  ///
  /// In fr, this message translates to:
  /// **'vu {when}'**
  String deviceLastSeen(String when);

  /// No description provided for @mySources.
  ///
  /// In fr, this message translates to:
  /// **'Mes sources'**
  String get mySources;

  /// No description provided for @pageboundTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pagebound'**
  String get pageboundTitle;

  /// No description provided for @pageboundHint.
  ///
  /// In fr, this message translates to:
  /// **'Lie ton compte Pagebound avec ton nom d\'utilisateur public (pas de mot de passe) : tes avis publics peuvent être importés dans Babel, en avis privés, avec leurs notes.'**
  String get pageboundHint;

  /// No description provided for @pageboundUsername.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur Pagebound'**
  String get pageboundUsername;

  /// No description provided for @pageboundLink.
  ///
  /// In fr, this message translates to:
  /// **'Lier mon compte Pagebound'**
  String get pageboundLink;

  /// No description provided for @pageboundUnlink.
  ///
  /// In fr, this message translates to:
  /// **'Délier'**
  String get pageboundUnlink;

  /// No description provided for @pageboundImport.
  ///
  /// In fr, this message translates to:
  /// **'Importer mes avis Pagebound'**
  String get pageboundImport;

  /// No description provided for @pageboundNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun lecteur de ce nom sur Pagebound.'**
  String get pageboundNotFound;

  /// No description provided for @pageboundLinked.
  ///
  /// In fr, this message translates to:
  /// **'Lié : {name}'**
  String pageboundLinked(String name);

  /// No description provided for @pageboundImported.
  ///
  /// In fr, this message translates to:
  /// **'{imported, plural, one{# avis importé} other{# avis importés}}, {skipped} déjà dans ta bibliothèque'**
  String pageboundImported(int imported, int skipped);

  /// No description provided for @themeClassics.
  ///
  /// In fr, this message translates to:
  /// **'Grands classiques'**
  String get themeClassics;

  /// No description provided for @badgeClassics.
  ///
  /// In fr, this message translates to:
  /// **'Rat de classiques'**
  String get badgeClassics;

  /// No description provided for @themeRomance.
  ///
  /// In fr, this message translates to:
  /// **'Histoires de cœur'**
  String get themeRomance;

  /// No description provided for @badgeRomance.
  ///
  /// In fr, this message translates to:
  /// **'Cœur battant'**
  String get badgeRomance;

  /// No description provided for @themeScifi.
  ///
  /// In fr, this message translates to:
  /// **'Voyages dans le futur'**
  String get themeScifi;

  /// No description provided for @badgeScifi.
  ///
  /// In fr, this message translates to:
  /// **'Voyageur du futur'**
  String get badgeScifi;

  /// No description provided for @themeMystery.
  ///
  /// In fr, this message translates to:
  /// **'Enquêtes et polars'**
  String get themeMystery;

  /// No description provided for @badgeMystery.
  ///
  /// In fr, this message translates to:
  /// **'Fin limier'**
  String get badgeMystery;

  /// No description provided for @themeFantasy.
  ///
  /// In fr, this message translates to:
  /// **'Mondes imaginaires'**
  String get themeFantasy;

  /// No description provided for @badgeFantasy.
  ///
  /// In fr, this message translates to:
  /// **'Maître des sortilèges'**
  String get badgeFantasy;

  /// No description provided for @themeComics.
  ///
  /// In fr, this message translates to:
  /// **'BD et mangas'**
  String get themeComics;

  /// No description provided for @badgeComics.
  ///
  /// In fr, this message translates to:
  /// **'Œil de lynx'**
  String get badgeComics;

  /// No description provided for @themeYoung.
  ///
  /// In fr, this message translates to:
  /// **'Jeunesse et young adult'**
  String get themeYoung;

  /// No description provided for @badgeYoung.
  ///
  /// In fr, this message translates to:
  /// **'Jeune pousse'**
  String get badgeYoung;

  /// No description provided for @themeHistory.
  ///
  /// In fr, this message translates to:
  /// **'Plongée dans l\'histoire'**
  String get themeHistory;

  /// No description provided for @badgeHistory.
  ///
  /// In fr, this message translates to:
  /// **'Chroniqueur'**
  String get badgeHistory;

  /// No description provided for @themeStage.
  ///
  /// In fr, this message translates to:
  /// **'Théâtre et poésie'**
  String get themeStage;

  /// No description provided for @badgeStage.
  ///
  /// In fr, this message translates to:
  /// **'Voix de la scène'**
  String get badgeStage;

  /// No description provided for @themeGothic.
  ///
  /// In fr, this message translates to:
  /// **'Lectures gothiques'**
  String get themeGothic;

  /// No description provided for @badgeGothic.
  ///
  /// In fr, this message translates to:
  /// **'Âme sombre'**
  String get badgeGothic;

  /// No description provided for @themeEssays.
  ///
  /// In fr, this message translates to:
  /// **'Essais et idées'**
  String get themeEssays;

  /// No description provided for @badgeEssays.
  ///
  /// In fr, this message translates to:
  /// **'Esprit curieux'**
  String get badgeEssays;

  /// No description provided for @themeWinter.
  ///
  /// In fr, this message translates to:
  /// **'Contes d\'hiver'**
  String get themeWinter;

  /// No description provided for @badgeWinter.
  ///
  /// In fr, this message translates to:
  /// **'Veilleur de neige'**
  String get badgeWinter;

  /// No description provided for @challengeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Défi du mois · {theme}'**
  String challengeTitle(String theme);

  /// No description provided for @challengeProgress.
  ///
  /// In fr, this message translates to:
  /// **'{done} / {target} livres — badge « {badge} »'**
  String challengeProgress(int done, int target, String badge);

  /// No description provided for @challengeWon.
  ///
  /// In fr, this message translates to:
  /// **'Défi réussi — badge « {badge} » gagné'**
  String challengeWon(String badge);

  /// No description provided for @playlistDystopia.
  ///
  /// In fr, this message translates to:
  /// **'Dystopies'**
  String get playlistDystopia;

  /// No description provided for @playlistMystery.
  ///
  /// In fr, this message translates to:
  /// **'Enquêtes & polars'**
  String get playlistMystery;

  /// No description provided for @playlistHorror.
  ///
  /// In fr, this message translates to:
  /// **'Frissons'**
  String get playlistHorror;

  /// No description provided for @playlistHistorical.
  ///
  /// In fr, this message translates to:
  /// **'Romans historiques'**
  String get playlistHistorical;

  /// No description provided for @playlistComingOfAge.
  ///
  /// In fr, this message translates to:
  /// **'Passage à l’âge adulte'**
  String get playlistComingOfAge;

  /// No description provided for @playlistHint.
  ///
  /// In fr, this message translates to:
  /// **'Les livres les plus lus de ce thème, d’après Open Library.'**
  String get playlistHint;

  /// No description provided for @homePlaylists.
  ///
  /// In fr, this message translates to:
  /// **'Playlists'**
  String get homePlaylists;

  /// No description provided for @suggestionGenre.
  ///
  /// In fr, this message translates to:
  /// **'Parce que vous lisez du {genre}'**
  String suggestionGenre(String genre);

  /// No description provided for @suggestionAuthor.
  ///
  /// In fr, this message translates to:
  /// **'Plus de {author}'**
  String suggestionAuthor(String author);

  /// No description provided for @coverDefault.
  ///
  /// In fr, this message translates to:
  /// **'Par défaut'**
  String get coverDefault;

  /// No description provided for @coverLinkFirst.
  ///
  /// In fr, this message translates to:
  /// **'Associez d\'abord ce livre à une fiche pour choisir parmi les couvertures de ses éditions.'**
  String get coverLinkFirst;

  /// No description provided for @volumeNumber.
  ///
  /// In fr, this message translates to:
  /// **'Tome {number}'**
  String volumeNumber(String number);

  /// No description provided for @seriesVolumes.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 tome} other{{count} tomes}}'**
  String seriesVolumes(int count);

  /// No description provided for @seriesRead.
  ///
  /// In fr, this message translates to:
  /// **'{count} lus'**
  String seriesRead(int count);

  /// No description provided for @detailsSaved.
  ///
  /// In fr, this message translates to:
  /// **'Informations enregistrées.'**
  String get detailsSaved;

  /// No description provided for @seriesOf.
  ///
  /// In fr, this message translates to:
  /// **'{series} · tome {number}'**
  String seriesOf(String series, String number);

  /// No description provided for @goalSet.
  ///
  /// In fr, this message translates to:
  /// **'Fixer un objectif'**
  String get goalSet;

  /// No description provided for @goalEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get goalEdit;

  /// No description provided for @goalAsk.
  ///
  /// In fr, this message translates to:
  /// **'Combien de livres cette année ?'**
  String get goalAsk;

  /// No description provided for @goalAskHint.
  ///
  /// In fr, this message translates to:
  /// **'Livres à terminer chaque année'**
  String get goalAskHint;

  /// No description provided for @goalRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer l\'objectif'**
  String get goalRemove;

  /// No description provided for @goalProgress.
  ///
  /// In fr, this message translates to:
  /// **'{done} sur {goal} livres'**
  String goalProgress(int done, int goal);

  /// No description provided for @goalReached.
  ///
  /// In fr, this message translates to:
  /// **'Objectif atteint, bravo !'**
  String get goalReached;

  /// No description provided for @goalLeft.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Encore 1 livre} other{Encore {count} livres}}'**
  String goalLeft(int count);

  /// No description provided for @importTitle.
  ///
  /// In fr, this message translates to:
  /// **'Importer un historique'**
  String get importTitle;

  /// No description provided for @importIntro.
  ///
  /// In fr, this message translates to:
  /// **'Goodreads, StoryGraph ou Babelio : exportez votre liste en CSV, Babel la reprend avec statuts, notes et dates (livres papier, sans fichier).'**
  String get importIntro;

  /// No description provided for @importChoose.
  ///
  /// In fr, this message translates to:
  /// **'Choisir le fichier CSV'**
  String get importChoose;

  /// No description provided for @csvImportDone.
  ///
  /// In fr, this message translates to:
  /// **'{imported} importés · {skipped} déjà là · {failed} sans titre'**
  String csvImportDone(int imported, int skipped, int failed);

  /// No description provided for @importNotList.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier n\'est pas une liste de lecture connue.'**
  String get importNotList;

  /// No description provided for @likeReview.
  ///
  /// In fr, this message translates to:
  /// **'J\'aime'**
  String get likeReview;

  /// No description provided for @commentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commentaires'**
  String get commentsTitle;

  /// No description provided for @commentsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Commenter} =1{1 commentaire} other{{count} commentaires}}'**
  String commentsCount(int count);

  /// No description provided for @commentHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre commentaire'**
  String get commentHint;

  /// No description provided for @commentSend.
  ///
  /// In fr, this message translates to:
  /// **'Publier'**
  String get commentSend;

  /// No description provided for @commentDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get commentDelete;

  /// No description provided for @commentsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de commentaire.'**
  String get commentsEmpty;

  /// No description provided for @audioDownload.
  ///
  /// In fr, this message translates to:
  /// **'Écouter hors ligne'**
  String get audioDownload;

  /// No description provided for @audioDownloading.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement…'**
  String get audioDownloading;

  /// No description provided for @audioOffline.
  ///
  /// In fr, this message translates to:
  /// **'Disponible hors ligne'**
  String get audioOffline;

  /// No description provided for @sagaTitle.
  ///
  /// In fr, this message translates to:
  /// **'Saga'**
  String get sagaTitle;

  /// No description provided for @sagaSee.
  ///
  /// In fr, this message translates to:
  /// **'Voir toute la saga'**
  String get sagaSee;

  /// No description provided for @sagaOf.
  ///
  /// In fr, this message translates to:
  /// **'{series} · tome {number}'**
  String sagaOf(String series, String number);

  /// No description provided for @sagaCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 tome} other{{count} tomes}} dans le catalogue · {owned} dans votre bibliothèque'**
  String sagaCount(int count, int owned);

  /// No description provided for @sagaMissing.
  ///
  /// In fr, this message translates to:
  /// **'Introuvable dans le catalogue'**
  String get sagaMissing;

  /// No description provided for @sagaNotOwned.
  ///
  /// In fr, this message translates to:
  /// **'Pas dans votre bibliothèque'**
  String get sagaNotOwned;

  /// No description provided for @sagaEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun tome trouvé pour cette saga.'**
  String get sagaEmpty;

  /// No description provided for @sagaHint.
  ///
  /// In fr, this message translates to:
  /// **'Les tomes viennent du catalogue : ouvrez-en un pour l\'ajouter, ou le chercher dans vos sources.'**
  String get sagaHint;

  /// No description provided for @progressAskPageHint.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de la page'**
  String get progressAskPageHint;

  /// No description provided for @cleanFinished.
  ///
  /// In fr, this message translates to:
  /// **'Retirer les livres lus ({count})'**
  String cleanFinished(int count);

  /// No description provided for @cleanFinishedAsk.
  ///
  /// In fr, this message translates to:
  /// **'Retirer {count} livres lus de la bibliothèque ?'**
  String cleanFinishedAsk(int count);

  /// No description provided for @cleanFinishedBody.
  ///
  /// In fr, this message translates to:
  /// **'Les fichiers sont retirés, pas vos notes, avis ni progression : en remettant un livre, vous les retrouvez.'**
  String get cleanFinishedBody;

  /// No description provided for @cleanFinishedDone.
  ///
  /// In fr, this message translates to:
  /// **'{count} livres retirés.'**
  String cleanFinishedDone(int count);

  /// No description provided for @monthWrapBooks.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{livre terminé} =1{livre terminé} other{livres terminés}}'**
  String monthWrapBooks(int count);

  /// No description provided for @monthWrapEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livre terminé ce mois-ci.'**
  String get monthWrapEmpty;

  /// No description provided for @monthWrapShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager l\'image'**
  String get monthWrapShare;

  /// No description provided for @statsOpenMonth.
  ///
  /// In fr, this message translates to:
  /// **'Récap de {month}'**
  String statsOpenMonth(String month);

  /// No description provided for @scanBurst.
  ///
  /// In fr, this message translates to:
  /// **'Rafale : ajouter chaque livre en papier'**
  String get scanBurst;

  /// No description provided for @scanBurstAdded.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 livre ajouté} other{{count} livres ajoutés}} : {titles}'**
  String scanBurstAdded(int count, String titles);

  /// No description provided for @adminConnectors.
  ///
  /// In fr, this message translates to:
  /// **'Connecteurs'**
  String get adminConnectors;

  /// No description provided for @adminSourcesHealth.
  ///
  /// In fr, this message translates to:
  /// **'Santé des sources'**
  String get adminSourcesHealth;

  /// No description provided for @adminNoSources.
  ///
  /// In fr, this message translates to:
  /// **'Aucune source connectée.'**
  String get adminNoSources;

  /// No description provided for @adminScanned.
  ///
  /// In fr, this message translates to:
  /// **'scan {date}'**
  String adminScanned(String date);

  /// No description provided for @adminNeverScanned.
  ///
  /// In fr, this message translates to:
  /// **'jamais scanné'**
  String get adminNeverScanned;

  /// No description provided for @adminQuota.
  ///
  /// In fr, this message translates to:
  /// **'Sources : {value}'**
  String adminQuota(String value);

  /// No description provided for @adminQuotaDefault.
  ///
  /// In fr, this message translates to:
  /// **'défaut ({count})'**
  String adminQuotaDefault(int count);

  /// No description provided for @adminQuotaAsk.
  ///
  /// In fr, this message translates to:
  /// **'Combien de sources ?'**
  String get adminQuotaAsk;

  /// No description provided for @adminQuotaHint.
  ///
  /// In fr, this message translates to:
  /// **'Vide : retour au défaut du serveur'**
  String get adminQuotaHint;

  /// No description provided for @requestBook.
  ///
  /// In fr, this message translates to:
  /// **'Demander ce livre'**
  String get requestBook;

  /// No description provided for @requestHint.
  ///
  /// In fr, this message translates to:
  /// **'Babel le cherche et le télécharge pour vous. Il apparaîtra ici dès qu\'il est arrivé.'**
  String get requestHint;

  /// No description provided for @requestPending.
  ///
  /// In fr, this message translates to:
  /// **'Demandé : en cours de recherche. Revenez dans un moment.'**
  String get requestPending;

  /// No description provided for @requestAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargé : il apparaît ici après le prochain scan.'**
  String get requestAvailable;

  /// No description provided for @requestNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Introuvable pour l\'instant.'**
  String get requestNotFound;

  /// No description provided for @requestFailed.
  ///
  /// In fr, this message translates to:
  /// **'La demande n\'a pas pu partir. Réessayez plus tard.'**
  String get requestFailed;

  /// No description provided for @addSourceHint.
  ///
  /// In fr, this message translates to:
  /// **'Ce livre n\'est dans aucune de vos sources. Ajoutez-en une (Kavita, WebDAV, GitHub…) pour le retrouver ici, ou liez votre Chaptarr dans Compte pour pouvoir le demander.'**
  String get addSourceHint;

  /// No description provided for @sourceScanning.
  ///
  /// In fr, this message translates to:
  /// **'Scan en cours… un gros compte peut prendre plusieurs minutes.'**
  String get sourceScanning;

  /// No description provided for @sagaOpenKnown.
  ///
  /// In fr, this message translates to:
  /// **'Pas dans le catalogue : ouvrez-le pour le chercher dans vos sources ou le demander.'**
  String get sagaOpenKnown;

  /// No description provided for @chaptarrTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon Chaptarr'**
  String get chaptarrTitle;

  /// No description provided for @chaptarrHint.
  ///
  /// In fr, this message translates to:
  /// **'Si vous avez votre propre Chaptarr, liez-le : les livres que vous demandez depuis Babel y seront cherchés et téléchargés. Adresse et clé d\'API sont dans Chaptarr, Réglages, Général.'**
  String get chaptarrHint;

  /// No description provided for @chaptarrHintServer.
  ///
  /// In fr, this message translates to:
  /// **'Sans Chaptarr à vous, les demandes passent par celui du serveur (réservé aux comptes premium). Avec le vôtre, vous pouvez demander sans être premium : adresse et clé d\'API sont dans Chaptarr, Réglages, Général.'**
  String get chaptarrHintServer;

  /// No description provided for @chaptarrUrl.
  ///
  /// In fr, this message translates to:
  /// **'Adresse de votre Chaptarr'**
  String get chaptarrUrl;

  /// No description provided for @chaptarrKey.
  ///
  /// In fr, this message translates to:
  /// **'Clé d\'API'**
  String get chaptarrKey;

  /// No description provided for @chaptarrKeyHelp.
  ///
  /// In fr, this message translates to:
  /// **'Gardée chiffrée sur le serveur, jamais affichée.'**
  String get chaptarrKeyHelp;

  /// No description provided for @chaptarrLink.
  ///
  /// In fr, this message translates to:
  /// **'Lier mon Chaptarr'**
  String get chaptarrLink;

  /// No description provided for @chaptarrUnlink.
  ///
  /// In fr, this message translates to:
  /// **'Délier mon Chaptarr'**
  String get chaptarrUnlink;

  /// No description provided for @chaptarrLinked.
  ///
  /// In fr, this message translates to:
  /// **'Lié : {url}'**
  String chaptarrLinked(String url);

  /// No description provided for @chaptarrLinkedHint.
  ///
  /// In fr, this message translates to:
  /// **'Vos demandes de livres partent chez vous.'**
  String get chaptarrLinkedHint;

  /// No description provided for @chaptarrWrongKey.
  ///
  /// In fr, this message translates to:
  /// **'Chaptarr a refusé la clé d\'API.'**
  String get chaptarrWrongKey;

  /// No description provided for @chaptarrNotChaptarr.
  ///
  /// In fr, this message translates to:
  /// **'Cette adresse ne répond pas comme un Chaptarr.'**
  String get chaptarrNotChaptarr;

  /// No description provided for @chaptarrBadAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse ou clé invalide : l\'adresse doit commencer par http:// ou https://.'**
  String get chaptarrBadAddress;

  /// No description provided for @chaptarrUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Babel n\'a pas pu joindre ce Chaptarr. L\'adresse doit être joignable depuis internet.'**
  String get chaptarrUnreachable;

  /// No description provided for @requestDownloading.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement : {percent} %'**
  String requestDownloading(int percent);

  /// No description provided for @sourceScanDone.
  ///
  /// In fr, this message translates to:
  /// **'Scan terminé : {total} livres (+{added}, −{removed})'**
  String sourceScanDone(int total, int added, int removed);

  /// No description provided for @librarySearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Chercher dans ma bibliothèque'**
  String get librarySearchHint;

  /// No description provided for @libraryNoMatch.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livre de votre bibliothèque ne correspond.'**
  String get libraryNoMatch;

  /// No description provided for @audiobooksLinkNow.
  ///
  /// In fr, this message translates to:
  /// **'Lier mon Audiobookshelf'**
  String get audiobooksLinkNow;

  /// No description provided for @fanficSummary.
  ///
  /// In fr, this message translates to:
  /// **'Résumé'**
  String get fanficSummary;

  /// No description provided for @fanficFandoms.
  ///
  /// In fr, this message translates to:
  /// **'Univers'**
  String get fanficFandoms;

  /// No description provided for @fanficRelationships.
  ///
  /// In fr, this message translates to:
  /// **'Relations'**
  String get fanficRelationships;

  /// No description provided for @fanficCharacters.
  ///
  /// In fr, this message translates to:
  /// **'Personnages'**
  String get fanficCharacters;

  /// No description provided for @fanficTags.
  ///
  /// In fr, this message translates to:
  /// **'Étiquettes'**
  String get fanficTags;

  /// No description provided for @fanficWarnings.
  ///
  /// In fr, this message translates to:
  /// **'Avertissements'**
  String get fanficWarnings;

  /// No description provided for @fanficWords.
  ///
  /// In fr, this message translates to:
  /// **'{count} mots'**
  String fanficWords(int count);

  /// No description provided for @fanficKudos.
  ///
  /// In fr, this message translates to:
  /// **'{count} kudos'**
  String fanficKudos(int count);

  /// No description provided for @fanficHits.
  ///
  /// In fr, this message translates to:
  /// **'{count} vues'**
  String fanficHits(int count);

  /// No description provided for @fanficChapters.
  ///
  /// In fr, this message translates to:
  /// **'{chapters} chapitres'**
  String fanficChapters(String chapters);

  /// No description provided for @fanficUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour le {date}'**
  String fanficUpdated(String date);

  /// No description provided for @fanficPublished.
  ///
  /// In fr, this message translates to:
  /// **'Publié le {date}'**
  String fanficPublished(String date);

  /// No description provided for @fanficOnAo3.
  ///
  /// In fr, this message translates to:
  /// **'Voir sur AO3'**
  String get fanficOnAo3;

  /// No description provided for @fanficUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'AO3 n\'a pas pu donner les détails de cette fanfiction (réservée aux membres, ou injoignable pour l\'instant).'**
  String get fanficUnavailable;

  /// No description provided for @appearanceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get appearanceTitle;

  /// No description provided for @appearanceNight.
  ///
  /// In fr, this message translates to:
  /// **'Nuit'**
  String get appearanceNight;

  /// No description provided for @appearanceDeco.
  ///
  /// In fr, this message translates to:
  /// **'Art déco'**
  String get appearanceDeco;

  /// No description provided for @playlistSpace.
  ///
  /// In fr, this message translates to:
  /// **'L\'espace'**
  String get playlistSpace;

  /// No description provided for @playlistSea.
  ///
  /// In fr, this message translates to:
  /// **'La mer'**
  String get playlistSea;

  /// No description provided for @playlistWar.
  ///
  /// In fr, this message translates to:
  /// **'La guerre'**
  String get playlistWar;

  /// No description provided for @playlistMagic.
  ///
  /// In fr, this message translates to:
  /// **'La magie'**
  String get playlistMagic;

  /// No description provided for @playlistTravel.
  ///
  /// In fr, this message translates to:
  /// **'Les voyages'**
  String get playlistTravel;

  /// No description provided for @playlistFriendship.
  ///
  /// In fr, this message translates to:
  /// **'L\'amitié'**
  String get playlistFriendship;

  /// No description provided for @extraPrize.
  ///
  /// In fr, this message translates to:
  /// **'Défi · lauréats du {prize}'**
  String extraPrize(String prize);

  /// No description provided for @extraSubject.
  ///
  /// In fr, this message translates to:
  /// **'Défi · lire sur {subject}'**
  String extraSubject(String subject);

  /// No description provided for @extraAuthors.
  ///
  /// In fr, this message translates to:
  /// **'Défi · trois auteurs différents'**
  String get extraAuthors;

  /// No description provided for @extraCountries.
  ///
  /// In fr, this message translates to:
  /// **'Défi · trois pays différents'**
  String get extraCountries;

  /// No description provided for @extraProgress.
  ///
  /// In fr, this message translates to:
  /// **'{done} / {target} livres'**
  String extraProgress(int done, int target);

  /// No description provided for @extraWon.
  ///
  /// In fr, this message translates to:
  /// **'Défi réussi, bravo !'**
  String get extraWon;
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
    'that was used.',
  );
}
