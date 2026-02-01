# Stronghold

Stronghold je aplikacija za upravljanje teretanom koja se sastoji od ASP.NET Core API-a, desktop Flutter aplikacije i mobilne Flutter aplikacije.

## Pokretanje aplikacije

### 1. Pokretanje backend servisa (API, baza, RabbitMQ, Worker)


cd Stronghold
docker compose up --build


Ovo pokrece sljedece servise:
- **API** - `http://localhost:5034`
- **SQL Server** - `localhost:1433`
- **RabbitMQ** - `localhost:5672` (management: `http://localhost:15672`)
- **Email Worker** - pozadinski servis za slanje emailova

Svi konfiguracijski podaci se nalaze u `Stronghold/.env` fajlu.

### 2. Pokretanje desktop aplikacije


cd stronghold_desktop
flutter pub get
flutter run


### 3. Pokretanje mobilne aplikacije


cd stronghold_mobile
flutter pub get
flutter run


> Za fizicki uredaj koristite: `flutter run --dart-define=API_BASE_URL=http://192.168.x.x:5034`

## Korisnicki podaci za pristup

Aplikacija ima dvije korisnicke uloge:

### Desktop verzija (Admin)

Korisnicko ime    Password
admin             test   

### Mobilna verzija (GymMember)

Korisnicko ime    Password
member            test  

### Na mobilnoj verziji seedano jos usera
