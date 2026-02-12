@echo off
title Stronghold Docker Setup
echo.
echo ========================================
echo   STRONGHOLD - Docker Setup
echo ========================================
echo.
echo   POKRETANJE:
echo   [1] Pokreni sve              - kontejneri su vec buildani, samo ih pokrece
echo   [2] Rebuild i pokreni        - rebuild backend koda pa pokreni (koristiti nakon promjene koda)
echo   [3] Zaustavi sve             - gasi kontejnere, podaci ostaju sacuvani
echo.
echo   RESET:
echo   [4] Reset baze               - brise bazu, rebuild, ponovo kreira seed podatke
echo   [5] Potpuno ciscenje          - brise SVE (kontejneri + slike + baza), koristiti [2] nakon
echo.
echo   DIJAGNOSTIKA:
echo   [6] Prikazi logove (API)      - prati sta API radi u realnom vremenu (Ctrl+C za izlaz)
echo   [7] Prikazi status            - provjeri koji kontejneri rade
echo   [8] Izlaz
echo.
echo   SERVISI KOJI SE POKRECU:
echo     SQL Server (baza)   - port 1401
echo     RabbitMQ (broker)   - port 5672, management UI na 15672
echo     API (.NET 8)        - port 5034, Swagger na http://localhost:5034/swagger
echo     Worker              - background servis za email notifikacije
echo.
echo   AKO NESTO NE RADI:
echo     [3] pa [1] (restart) -^> [3] pa [2] (rebuild) -^> [4] (reset baze) -^> [5] pa [2] (ispocetka)
echo.
set /p choice="Odaberi opciju [1-8]: "

if "%choice%"=="1" (
    echo.
    echo Pokrecem servise...
    docker-compose up -d
    echo.
    echo Servisi pokrenuti. API na http://localhost:5034
    pause
    goto :eof
)

if "%choice%"=="2" (
    echo.
    echo Rebuildujem i pokrecem...
    docker-compose up --build -d
    echo.
    echo Rebuild zavrsen. API na http://localhost:5034
    pause
    goto :eof
)

if "%choice%"=="3" (
    echo.
    echo Zaustavljam servise...
    docker-compose down
    echo Zaustavljeno.
    pause
    goto :eof
)

if "%choice%"=="4" (
    echo.
    echo UPOZORENJE: Ovo ce obrisati bazu i sve podatke!
    set /p confirm="Jesi li siguran? (da/ne): "
    if /i "%confirm%"=="da" (
        echo Zaustavljam i brisem volumene...
        docker-compose down -v
        echo Rebuildujem i pokrecem...
        docker-compose up --build -d
        echo.
        echo Reset zavrsen. Baza ce se ponovo kreirati sa seed podacima.
        pause
    ) else (
        echo Otkazano.
        pause
    )
    goto :eof
)

if "%choice%"=="5" (
    echo.
    echo UPOZORENJE: Ovo brise SVE - kontejnere, slike, volumene!
    echo Nakon ovoga pokreni opciju [2] za svjez start.
    set /p confirm="Jesi li siguran? (da/ne): "
    if /i "%confirm%"=="da" (
        echo Cistim sve...
        docker-compose down -v --rmi all
        echo.
        echo Sve obrisano. Pokreni opciju [2] za svjez start.
        pause
    ) else (
        echo Otkazano.
        pause
    )
    goto :eof
)

if "%choice%"=="6" (
    echo.
    echo Prikaz API logova (Ctrl+C za izlaz)...
    docker-compose logs -f api
    goto :eof
)

if "%choice%"=="7" (
    echo.
    docker-compose ps
    echo.
    pause
    goto :eof
)

if "%choice%"=="8" (
    goto :eof
)

echo Nepoznata opcija.
pause
