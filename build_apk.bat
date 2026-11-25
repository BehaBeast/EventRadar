@echo off
chcp 65001 > nul
echo ===================================================
echo        Сборка APK приложения EventRadar
echo ===================================================
echo.

where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [ОШИБКА] Flutter SDK не обнаружен в системе или не добавлен в PATH!
    echo.
    echo Для сборки APK на этом компьютере необходимо:
    echo 1. Установить Flutter SDK: https://docs.flutter.dev/get-started/install/windows
    echo 2. Установить Android Studio с Android SDK (API 34) и JDK 17
    echo 3. Добавить flutter/bin в переменную среды PATH
    echo 4. Запустить: flutter doctor
    echo.
    echo Либо загрузите проект на GitHub — автоматический GitHub Actions
    echo workflow (.github/workflows/build_apk.yml) соберёт APK в облаке!
    echo.
    pause
    exit /b 1
)

echo [1/4] Копирование тестовой конфигурации...
if not exist config.json (
    copy config.example.json config.json
)

echo [2/4] Загрузка зависимостей (flutter pub get)...
call flutter pub get
if %errorlevel% neq 0 goto error

echo [3/4] Генерация локализаций (flutter gen-l10n)...
call flutter gen-l10n
if %errorlevel% neq 0 goto error

echo [4/4] Сборка APK (flutter build apk --debug)...
call flutter build apk --debug --dart-define-from-file=config.json
if %errorlevel% neq 0 goto error

echo.
echo ===================================================
echo [УСПЕХ] APK успешно собран!
echo Файл находится по пути:
echo build\app\outputs\flutter-apk\app-debug.apk
echo ===================================================
echo.
pause
exit /b 0

:error
echo.
echo [ОШИБКА] Произошла ошибка во время сборки APK!
pause
exit /b 1

