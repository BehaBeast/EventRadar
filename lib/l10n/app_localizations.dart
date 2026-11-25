import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'EventRadar'**
  String get appTitle;

  /// No description provided for @discover.
  ///
  /// In ru, this message translates to:
  /// **'Открывай новое'**
  String get discover;

  /// No description provided for @catalog.
  ///
  /// In ru, this message translates to:
  /// **'Мероприятия'**
  String get catalog;

  /// No description provided for @profile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profile;

  /// No description provided for @search.
  ///
  /// In ru, this message translates to:
  /// **'Найти'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In ru, this message translates to:
  /// **'Концерт, спорт, мастер-класс…'**
  String get searchHint;

  /// No description provided for @allCities.
  ///
  /// In ru, this message translates to:
  /// **'Все города'**
  String get allCities;

  /// No description provided for @allCategories.
  ///
  /// In ru, this message translates to:
  /// **'Все категории'**
  String get allCategories;

  /// No description provided for @empty.
  ///
  /// In ru, this message translates to:
  /// **'Мероприятий пока нет. Попробуй изменить поиск.'**
  String get empty;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @networkError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить данные. Проверь подключение и повтори.'**
  String get networkError;

  /// No description provided for @actionError.
  ///
  /// In ru, this message translates to:
  /// **'Действие не выполнено. Попробуй ещё раз.'**
  String get actionError;

  /// No description provided for @setup.
  ///
  /// In ru, this message translates to:
  /// **'Сервер не подключён'**
  String get setup;

  /// No description provided for @setupBody.
  ///
  /// In ru, this message translates to:
  /// **'Это первая сборка EventRadar. Для каталога и входа нужно подключить Supabase по инструкции в README.'**
  String get setupBody;

  /// No description provided for @foundation.
  ///
  /// In ru, this message translates to:
  /// **'Первая версия • каталог и профиль'**
  String get foundation;

  /// No description provided for @more.
  ///
  /// In ru, this message translates to:
  /// **'Показать ещё'**
  String get more;

  /// No description provided for @details.
  ///
  /// In ru, this message translates to:
  /// **'О мероприятии'**
  String get details;

  /// No description provided for @organizer.
  ///
  /// In ru, this message translates to:
  /// **'Организатор'**
  String get organizer;

  /// No description provided for @originalLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык описания'**
  String get originalLanguage;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'В избранное'**
  String get save;

  /// No description provided for @unsave.
  ///
  /// In ru, this message translates to:
  /// **'Убрать из избранного'**
  String get unsave;

  /// No description provided for @online.
  ///
  /// In ru, this message translates to:
  /// **'Онлайн'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In ru, this message translates to:
  /// **'Офлайн'**
  String get offline;

  /// No description provided for @signIn.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get signOut;

  /// No description provided for @email.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get password;

  /// No description provided for @displayName.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get displayName;

  /// No description provided for @invalidEmail.
  ///
  /// In ru, this message translates to:
  /// **'Введи корректный email'**
  String get invalidEmail;

  /// No description provided for @invalidPassword.
  ///
  /// In ru, this message translates to:
  /// **'Не менее 12 символов'**
  String get invalidPassword;

  /// No description provided for @requiredField.
  ///
  /// In ru, this message translates to:
  /// **'Заполни поле'**
  String get requiredField;

  /// No description provided for @authError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось войти или создать аккаунт. Проверь данные, подтверждение email и соединение.'**
  String get authError;

  /// No description provided for @checkEmail.
  ///
  /// In ru, this message translates to:
  /// **'Проверь почту для подтверждения аккаунта. Затем войди.'**
  String get checkEmail;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get system;

  /// No description provided for @light.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get dark;

  /// No description provided for @guest.
  ///
  /// In ru, this message translates to:
  /// **'Гость'**
  String get guest;

  /// No description provided for @guestBody.
  ///
  /// In ru, this message translates to:
  /// **'Смотри мероприятия без регистрации. Избранное гостя сохраняется на этом устройстве.'**
  String get guestBody;

  /// No description provided for @importFavorites.
  ///
  /// In ru, this message translates to:
  /// **'Перенести избранное гостя'**
  String get importFavorites;

  /// No description provided for @importDone.
  ///
  /// In ru, this message translates to:
  /// **'Избранное перенесено. Недоступные мероприятия оставлены на устройстве.'**
  String get importDone;

  /// No description provided for @savedCount.
  ///
  /// In ru, this message translates to:
  /// **'Сохранённые мероприятия'**
  String get savedCount;

  /// No description provided for @editName.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить имя'**
  String get editName;

  /// No description provided for @nameSaved.
  ///
  /// In ru, this message translates to:
  /// **'Имя сохранено'**
  String get nameSaved;

  /// No description provided for @noPurchase.
  ///
  /// In ru, this message translates to:
  /// **'Онлайн-продажа билетов скоро появится. Для участия свяжитесь с организатором.'**
  String get noPurchase;

  /// No description provided for @deleteAccount.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт, профиль, избранное и другие персональные данные будут удалены навсегда. Это действие нельзя отменить.'**
  String get deleteAccountBody;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @accountDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт удалён'**
  String get accountDeleted;

  /// No description provided for @organizerHasEvents.
  ///
  /// In ru, this message translates to:
  /// **'Организатор с мероприятиями может удалить аккаунт только через поддержку.'**
  String get organizerHasEvents;

  /// No description provided for @privacyPolicy.
  ///
  /// In ru, this message translates to:
  /// **'Политика конфиденциальности'**
  String get privacyPolicy;
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
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
