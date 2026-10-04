// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get brand => 'BABEL';

  @override
  String get navFeatures => 'Fonctionnalités';

  @override
  String get navDevices => 'Appareils';

  @override
  String get navPrivacy => 'Confidentialité';

  @override
  String get signIn => 'Se connecter';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get heroEyebrow => 'Bibliothèque · Lecture · Annotations';

  @override
  String get heroTitleLead => 'Toute votre bibliothèque, ';

  @override
  String get heroTitleEmphasis => 'au même endroit.';

  @override
  String get heroLede =>
      'Livres papier ou numériques, BD, audio et fanfictions : rangez toute votre bibliothèque, suivez vos lectures et partagez-les avec vos amis. Importez vos propres fichiers pour les lire où que vous soyez.';

  @override
  String get startFree => 'Commencer — c’est gratuit';

  @override
  String get haveAccount => 'J’ai déjà un compte';

  @override
  String get heroNote => 'Sans publicité. Vos données restent les vôtres.';

  @override
  String get trendingLabel => 'Tendance cette semaine';

  @override
  String get featuresEyebrow => 'Fonctionnalités';

  @override
  String get featuresTitle =>
      'Une bibliothèque qui vous ressemble, pas un catalogue.';

  @override
  String get featureAllTitle => 'Tout au même endroit';

  @override
  String get featureAllBody =>
      'Scannez vos livres papier, importez vos fichiers, téléchargez vos fanfictions depuis AO3 et retrouvez vos lectures en cours, à lire et terminées.';

  @override
  String get featureSyncTitle => 'Vos fichiers, partout';

  @override
  String get featureSyncBody =>
      'Importez vos EPUB et reprenez à la bonne page sur liseuse, téléphone ou ordinateur, même hors ligne.';

  @override
  String get featureNotesTitle => 'Annotez en marge';

  @override
  String get featureNotesBody =>
      'Surlignez, commentez, retrouvez vos passages préférés et ceux de vos amis.';

  @override
  String get featureStatsTitle => 'Vos lectures, en chiffres';

  @override
  String get featureStatsBody =>
      'Statistiques, objectifs et un bilan de fin d’année que vous aurez envie de partager.';

  @override
  String get devicesEyebrow => 'Appareils';

  @override
  String get devicesTitle => 'Lisez où vous voulez. Babel suit.';

  @override
  String get devicesBody =>
      'Votre progression, vos notes et vos étagères se synchronisent entre vos appareils. Commencez un chapitre au lit sur votre liseuse, finissez-le dans le métro.';

  @override
  String get deviceChapter => 'Chapitre XII';

  @override
  String get deviceExcerpt =>
      'Marguerite ouvrit la fenêtre. La lune, au-dessus des toits, éclairait la rue d’une lumière blanche et nette, comme si quelqu’un avait tendu un drap sur toute la ville…';

  @override
  String get deviceSynced => 'Synchronisé';

  @override
  String get quote =>
      '« Quoi que nos âmes soient faites, la sienne et la mienne sont pareilles. »';

  @override
  String get quoteAuthor => 'Emily Brontë · Les Hauts de Hurle-Vent';

  @override
  String get ctaTitle => 'Ouvrez votre bibliothèque.';

  @override
  String get ctaBody => 'Créez votre compte en une minute.';

  @override
  String get footerPrivacy => 'Confidentialité';

  @override
  String get footerTerms => 'Conditions';

  @override
  String get footerContact => 'Contact';

  @override
  String get authQuote => '« Un lecteur vit mille vies avant de mourir. »';

  @override
  String get authQuoteAuthor => 'George R. R. Martin';

  @override
  String get loginEyebrow => 'Connexion';

  @override
  String get loginTitle => 'Bon retour parmi nous.';

  @override
  String get loginLede => 'Reprenez votre lecture là où vous l’aviez laissée.';

  @override
  String get signupEyebrow => 'Inscription';

  @override
  String get signupTitle => 'Ouvrez votre bibliothèque.';

  @override
  String get signupLede =>
      'Un compte pour retrouver vos livres, vos notes et vos amis sur tous vos appareils.';

  @override
  String get continueWithApple => 'Continuer avec Apple';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get or => 'ou';

  @override
  String get displayNameLabel => 'Nom affiché';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get showPassword => 'Afficher';

  @override
  String get hidePassword => 'Masquer';

  @override
  String get passwordHelp =>
      '10 caractères minimum. Une phrase de passe est idéale.';

  @override
  String get termsNotice =>
      'En créant un compte, vous acceptez les Conditions d’utilisation et la Politique de confidentialité.';

  @override
  String get createMyAccount => 'Créer mon compte';

  @override
  String get noAccount => 'Pas encore de compte ?';

  @override
  String get alreadyAccount => 'Déjà un compte ?';

  @override
  String get errorRequired => 'Ce champ est requis.';

  @override
  String get errorEmail => 'Adresse email invalide.';

  @override
  String get errorPasswordLength => '10 caractères minimum.';

  @override
  String get errorInvalidCredentials => 'Email ou mot de passe incorrect.';

  @override
  String get errorEmailTaken => 'Un compte existe déjà avec cet email.';

  @override
  String get errorWrongPassword => 'Le mot de passe actuel est incorrect.';

  @override
  String get errorNetwork =>
      'Impossible de joindre Babel. Vérifiez votre connexion.';

  @override
  String get errorGeneric => 'Une erreur est survenue. Réessayez.';

  @override
  String apiConnected(String version) {
    return 'API connectée · v$version';
  }

  @override
  String get apiConnecting => 'Connexion à l’API…';

  @override
  String get apiUnreachable => 'API injoignable';

  @override
  String get accountTitle => 'Compte';

  @override
  String get accountProfile => 'Profil';

  @override
  String get accountSecurity => 'Sécurité';

  @override
  String get save => 'Enregistrer';

  @override
  String get saved => 'Enregistré.';

  @override
  String get currentPasswordLabel => 'Mot de passe actuel';

  @override
  String get newPasswordLabel => 'Nouveau mot de passe';

  @override
  String get setPassword => 'Définir un mot de passe';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get passwordChanged =>
      'Mot de passe modifié. Vos autres appareils ont été déconnectés.';

  @override
  String signedInWith(String providers) {
    return 'Connecté avec $providers';
  }

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get deleteAccount => 'Supprimer mon compte';

  @override
  String get deleteAccountTitle => 'Supprimer votre compte ?';

  @override
  String get deleteAccountBody =>
      'Votre bibliothèque, vos notes et vos statistiques seront définitivement effacées. Cette action est irréversible.';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String greetingMorning(String name) {
    return 'Bonjour, $name.';
  }

  @override
  String greetingEvening(String name) {
    return 'Bonsoir, $name.';
  }

  @override
  String get language => 'Langue';

  @override
  String get languageName => 'Français';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get forgotEyebrow => 'Mot de passe oublié';

  @override
  String get forgotTitle => 'Retrouvez l’accès à votre bibliothèque.';

  @override
  String get forgotLede =>
      'Indiquez l’email de votre compte : nous vous enverrons un lien pour choisir un nouveau mot de passe.';

  @override
  String get sendResetLink => 'Envoyer le lien';

  @override
  String resetLinkSent(String email) {
    return 'Si un compte existe pour $email, un email vient de lui être envoyé. Le lien est valable une heure.';
  }

  @override
  String get resetEyebrow => 'Nouveau mot de passe';

  @override
  String get resetTitle => 'Choisissez un nouveau mot de passe.';

  @override
  String get resetLede => 'Vos autres appareils seront déconnectés.';

  @override
  String get resetPasswordAction => 'Enregistrer le mot de passe';

  @override
  String get resetDone =>
      'Mot de passe enregistré. Vous pouvez vous connecter.';

  @override
  String get errorResetLink =>
      'Ce lien n’est plus valable. Demandez-en un nouveau.';

  @override
  String get backToSignIn => 'Retour à la connexion';

  @override
  String get verifyEyebrow => 'Confirmation';

  @override
  String get verifyTitle => 'Confirmation de votre adresse';

  @override
  String get verifyChecking => 'Vérification du lien…';

  @override
  String get verifyDone => 'Votre adresse est confirmée. Merci !';

  @override
  String get continueAction => 'Continuer';

  @override
  String get verifyBanner =>
      'Confirmez votre adresse email : nous vous avons envoyé un lien.';

  @override
  String get verifyResend => 'Renvoyer';

  @override
  String get verifyResent => 'Lien envoyé. Pensez à vérifier vos spams.';
}
