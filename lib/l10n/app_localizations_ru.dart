// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'EventRadar';

  @override
  String get discover => 'Открывай новое';

  @override
  String get catalog => 'Мероприятия';

  @override
  String get profile => 'Профиль';

  @override
  String get search => 'Найти';

  @override
  String get searchHint => 'Концерт, спорт, мастер-класс…';

  @override
  String get allCities => 'Все города';

  @override
  String get allCategories => 'Все категории';

  @override
  String get empty => 'Мероприятий пока нет. Попробуй изменить поиск.';

  @override
  String get retry => 'Повторить';

  @override
  String get networkError =>
      'Не удалось загрузить данные. Проверь подключение и повтори.';

  @override
  String get actionError => 'Действие не выполнено. Попробуй ещё раз.';

  @override
  String get setup => 'Сервер не подключён';

  @override
  String get setupBody =>
      'Это первая сборка EventRadar. Для каталога и входа нужно подключить Supabase по инструкции в README.';

  @override
  String get foundation => 'Мероприятия Ташкента и Ферганы';

  @override
  String get more => 'Показать ещё';

  @override
  String get details => 'О мероприятии';

  @override
  String get organizer => 'Организатор';

  @override
  String get originalLanguage => 'Язык описания';

  @override
  String get save => 'В избранное';

  @override
  String get unsave => 'Убрать из избранного';

  @override
  String get online => 'Онлайн';

  @override
  String get offline => 'Офлайн';

  @override
  String get signIn => 'Войти';

  @override
  String get signUp => 'Создать аккаунт';

  @override
  String get signOut => 'Выйти';

  @override
  String get email => 'Email';

  @override
  String get password => 'Пароль';

  @override
  String get displayName => 'Имя';

  @override
  String get invalidEmail => 'Введи корректный email';

  @override
  String get invalidPassword => 'Не менее 12 символов';

  @override
  String get requiredField => 'Заполни поле';

  @override
  String get authError =>
      'Не удалось войти или создать аккаунт. Проверь данные, подтверждение email и соединение.';

  @override
  String get checkEmail =>
      'Проверь почту для подтверждения аккаунта. Затем войди.';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Оформление';

  @override
  String get system => 'Как в системе';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Тёмная';

  @override
  String get guest => 'Гость';

  @override
  String get guestBody =>
      'Смотри мероприятия без регистрации. Избранное гостя сохраняется на этом устройстве.';

  @override
  String get importFavorites => 'Перенести избранное гостя';

  @override
  String get importDone =>
      'Избранное перенесено. Недоступные мероприятия оставлены на устройстве.';

  @override
  String get savedCount => 'Сохранённые мероприятия';

  @override
  String get editName => 'Сохранить имя';

  @override
  String get nameSaved => 'Имя сохранено';

  @override
  String get noPurchase =>
      'Онлайн-продажа билетов скоро появится. Для участия свяжитесь с организатором.';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountTitle => 'Удалить аккаунт?';

  @override
  String get deleteAccountBody =>
      'Аккаунт, профиль, избранное и другие персональные данные будут удалены навсегда. Это действие нельзя отменить.';

  @override
  String get cancel => 'Отмена';

  @override
  String get accountDeleted => 'Аккаунт удалён';

  @override
  String get organizerHasEvents =>
      'Организатор с мероприятиями может удалить аккаунт только через поддержку.';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get openInMaps => 'Открыть на карте';
}
