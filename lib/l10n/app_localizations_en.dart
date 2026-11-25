// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EventRadar';

  @override
  String get discover => 'Discover something new';

  @override
  String get catalog => 'Events';

  @override
  String get profile => 'Profile';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Concert, sport, workshop…';

  @override
  String get allCities => 'All cities';

  @override
  String get allCategories => 'All categories';

  @override
  String get empty => 'No events yet. Try changing your search.';

  @override
  String get retry => 'Retry';

  @override
  String get networkError =>
      'Could not load data. Check your connection and retry.';

  @override
  String get actionError => 'Action failed. Please try again.';

  @override
  String get setup => 'Server not connected';

  @override
  String get setupBody =>
      'This is the first EventRadar build. Connect Supabase using the README to enable the catalog and sign-in.';

  @override
  String get foundation => 'Events in Tashkent and Fergana';

  @override
  String get more => 'Load more';

  @override
  String get details => 'About this event';

  @override
  String get organizer => 'Organizer';

  @override
  String get originalLanguage => 'Description language';

  @override
  String get save => 'Save event';

  @override
  String get unsave => 'Remove saved event';

  @override
  String get online => 'Online';

  @override
  String get offline => 'In person';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Create account';

  @override
  String get signOut => 'Sign out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get displayName => 'Name';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get invalidPassword => 'Use at least 12 characters';

  @override
  String get requiredField => 'This field is required';

  @override
  String get authError =>
      'Could not sign in or create an account. Check your details, email confirmation and connection.';

  @override
  String get checkEmail =>
      'Check your email to confirm your account, then sign in.';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Appearance';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get guest => 'Guest';

  @override
  String get guestBody =>
      'Browse without an account. Guest favorites stay on this device.';

  @override
  String get importFavorites => 'Import guest favorites';

  @override
  String get importDone =>
      'Favorites imported. Unavailable events remain on this device.';

  @override
  String get savedCount => 'Saved events';

  @override
  String get editName => 'Save name';

  @override
  String get nameSaved => 'Name saved';

  @override
  String get noPurchase =>
      'Online ticket sales are coming soon. Contact the organizer to attend.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete account?';

  @override
  String get deleteAccountBody =>
      'Your account, profile, saved events and other personal data will be permanently deleted. This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String get organizerHasEvents =>
      'Organizers with events must contact support to delete their account.';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get openInMaps => 'Open in Maps';
}
