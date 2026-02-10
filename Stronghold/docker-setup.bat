@echo off
title Stronghold Docker Setup
echo.
echo ========================================
echo   STRONGHOLD - Docker Setup
echo ========================================
echo.
echo   SVAKODNEVNE OPCIJE:
echo   [1] Pokreni sve - koristi kad su kontejneri vec buildani, samo ih pokrece
echo   [2] Rebuild i pokreni - koristi NAKON PROMJENE KODA u backendu (.NET)
echo   [5] Zaustavi sve - gasi kontejnere, podaci ostaju sacuvani
echo.
echo   RESET OPCIJE:
echo   [3] Reset baze - brise bazu i ponovo pokrece seed podatke, rebuild sve
echo   [4] Potpuno ciscenje - brise SVE (kontejneri + slike + baza), nakon ovoga koristi [2]
echo.
echo   DIJAGNOSTIKA:
echo   [6] Prikazi logove (API) - prati sta API radi u realnom vremenu
echo   [7] Prikazi status kontejnera - provjeri da li sve radi
echo   [8] Izlaz
echo.
echo   REDOSLIJED AKO NESTO NE RADI:
echo   1. Probaj [5] pa [1] (restart)
echo   2. Ako ne pomaze, probaj [5] pa [2] (rebuild)
echo   3. Ako ni to, probaj [3] (reset baze)
echo   4. Zadnja opcija: [4] pa [2] (sve ispocetka)
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

if "%choice%"=="4" (
    echo.
    echo UPOZORENJE: Ovo brise SVE - kontejnere, slike, volumene!
    echo Nakon ovoga moras pokrenuti opciju [2] za svjez start.
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

if "%choice%"=="5" (
    echo.
    echo Zaustavljam servise...
    docker-compose down
    echo Zaustavljeno.
    pause
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
