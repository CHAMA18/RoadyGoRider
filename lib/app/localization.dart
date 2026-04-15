import 'package:flutter/material.dart';

import 'app.dart';

class AppStrings {
  static const appTitle = 'appTitle';
  static const settings = 'settings';
  static const appAppearance = 'appAppearance';
  static const language = 'language';
  static const getInTouch = 'getInTouch';
  static const notifications = 'notifications';
  static const wallet = 'wallet';
  static const aboutWallet = 'aboutWallet';
  static const topUp = 'topUp';
  static const defaultTips = 'defaultTips';
  static const transactions = 'transactions';
  static const noTip = 'noTip';
  static const promo = 'promo';
  static const yourCoupons = 'yourCoupons';
  static const inviteFriends = 'inviteFriends';
  static const savedPlaces = 'savedPlaces';
  static const addAPlace = 'addAPlace';
  static const saveYourFavoritePlaces = 'saveYourFavoritePlaces';
  static const noOrdersYet = 'noOrdersYet';
  static const historyIsToMake = 'historyIsToMake';
  static const enterPhoneNumberToStart = 'enterPhoneNumberToStart';
  static const iAgreeTo = 'iAgreeTo';
  static const termsAndConditions = 'termsAndConditions';
  static const privacyPolicy = 'privacyPolicy';
  static const aboutUs = 'aboutUs';
  static const requestCode = 'requestCode';
  static const phoneNumber = 'phoneNumber';
  static const codeSentTo = 'codeSentTo';
  static const sendAgainIn = 'sendAgainIn';
  static const sendCodeAgain = 'sendCodeAgain';
  static const resendCodeConfirmation = 'resendCodeConfirmation';
  static const useDeviceSettings = 'useDeviceSettings';
  static const lightMode = 'lightMode';
  static const darkMode = 'darkMode';
  static const chooseLanguageDescription = 'chooseLanguageDescription';
  static const currentLanguage = 'currentLanguage';
  static const searchLanguages = 'searchLanguages';
  static const noLanguagesMatch = 'noLanguagesMatch';
  static const callUs = 'callUs';
  static const emailUs = 'emailUs';
  static const addAPhoto = 'addAPhoto';
  static const save = 'save';
  static const name = 'name';
  static const email = 'email';
  static const tripSummaryEmailHint = 'tripSummaryEmailHint';
  static const emergencyContactNumber = 'emergencyContactNumber';
  static const deleteMyAccount = 'deleteMyAccount';
  static const logOut = 'logOut';
  static const topUpWallet = 'topUpWallet';
  static const dontAidFraud = 'dontAidFraud';
  static const food = 'food';
  static const ride = 'ride';
  static const addWork = 'addWork';
  static const profile = 'profile';
  static const becomeADriver = 'becomeADriver';
  static const myOrders = 'myOrders';
  static const quickAccess = 'quickAccess';
  static const account = 'account';
  static const activity = 'activity';
  static const signOut = 'signOut';
  static const go = 'go';
  static const newBadge = 'newBadge';
  static const adBadge = 'adBadge';
  static const happyYouthDay = 'happyYouthDay';
  static const freeConcertTickets = 'freeConcertTickets';
  static const marchPromos = 'marchPromos';
  static const freeTrip = 'freeTrip';
  static const setPickupAddress = 'setPickupAddress';
  static const setDestinationAddress = 'setDestinationAddress';
  static const setPickupPoint = 'setPickupPoint';
  static const dropOffAddress = 'dropOffAddress';
  static const taxi = 'taxi';
  static const delivery = 'delivery';
  static const cargo = 'cargo';
  static const standardTaxi = 'standardTaxi';
  static const comfortTaxi = 'comfortTaxi';
  static const vipTaxi = 'vipTaxi';
  static const bicycleCourier = 'bicycleCourier';
  static const motorcycleCourier = 'motorcycleCourier';
  static const minivan = 'minivan';
  static const panelVan = 'panelVan';
  static const lightTruck = 'lightTruck';
  static const fromPrice = 'fromPrice';
  static const now = 'now';
  static const cash = 'cash';
  static const continueLabel = 'continueLabel';
  static const searchForAPlace = 'searchForAPlace';
  static const mapFailedToLoad = 'mapFailedToLoad';
  static const addMapsApiKey = 'addMapsApiKey';
  static const welcomeBackTitle = 'welcomeBackTitle';
  static const authScreenSubtitle = 'authScreenSubtitle';
  static const loginTitle = 'loginTitle';
  static const loginSubtitle = 'loginSubtitle';
  static const createAccountTitle = 'createAccountTitle';
  static const createAccountSubtitle = 'createAccountSubtitle';
  static const logIn = 'logIn';
  static const createAccount = 'createAccount';
  static const fullName = 'fullName';
  static const fullNameHint = 'fullNameHint';
  static const emailAddress = 'emailAddress';
  static const emailHint = 'emailHint';
  static const password = 'password';
  static const passwordHint = 'passwordHint';
  static const forgotPassword = 'forgotPassword';
  static const alreadyHaveAccount = 'alreadyHaveAccount';
  static const newHerePrompt = 'newHerePrompt';
  static const enterYourName = 'enterYourName';
  static const enterValidEmail = 'enterValidEmail';
  static const enterPhoneNumberToContinue = 'enterPhoneNumberToContinue';
  static const passwordTooShort = 'passwordTooShort';
  static const acceptTermsToContinue = 'acceptTermsToContinue';
  static const failedToSendVerificationCode = 'failedToSendVerificationCode';
  static const phoneNumberHint = 'phoneNumberHint';
  static const confirmPassword = 'confirmPassword';
  static const confirmPasswordHint = 'confirmPasswordHint';
  static const passwordsDoNotMatch = 'passwordsDoNotMatch';
  static const scheduleAppointment = 'scheduleAppointment';
  static const enterPromoCode = 'enterPromoCode';
  static const noCoupons = 'noCoupons';
  static const done = 'done';
}

class AppLocalizations {
  const AppLocalizations(this.language);

  final String language;

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(RoadyGoRiderApp.of(context).selectedLanguage);
  }

  String text(String key, {Map<String, String> params = const {}}) {
    final languageKey = _resolveLanguage(language);
    final langMap = _translations[languageKey];
    final fallbackMap = _translations['English'];

    String template = key;
    if (langMap != null && langMap[key] != null) {
      template = langMap[key]!;
    } else if (fallbackMap != null && fallbackMap[key] != null) {
      template = fallbackMap[key]!;
    }

    return _interpolate(template, params);
  }

  String _interpolate(String template, Map<String, String> params) {
    var result = template;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  static String _resolveLanguage(String language) {
    if (_translations.containsKey(language)) {
      return language;
    }

    const families = {
      'Basque': 'Spanish',
      'Catalan': 'Spanish',
      'Galician': 'Portuguese',
      'Corsican': 'Italian',
      'Luxembourgish': 'German',
      'Welsh': 'English',
      'Irish': 'English',
      'Breton': 'French',
      'Danish': 'German',
      'Norwegian': 'German',
      'Swedish': 'German',
      'Finnish': 'English',
      'Icelandic': 'English',
      'Estonian': 'English',
      'Latvian': 'English',
      'Lithuanian': 'English',
      'Belarusian': 'Russian',
      'Bosnian': 'English',
      'Bulgarian': 'Russian',
      'Czech': 'Polish',
      'Hungarian': 'Romanian',
      'Macedonian': 'Russian',
      'Slovak': 'Polish',
      'Slovene': 'English',
      'Ukrainian': 'Russian',
      'Armenian': 'Russian',
      'Azerbaijani': 'Turkish',
      'Georgian': 'Russian',
      'Kazakh': 'Russian',
      'Kurdish': 'Turkish',
      'Maltese': 'Italian',
      'Sami': 'English',
      'Serbian': 'Russian',
      'Tatar': 'Russian',
      'Croatian': 'English',
    };
    return families[language] ?? 'English';
  }
}

extension LocalizationBuildContext on BuildContext {
  String tr(String key, {Map<String, String> params = const {}}) {
    return AppLocalizations.of(this).text(key, params: params);
  }
}

const Map<String, Map<String, String>> _translations = {
  'English': {
    AppStrings.appTitle: 'Vunigo',
    AppStrings.settings: 'Settings',
    AppStrings.appAppearance: 'App appearance',
    AppStrings.language: 'Language',
    AppStrings.getInTouch: 'Get in touch',
    AppStrings.notifications: 'Notifications',
    AppStrings.wallet: 'Wallet',
    AppStrings.aboutWallet: 'About wallet',
    AppStrings.topUp: 'Top up',
    AppStrings.defaultTips: 'Default tips',
    AppStrings.transactions: 'Transactions',
    AppStrings.noTip: 'No tip',
    AppStrings.promo: 'Promo',
    AppStrings.yourCoupons: 'Your coupons',
    AppStrings.inviteFriends: 'Invite friends',
    AppStrings.savedPlaces: 'Saved places',
    AppStrings.addAPlace: 'Add a place',
    AppStrings.saveYourFavoritePlaces: 'Save your favorite places',
    AppStrings.noOrdersYet: 'No orders yet.',
    AppStrings.historyIsToMake: 'History is to make!',
    AppStrings.enterPhoneNumberToStart: 'Enter your phone number to start',
    AppStrings.iAgreeTo: 'I agree to ',
    AppStrings.termsAndConditions: 'Terms and Conditions',
    AppStrings.privacyPolicy: 'Privacy Policy',
    AppStrings.aboutUs: 'About Us',
    AppStrings.requestCode: 'Request code',
    AppStrings.phoneNumber: 'Phone number',
    AppStrings.codeSentTo: 'Code sent via SMS, WhatsApp, or Viber to',
    AppStrings.sendAgainIn: 'Send again in {time}',
    AppStrings.sendCodeAgain: 'Send code again',
    AppStrings.resendCodeConfirmation:
        'A new verification code was sent to {phone}.',
    AppStrings.useDeviceSettings: 'Use device settings',
    AppStrings.lightMode: 'Light mode',
    AppStrings.darkMode: 'Dark mode',
    AppStrings.chooseLanguageDescription:
        'Choose the language you want to use in Vunigo.',
    AppStrings.currentLanguage: 'Current language',
    AppStrings.searchLanguages: 'Search languages',
    AppStrings.noLanguagesMatch: 'No languages match your search.',
    AppStrings.callUs: 'Call us',
    AppStrings.emailUs: 'Email us',
    AppStrings.addAPhoto: 'Add a photo',
    AppStrings.save: 'Save',
    AppStrings.name: 'Name',
    AppStrings.email: 'Email',
    AppStrings.tripSummaryEmailHint:
        "We'll send your trip summaries or invoices to this email",
    AppStrings.emergencyContactNumber: 'Emergency contact number (SOS button)',
    AppStrings.deleteMyAccount: 'Delete my account',
    AppStrings.logOut: 'Log out',
    AppStrings.topUpWallet: 'Top up wallet',
    AppStrings.dontAidFraud: "Don't Aid Fraud",
    AppStrings.food: 'Food',
    AppStrings.ride: 'Ride',
    AppStrings.addWork: 'Add work',
    AppStrings.profile: 'Profile',
    AppStrings.becomeADriver: 'Become a driver',
    AppStrings.myOrders: 'My orders',
    AppStrings.quickAccess: 'Quick access',
    AppStrings.account: 'Account',
    AppStrings.activity: 'Activity',
    AppStrings.signOut: 'Sign out',
    AppStrings.go: 'Go',
    AppStrings.newBadge: 'New',
    AppStrings.adBadge: 'Ad',
    AppStrings.happyYouthDay: 'Happy Youth Day!',
    AppStrings.freeConcertTickets: 'Want Free Concert Tickets?',
    AppStrings.marchPromos: 'March Promos',
    AppStrings.freeTrip: 'Win A Free Trip!',
    AppStrings.setPickupAddress: 'Set pick-up address',
    AppStrings.setDestinationAddress: 'Set destination address',
    AppStrings.setPickupPoint: 'Set pick-up point',
    AppStrings.dropOffAddress: 'Drop-off address',
    AppStrings.taxi: 'Taxi',
    AppStrings.delivery: 'Delivery',
    AppStrings.cargo: 'Cargo',
    AppStrings.standardTaxi: 'Standard',
    AppStrings.comfortTaxi: 'Comfort',
    AppStrings.vipTaxi: 'VIP',
    AppStrings.bicycleCourier: 'Bicycle Courier',
    AppStrings.motorcycleCourier: 'Motorcycle Courier',
    AppStrings.minivan: 'Minivan',
    AppStrings.panelVan: 'Panel Van',
    AppStrings.lightTruck: 'Light Truck',
    AppStrings.fromPrice: 'From {price}',
    AppStrings.now: 'Now',
    AppStrings.cash: 'Cash', // You can translate this to 'Para në dorë' or keep 'Cash'
    AppStrings.continueLabel: 'Continue',
    AppStrings.scheduleAppointment: 'Schedule appointment',
    AppStrings.searchForAPlace: 'Search for a place',
    AppStrings.mapFailedToLoad: 'Map failed to load.',
    AppStrings.addMapsApiKey: 'Add GOOGLE_MAPS_API_KEY to show the map.',
    AppStrings.welcomeBackTitle: 'Your next move starts here',
    AppStrings.authScreenSubtitle:
        'Log in to manage your fleet and premium logistics dashboard with precision.',
    AppStrings.loginTitle: 'Log in',
    AppStrings.loginSubtitle:
        'Enter your phone number and password, then confirm with a secure verification code.',
    AppStrings.createAccountTitle: 'Create account',
    AppStrings.createAccountSubtitle:
        'Create your Vunigo account and verify your phone to unlock premium access.',
    AppStrings.logIn: 'Log in',
    AppStrings.createAccount: 'Create account',
    AppStrings.fullName: 'Full name',
    AppStrings.fullNameHint: 'Enter your full name',
    AppStrings.emailAddress: 'Email address',
    AppStrings.emailHint: 'name@example.com',
    AppStrings.password: 'Password',
    AppStrings.passwordHint: 'Enter your password',
    AppStrings.forgotPassword: 'Forgot password?',
    AppStrings.alreadyHaveAccount: 'Already have an account?',
    AppStrings.newHerePrompt: 'New to Vunigo?',
    AppStrings.enterYourName: 'Enter your full name to continue.',
    AppStrings.enterValidEmail: 'Enter a valid email address to continue.',
    AppStrings.enterPhoneNumberToContinue:
        'Enter a valid phone number to continue.',
    AppStrings.passwordTooShort: 'Password must be at least 6 characters long.',
    AppStrings.acceptTermsToContinue:
        'Accept the terms and conditions to continue.',
    AppStrings.failedToSendVerificationCode:
        'Failed to send verification code. Check Firebase setup.',
    AppStrings.phoneNumberHint: 'Enter your mobile number',
    AppStrings.confirmPassword: 'Confirm password',
    AppStrings.confirmPasswordHint: 'Re-enter your password',
    AppStrings.passwordsDoNotMatch: 'Passwords do not match.',
    AppStrings.enterPromoCode: 'Enter promo code',
    AppStrings.noCoupons: 'No coupons',
    AppStrings.done: 'Done',
  },
  'Albanian': {
    AppStrings.settings: 'Cilesimet',
    AppStrings.appAppearance: 'Pamja e aplikacionit',
    AppStrings.language: 'Gjuha',
    AppStrings.getInTouch: 'Na kontaktoni',
    AppStrings.privacyPolicy: 'Politika e privatesise',
    AppStrings.termsAndConditions: 'Kushtet e sherbimit',
    AppStrings.aboutUs: 'Rreth nesh',
    AppStrings.notifications: 'Njoftime',
    AppStrings.wallet: 'Portofoli',
    AppStrings.aboutWallet: 'Rreth portofolit',
    AppStrings.topUp: 'Mbush',
    AppStrings.defaultTips: 'Bakshishet e parazgjedhura',
    AppStrings.transactions: 'Transaksionet',
    AppStrings.noTip: 'Pa bakshish',
    AppStrings.promo: 'Promocione',
    AppStrings.yourCoupons: 'Kuponat tuaj',
    AppStrings.inviteFriends: 'Ftoni miq',
    AppStrings.savedPlaces: 'Vende te ruajtura',
    AppStrings.addAPlace: 'Shto vend',
    AppStrings.saveYourFavoritePlaces: 'Ruani vendet tuaja te preferuara',
    AppStrings.noOrdersYet: 'Ende nuk ka porosi.',
    AppStrings.historyIsToMake: 'Historia sapo nis!',
    AppStrings.enterPhoneNumberToStart:
        'Shkruani numrin e telefonit per te filluar',
    AppStrings.iAgreeTo: 'Jam dakord me ',
    AppStrings.requestCode: 'Kerko kodin',
    AppStrings.phoneNumber: 'Numri i telefonit',
    AppStrings.codeSentTo: 'Kodi u dergua me SMS, WhatsApp ose Viber ne',
    AppStrings.sendAgainIn: 'Dergo perseri pas {time}',
    AppStrings.sendCodeAgain: 'Dergo kodin perseri',
    AppStrings.resendCodeConfirmation:
        'Nje kod i ri verifikimi u dergua ne {phone}.',
    AppStrings.useDeviceSettings: 'Perdor cilesimet e pajisjes',
    AppStrings.lightMode: 'Menyra e ndricuar',
    AppStrings.darkMode: 'Menyra e erret',
    AppStrings.chooseLanguageDescription:
        'Zgjidhni gjuhen qe deshironi te perdorni ne Vunigo.',
    AppStrings.currentLanguage: 'Gjuha aktuale',
    AppStrings.searchLanguages: 'Kerko gjuhet',
    AppStrings.noLanguagesMatch: 'Asnje gjuhe nuk perputhet me kerkimin tuaj.',
    AppStrings.callUs: 'Na telefononi',
    AppStrings.emailUs: 'Na dergoni email',
    AppStrings.addAPhoto: 'Shto nje foto',
    AppStrings.save: 'Ruaj',
    AppStrings.name: 'Emri',
    AppStrings.email: 'Email',
    AppStrings.tripSummaryEmailHint:
        'Do t\'ju dergojme permbledhjet e udhetimeve ose faturat ne kete email',
    AppStrings.emergencyContactNumber:
        'Numri i kontaktit emergjent (butoni SOS)',
    AppStrings.deleteMyAccount: 'Fshi llogarine time',
    AppStrings.logOut: 'Dil',
    AppStrings.topUpWallet: 'Mbush portofolin',
    AppStrings.dontAidFraud: 'Mos ndihmo mashtrimin',
    AppStrings.food: 'Ushqim',
    AppStrings.ride: 'Udhetim',
    AppStrings.addWork: 'Shto pune',
    AppStrings.profile: 'Profili',
    AppStrings.becomeADriver: 'Behu shofer',
    AppStrings.myOrders: 'Porosite e mia',
    AppStrings.quickAccess: 'Qasje e shpejte',
    AppStrings.account: 'Llogaria',
    AppStrings.activity: 'Aktiviteti',
    AppStrings.signOut: 'Dil',
    AppStrings.go: 'Shko',
    AppStrings.newBadge: 'I ri',
    AppStrings.adBadge: 'Reklame',
    AppStrings.happyYouthDay: 'Gezuar Diten e Rinise!',
    AppStrings.freeConcertTickets: 'Deshironi bileta falas per koncert?',
    AppStrings.marchPromos: 'Promocionet e marsit',
    AppStrings.freeTrip: 'Fito nje udhetim falas!',
    AppStrings.setPickupAddress: 'Vendos adresen e marrjes',
    AppStrings.setDestinationAddress: 'Vendos adresen e destinacionit',
    AppStrings.setPickupPoint: 'Vendos piken e marrjes',
    AppStrings.dropOffAddress: 'Adresa e zbritjes',
    AppStrings.taxi: 'Taksi',
    AppStrings.delivery: 'Dergese',
    AppStrings.cargo: 'Ngarkese',
    AppStrings.standardTaxi: 'Standarde',
    AppStrings.comfortTaxi: 'Komode',
    AppStrings.vipTaxi: 'VIP',
    AppStrings.bicycleCourier: 'Korrier me biciklete',
    AppStrings.motorcycleCourier: 'Korrier me motor',
    AppStrings.minivan: 'Minivan',
    AppStrings.panelVan: 'Furgon panel',
    AppStrings.lightTruck: 'Kamion i lehte',
    AppStrings.fromPrice: 'Nga {price}',
    AppStrings.now: 'Tani',
    AppStrings.cash: 'Para ne dore',
    AppStrings.continueLabel: 'Vazhdo',
    AppStrings.searchForAPlace: 'Kerkoni nje vend',
    AppStrings.mapFailedToLoad: 'Harta deshtoi te ngarkohet.',
    AppStrings.addMapsApiKey:
        'Shtoni GOOGLE_MAPS_API_KEY per te shfaqur harten.',
  },
  'French': {
    AppStrings.settings: 'Parametres',
    AppStrings.appAppearance: 'Apparence de l\'application',
    AppStrings.language: 'Langue',
    AppStrings.getInTouch: 'Nous contacter',
    AppStrings.privacyPolicy: 'Politique de confidentialite',
    AppStrings.termsAndConditions: 'Termes et conditions',
    AppStrings.aboutUs: 'A propos de nous',
    AppStrings.notifications: 'Notifications',
    AppStrings.wallet: 'Portefeuille',
    AppStrings.aboutWallet: 'A propos du portefeuille',
    AppStrings.topUp: 'Recharger',
    AppStrings.defaultTips: 'Pourboires par defaut',
    AppStrings.transactions: 'Transactions',
    AppStrings.noTip: 'Aucun pourboire',
    AppStrings.promo: 'Promos',
    AppStrings.yourCoupons: 'Vos coupons',
    AppStrings.inviteFriends: 'Inviter des amis',
    AppStrings.savedPlaces: 'Lieux enregistres',
    AppStrings.requestCode: 'Demander le code',
    AppStrings.phoneNumber: 'Numero de telephone',
    AppStrings.codeSentTo: 'Code envoye par SMS, WhatsApp ou Viber au',
    AppStrings.sendAgainIn: 'Renvoyer dans {time}',
    AppStrings.sendCodeAgain: 'Renvoyer le code',
    AppStrings.resendCodeConfirmation:
        'Un nouveau code de verification a ete envoye au {phone}.',
    AppStrings.useDeviceSettings: 'Utiliser les reglages de l\'appareil',
    AppStrings.lightMode: 'Mode clair',
    AppStrings.darkMode: 'Mode sombre',
    AppStrings.chooseLanguageDescription:
        'Choisissez la langue a utiliser dans Vunigo.',
    AppStrings.currentLanguage: 'Langue actuelle',
    AppStrings.searchLanguages: 'Rechercher des langues',
    AppStrings.callUs: 'Appelez-nous',
    AppStrings.emailUs: 'Envoyez-nous un e-mail',
    AppStrings.topUpWallet: 'Recharger le portefeuille',
    AppStrings.food: 'Repas',
    AppStrings.ride: 'Course',
    AppStrings.profile: 'Profil',
    AppStrings.taxi: 'Taxi',
    AppStrings.delivery: 'Livraison',
    AppStrings.cargo: 'Cargo',
    AppStrings.standardTaxi: 'Standard',
    AppStrings.comfortTaxi: 'Confort',
    AppStrings.vipTaxi: 'VIP',
    AppStrings.bicycleCourier: 'Coursier a velo',
    AppStrings.motorcycleCourier: 'Coursier a moto',
    AppStrings.minivan: 'Minivan',
    AppStrings.panelVan: 'Fourgon',
    AppStrings.lightTruck: 'Camion leger',
    AppStrings.fromPrice: 'A partir de {price}',
    AppStrings.now: 'Maintenant',
    AppStrings.cash: 'Especes',
    AppStrings.continueLabel: 'Continuer',
  },
  'German': {
    AppStrings.settings: 'Einstellungen',
    AppStrings.appAppearance: 'App-Darstellung',
    AppStrings.language: 'Sprache',
    AppStrings.getInTouch: 'Kontakt',
    AppStrings.privacyPolicy: 'Datenschutzrichtlinie',
    AppStrings.termsAndConditions: 'Allgemeine Geschaftsbedingungen',
    AppStrings.aboutUs: 'Uber uns',
    AppStrings.notifications: 'Benachrichtigungen',
    AppStrings.wallet: 'Geldborse',
    AppStrings.topUp: 'Aufladen',
    AppStrings.noTip: 'Kein Trinkgeld',
    AppStrings.requestCode: 'Code anfordern',
    AppStrings.phoneNumber: 'Telefonnummer',
    AppStrings.codeSentTo: 'Code per SMS, WhatsApp oder Viber gesendet an',
    AppStrings.sendAgainIn: 'Erneut senden in {time}',
    AppStrings.sendCodeAgain: 'Code erneut senden',
    AppStrings.useDeviceSettings: 'Gerateeinstellungen verwenden',
    AppStrings.lightMode: 'Heller Modus',
    AppStrings.darkMode: 'Dunkler Modus',
    AppStrings.chooseLanguageDescription:
        'Wahlen Sie die Sprache, die Sie in Vunigo verwenden mochten.',
    AppStrings.currentLanguage: 'Aktuelle Sprache',
    AppStrings.searchLanguages: 'Sprachen suchen',
    AppStrings.topUpWallet: 'Geldborse aufladen',
    AppStrings.food: 'Essen',
    AppStrings.ride: 'Fahrt',
    AppStrings.profile: 'Profil',
    AppStrings.taxi: 'Taxi',
    AppStrings.delivery: 'Lieferung',
    AppStrings.cargo: 'Fracht',
    AppStrings.standardTaxi: 'Standard',
    AppStrings.comfortTaxi: 'Komfort',
    AppStrings.vipTaxi: 'VIP',
    AppStrings.bicycleCourier: 'Fahrradkurier',
    AppStrings.motorcycleCourier: 'Motorradkurier',
    AppStrings.panelVan: 'Kastenwagen',
    AppStrings.lightTruck: 'Leichter Lkw',
    AppStrings.fromPrice: 'Ab {price}',
    AppStrings.now: 'Jetzt',
    AppStrings.cash: 'Bar',
    AppStrings.continueLabel: 'Weiter',
  },
  'Spanish': {
    AppStrings.settings: 'Configuracion',
    AppStrings.appAppearance: 'Apariencia de la aplicacion',
    AppStrings.language: 'Idioma',
    AppStrings.getInTouch: 'Contactanos',
    AppStrings.privacyPolicy: 'Politica de privacidad',
    AppStrings.termsAndConditions: 'Terminos y condiciones',
    AppStrings.aboutUs: 'Sobre nosotros',
    AppStrings.notifications: 'Notificaciones',
    AppStrings.wallet: 'Billetera',
    AppStrings.topUp: 'Recargar',
    AppStrings.requestCode: 'Solicitar codigo',
    AppStrings.phoneNumber: 'Numero de telefono',
    AppStrings.codeSentTo: 'Codigo enviado por SMS, WhatsApp o Viber a',
    AppStrings.sendAgainIn: 'Enviar de nuevo en {time}',
    AppStrings.sendCodeAgain: 'Enviar codigo otra vez',
    AppStrings.useDeviceSettings: 'Usar ajustes del dispositivo',
    AppStrings.lightMode: 'Modo claro',
    AppStrings.darkMode: 'Modo oscuro',
    AppStrings.chooseLanguageDescription:
        'Elige el idioma que deseas usar en Vunigo.',
    AppStrings.currentLanguage: 'Idioma actual',
    AppStrings.searchLanguages: 'Buscar idiomas',
    AppStrings.topUpWallet: 'Recargar billetera',
    AppStrings.food: 'Comida',
    AppStrings.ride: 'Viaje',
    AppStrings.profile: 'Perfil',
    AppStrings.taxi: 'Taxi',
    AppStrings.delivery: 'Entrega',
    AppStrings.cargo: 'Carga',
    AppStrings.standardTaxi: 'Estandar',
    AppStrings.comfortTaxi: 'Confort',
    AppStrings.vipTaxi: 'VIP',
    AppStrings.bicycleCourier: 'Mensajero en bicicleta',
    AppStrings.motorcycleCourier: 'Mensajero en motocicleta',
    AppStrings.fromPrice: 'Desde {price}',
    AppStrings.now: 'Ahora',
    AppStrings.cash: 'Efectivo',
    AppStrings.continueLabel: 'Continuar',
  },
  'Italian': {
    AppStrings.settings: 'Impostazioni',
    AppStrings.appAppearance: 'Aspetto dell\'app',
    AppStrings.language: 'Lingua',
    AppStrings.getInTouch: 'Contattaci',
    AppStrings.privacyPolicy: 'Informativa sulla privacy',
    AppStrings.termsAndConditions: 'Termini e condizioni',
    AppStrings.aboutUs: 'Chi siamo',
    AppStrings.notifications: 'Notifiche',
    AppStrings.wallet: 'Portafoglio',
    AppStrings.topUp: 'Ricarica',
    AppStrings.requestCode: 'Richiedi codice',
    AppStrings.phoneNumber: 'Numero di telefono',
    AppStrings.codeSentTo: 'Codice inviato tramite SMS, WhatsApp o Viber a',
    AppStrings.sendAgainIn: 'Invia di nuovo tra {time}',
    AppStrings.sendCodeAgain: 'Invia di nuovo il codice',
    AppStrings.useDeviceSettings: 'Usa le impostazioni del dispositivo',
    AppStrings.lightMode: 'Modalita chiara',
    AppStrings.darkMode: 'Modalita scura',
    AppStrings.chooseLanguageDescription:
        'Scegli la lingua da usare in Vunigo.',
    AppStrings.currentLanguage: 'Lingua corrente',
    AppStrings.searchLanguages: 'Cerca lingue',
    AppStrings.topUpWallet: 'Ricarica portafoglio',
    AppStrings.food: 'Cibo',
    AppStrings.ride: 'Corsa',
    AppStrings.profile: 'Profilo',
    AppStrings.taxi: 'Taxi',
    AppStrings.delivery: 'Consegna',
    AppStrings.cargo: 'Carico',
    AppStrings.standardTaxi: 'Standard',
    AppStrings.comfortTaxi: 'Comfort',
    AppStrings.vipTaxi: 'VIP',
    AppStrings.fromPrice: 'Da {price}',
    AppStrings.now: 'Ora',
    AppStrings.cash: 'Contanti',
    AppStrings.continueLabel: 'Continua',
  },
  'Portuguese': {
    AppStrings.settings: 'Definicoes',
    AppStrings.appAppearance: 'Aparencia da aplicacao',
    AppStrings.language: 'Idioma',
    AppStrings.getInTouch: 'Entre em contacto',
    AppStrings.privacyPolicy: 'Politica de privacidade',
    AppStrings.termsAndConditions: 'Termos e condicoes',
    AppStrings.aboutUs: 'Sobre nos',
    AppStrings.notifications: 'Notificacoes',
    AppStrings.wallet: 'Carteira',
    AppStrings.topUp: 'Carregar',
    AppStrings.requestCode: 'Solicitar codigo',
    AppStrings.phoneNumber: 'Numero de telefone',
    AppStrings.codeSentTo: 'Codigo enviado por SMS, WhatsApp ou Viber para',
    AppStrings.sendAgainIn: 'Enviar novamente em {time}',
    AppStrings.sendCodeAgain: 'Enviar codigo novamente',
    AppStrings.useDeviceSettings: 'Usar definicoes do dispositivo',
    AppStrings.lightMode: 'Modo claro',
    AppStrings.darkMode: 'Modo escuro',
    AppStrings.chooseLanguageDescription:
        'Escolha o idioma que pretende usar no Vunigo.',
    AppStrings.currentLanguage: 'Idioma atual',
    AppStrings.searchLanguages: 'Pesquisar idiomas',
    AppStrings.topUpWallet: 'Carregar carteira',
    AppStrings.food: 'Comida',
    AppStrings.ride: 'Viagem',
    AppStrings.profile: 'Perfil',
    AppStrings.taxi: 'Taxi',
    AppStrings.delivery: 'Entrega',
    AppStrings.cargo: 'Carga',
    AppStrings.standardTaxi: 'Padrao',
    AppStrings.comfortTaxi: 'Conforto',
    AppStrings.vipTaxi: 'VIP',
    AppStrings.fromPrice: 'A partir de {price}',
    AppStrings.now: 'Agora',
    AppStrings.cash: 'Dinheiro',
    AppStrings.continueLabel: 'Continuar',
  },
  'Dutch': {
    AppStrings.settings: 'Instellingen',
    AppStrings.appAppearance: 'App-weergave',
    AppStrings.language: 'Taal',
    AppStrings.getInTouch: 'Neem contact op',
    AppStrings.privacyPolicy: 'Privacybeleid',
    AppStrings.termsAndConditions: 'Algemene voorwaarden',
    AppStrings.aboutUs: 'Over ons',
    AppStrings.notifications: 'Meldingen',
    AppStrings.wallet: 'Portemonnee',
    AppStrings.requestCode: 'Code aanvragen',
    AppStrings.phoneNumber: 'Telefoonnummer',
    AppStrings.codeSentTo: 'Code verzonden via sms, WhatsApp of Viber naar',
    AppStrings.sendAgainIn: 'Opnieuw verzenden over {time}',
    AppStrings.sendCodeAgain: 'Code opnieuw verzenden',
    AppStrings.useDeviceSettings: 'Apparaatinstellingen gebruiken',
    AppStrings.lightMode: 'Lichte modus',
    AppStrings.darkMode: 'Donkere modus',
    AppStrings.chooseLanguageDescription:
        'Kies de taal die je wilt gebruiken in Vunigo.',
    AppStrings.currentLanguage: 'Huidige taal',
    AppStrings.searchLanguages: 'Talen zoeken',
    AppStrings.topUpWallet: 'Portemonnee opwaarderen',
    AppStrings.food: 'Eten',
    AppStrings.ride: 'Rit',
    AppStrings.profile: 'Profiel',
    AppStrings.delivery: 'Bezorging',
    AppStrings.fromPrice: 'Vanaf {price}',
    AppStrings.now: 'Nu',
    AppStrings.cash: 'Contant',
  },
  'Polish': {
    AppStrings.settings: 'Ustawienia',
    AppStrings.appAppearance: 'Wyglad aplikacji',
    AppStrings.language: 'Jezyk',
    AppStrings.getInTouch: 'Skontaktuj sie z nami',
    AppStrings.privacyPolicy: 'Polityka prywatnosci',
    AppStrings.termsAndConditions: 'Regulamin',
    AppStrings.aboutUs: 'O nas',
    AppStrings.notifications: 'Powiadomienia',
    AppStrings.wallet: 'Portfel',
    AppStrings.requestCode: 'Popros o kod',
    AppStrings.phoneNumber: 'Numer telefonu',
    AppStrings.codeSentTo: 'Kod wyslano przez SMS, WhatsApp lub Viber na',
    AppStrings.sendAgainIn: 'Wyslij ponownie za {time}',
    AppStrings.sendCodeAgain: 'Wyslij kod ponownie',
    AppStrings.useDeviceSettings: 'Uzyj ustawien urzadzenia',
    AppStrings.lightMode: 'Tryb jasny',
    AppStrings.darkMode: 'Tryb ciemny',
    AppStrings.chooseLanguageDescription:
        'Wybierz jezyk, ktorego chcesz uzywac w Vunigo.',
    AppStrings.currentLanguage: 'Biezacy jezyk',
    AppStrings.searchLanguages: 'Szukaj jezykow',
    AppStrings.food: 'Jedzenie',
    AppStrings.ride: 'Przejazd',
    AppStrings.delivery: 'Dostawa',
    AppStrings.fromPrice: 'Od {price}',
    AppStrings.now: 'Teraz',
    AppStrings.cash: 'Gotowka',
    AppStrings.continueLabel: 'Kontynuuj',
  },
  'Greek': {
    AppStrings.settings: 'Rythmiseis',
    AppStrings.appAppearance: 'Emfanisi efarmogis',
    AppStrings.language: 'Glossa',
    AppStrings.getInTouch: 'Epikoinoniste mazi mas',
    AppStrings.privacyPolicy: 'Politiki aporritou',
    AppStrings.termsAndConditions: 'Oroi kai proupotheseis',
    AppStrings.aboutUs: 'Schetika me emas',
    AppStrings.notifications: 'Eidopoiiseis',
    AppStrings.wallet: 'Portofoli',
    AppStrings.requestCode: 'Zitise kodiko',
    AppStrings.phoneNumber: 'Arithmos tilefonou',
    AppStrings.codeSentTo: 'O kodikos stalthike me SMS, WhatsApp i Viber sto',
    AppStrings.sendAgainIn: 'Steilto xana se {time}',
    AppStrings.sendCodeAgain: 'Steile ton kodiko xana',
    AppStrings.useDeviceSettings: 'Xrisimopoiste tis rythmiseis syskevis',
    AppStrings.lightMode: 'Anoichti leitourgia',
    AppStrings.darkMode: 'Skoteini leitourgia',
    AppStrings.chooseLanguageDescription:
        'Epilexte ti glossa pou thelete na xrisimopoieite sto Vunigo.',
    AppStrings.currentLanguage: 'Trexousa glossa',
    AppStrings.searchLanguages: 'Anazitisi glosson',
    AppStrings.food: 'Fagito',
    AppStrings.ride: 'Diadromi',
    AppStrings.delivery: 'Paradosi',
    AppStrings.fromPrice: 'Apo {price}',
    AppStrings.now: 'Tora',
    AppStrings.cash: 'Metrita',
    AppStrings.continueLabel: 'Synexeia',
  },
  'Romanian': {
    AppStrings.settings: 'Setari',
    AppStrings.appAppearance: 'Aspectul aplicatiei',
    AppStrings.language: 'Limba',
    AppStrings.getInTouch: 'Contacteaza-ne',
    AppStrings.privacyPolicy: 'Politica de confidentialitate',
    AppStrings.termsAndConditions: 'Termeni si conditii',
    AppStrings.aboutUs: 'Despre noi',
    AppStrings.notifications: 'Notificari',
    AppStrings.wallet: 'Portofel',
    AppStrings.requestCode: 'Solicita codul',
    AppStrings.phoneNumber: 'Numar de telefon',
    AppStrings.codeSentTo: 'Cod trimis prin SMS, WhatsApp sau Viber la',
    AppStrings.sendAgainIn: 'Trimite din nou in {time}',
    AppStrings.sendCodeAgain: 'Trimite codul din nou',
    AppStrings.useDeviceSettings: 'Foloseste setarile dispozitivului',
    AppStrings.lightMode: 'Mod luminos',
    AppStrings.darkMode: 'Mod intunecat',
    AppStrings.chooseLanguageDescription:
        'Alegeti limba pe care doriti sa o folositi in Vunigo.',
    AppStrings.currentLanguage: 'Limba curenta',
    AppStrings.searchLanguages: 'Cauta limbi',
    AppStrings.food: 'Mancare',
    AppStrings.ride: 'Cursa',
    AppStrings.delivery: 'Livrare',
    AppStrings.fromPrice: 'De la {price}',
    AppStrings.now: 'Acum',
    AppStrings.cash: 'Numerar',
    AppStrings.continueLabel: 'Continua',
  },
  'Turkish': {
    AppStrings.settings: 'Ayarlar',
    AppStrings.appAppearance: 'Uygulama gorunumu',
    AppStrings.language: 'Dil',
    AppStrings.getInTouch: 'Bize ulasin',
    AppStrings.privacyPolicy: 'Gizlilik politikasi',
    AppStrings.termsAndConditions: 'Sartlar ve kosullar',
    AppStrings.aboutUs: 'Hakkimizda',
    AppStrings.notifications: 'Bildirimler',
    AppStrings.wallet: 'Cuzdan',
    AppStrings.requestCode: 'Kod iste',
    AppStrings.phoneNumber: 'Telefon numarasi',
    AppStrings.codeSentTo:
        'Kod SMS, WhatsApp veya Viber ile su numaraya gonderildi',
    AppStrings.sendAgainIn: '{time} sonra tekrar gonder',
    AppStrings.sendCodeAgain: 'Kodu tekrar gonder',
    AppStrings.useDeviceSettings: 'Cihaz ayarlarini kullan',
    AppStrings.lightMode: 'Acik mod',
    AppStrings.darkMode: 'Koyu mod',
    AppStrings.chooseLanguageDescription:
        'Vunigo\'da kullanmak istediginiz dili secin.',
    AppStrings.currentLanguage: 'Gecerli dil',
    AppStrings.searchLanguages: 'Dilleri ara',
    AppStrings.food: 'Yemek',
    AppStrings.ride: 'Surus',
    AppStrings.delivery: 'Teslimat',
    AppStrings.fromPrice: '{price} itibaren',
    AppStrings.now: 'Simdi',
    AppStrings.cash: 'Nakit',
    AppStrings.continueLabel: 'Devam et',
  },
  'Russian': {
    AppStrings.settings: 'Nastroiki',
    AppStrings.appAppearance: 'Vneshniy vid prilozheniya',
    AppStrings.language: 'Yazyk',
    AppStrings.getInTouch: 'Svyazatsya s nami',
    AppStrings.privacyPolicy: 'Politika konfidentsialnosti',
    AppStrings.termsAndConditions: 'Usloviya ispolzovaniya',
    AppStrings.aboutUs: 'O nas',
    AppStrings.notifications: 'Uvedomleniya',
    AppStrings.wallet: 'Koshelek',
    AppStrings.requestCode: 'Zaprosit kod',
    AppStrings.phoneNumber: 'Nomer telefona',
    AppStrings.codeSentTo: 'Kod otpravlen po SMS, WhatsApp ili Viber na',
    AppStrings.sendAgainIn: 'Otpravit snova cherez {time}',
    AppStrings.sendCodeAgain: 'Otpravit kod snova',
    AppStrings.useDeviceSettings: 'Ispolzovat nastroiki ustroystva',
    AppStrings.lightMode: 'Svetlyy rezhim',
    AppStrings.darkMode: 'Temnyy rezhim',
    AppStrings.chooseLanguageDescription:
        'Vyberite yazyk, kotoryy vy hotite ispolzovat v Vunigo.',
    AppStrings.currentLanguage: 'Tekushchiy yazyk',
    AppStrings.searchLanguages: 'Poisk yazykov',
    AppStrings.food: 'Eda',
    AppStrings.ride: 'Poezdka',
    AppStrings.delivery: 'Dostavka',
    AppStrings.cargo: 'Gruz',
    AppStrings.fromPrice: 'Ot {price}',
    AppStrings.now: 'Seichas',
    AppStrings.cash: 'Nalichnye',
    AppStrings.continueLabel: 'Prodolzhit',
  },
};
