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
  /// **'« {title} » a été retiré de votre bibliothèque.'**
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
  /// **'Par exemple https://calibre.example.com/opds'**
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
