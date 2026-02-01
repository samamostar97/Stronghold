@echo off
chcp 65001 >nul
title Stronghold Setup
echo ================================================================================
echo                     STRONGHOLD - POSTAVLJANJE OKRUZENJA
echo ================================================================================
echo.

:: Provjera da li .env vec postoji
if exist ".env" (
    echo [!] .env fajl vec postoji.
    set /p OVERWRITE="Zelite li ga prebrisati? (d/n): "
    if /i not "%OVERWRITE%"=="d" (
        echo Postavljanje otkazano.
        pause
        exit /b
    )
)

:: Pokusaj pronaci .env iz zip fajla
if exist "env.zip" (
    echo [*] Pronadjen env.zip - pokusavam ekstraktovati...
    echo.

    where 7z >nul 2>&1
    if %ERRORLEVEL%==0 (
        7z x env.zip -o. -y -pfit123 >nul 2>&1
        if exist ".env" (
            echo [OK] .env uspjesno ekstraktovan iz env.zip
            echo.
            echo ================================================================================
            echo Postavljanje zavrseno! Sada mozete pokrenuti:
            echo.
            echo     docker-compose up --build
            echo.
            echo ================================================================================
            pause
            exit /b
        )
    )

    echo [!] Nije moguce automatski ekstraktovati zip.
    echo     Molimo ekstraktujte env.zip rucno koristeci lozinku: fit123
    echo     Zatim ponovo pokrenite ovaj skript.
    echo.
    pause
    exit /b
)

:: Zip nije pronadjen - rucni unos
echo [!] env.zip nije pronadjen. Rucno postavljanje .env fajla...
echo.
echo Molimo unesite konfiguracijske vrijednosti ispod.
echo Pritisnite Enter da prihvatite podrazumijevanu vrijednost u zagradama.
echo.

:: Baza podataka
echo --- Konfiguracija baze podataka ---
set /p DB_PASSWORD="DB_PASSWORD [YourStrong@Password123]: "
if "%DB_PASSWORD%"=="" set DB_PASSWORD=YourStrong@Password123

:: JWT
echo.
echo --- JWT Konfiguracija ---
set /p JWT_SECRET="JWT_SECRET [unesite string od min 32 karaktera]: "
if "%JWT_SECRET%"=="" (
    echo [!] JWT_SECRET je obavezan.
    pause
    exit /b
)

:: Stripe
echo.
echo --- Stripe Konfiguracija ---
set /p STRIPE_SECRET_KEY="STRIPE_SECRET_KEY: "
if "%STRIPE_SECRET_KEY%"=="" (
    echo [!] STRIPE_SECRET_KEY je obavezan.
    pause
    exit /b
)

:: SMTP
echo.
echo --- Email (SMTP) Konfiguracija ---
set /p SMTP_USERNAME="SMTP_USERNAME (email adresa): "
if "%SMTP_USERNAME%"=="" (
    echo [!] SMTP_USERNAME je obavezan.
    pause
    exit /b
)
set /p SMTP_PASSWORD="SMTP_PASSWORD (app lozinka): "
if "%SMTP_PASSWORD%"=="" (
    echo [!] SMTP_PASSWORD je obavezan.
    pause
    exit /b
)

:: Kreiranje .env fajla
echo.
echo [*] Kreiranje .env fajla...

(
echo # Baza podataka
echo DB_SERVER=sqlserver
echo DB_NAME=StrongholdDb
echo DB_USER=sa
echo DB_PASSWORD=%DB_PASSWORD%
echo.
echo # JWT
echo JWT_SECRET=%JWT_SECRET%
echo JWT_ISSUER=Stronghold
echo JWT_AUDIENCE=StrongholdApp
echo.
echo # Stripe
echo STRIPE_SECRET_KEY=%STRIPE_SECRET_KEY%
echo.
echo # Email ^(SMTP^)
echo SMTP_HOST=smtp.gmail.com
echo SMTP_PORT=587
echo SMTP_USERNAME=%SMTP_USERNAME%
echo SMTP_PASSWORD=%SMTP_PASSWORD%
echo SMTP_USE_SSL=true
echo.
echo # RabbitMQ
echo RABBITMQ_HOST=rabbitmq
echo RABBITMQ_PORT=5672
echo RABBITMQ_USER=guest
echo RABBITMQ_PASSWORD=guest
echo.
echo # Razvoj
echo CLEAR_DATABASE=false
) > .env

echo [OK] .env fajl uspjesno kreiran!
echo.
echo ================================================================================
echo Postavljanje zavrseno! Sada mozete pokrenuti:
echo.
echo     docker-compose up --build
echo.
echo ================================================================================
pause
