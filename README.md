# TheStronghold

Gym management sistem sa .NET 8 backendom i Flutter klijentskim aplikacijama.

## Aplikacije

- **Desktop** (`stronghold_desktop`) - admin dashboard za upravljanje teretanom
- **Mobile** (`stronghold_mobile`) - mobilna aplikacija za clanove teretane

## Login podaci

### Desktop (Admin)
- Username: `desktop`
- Password: `test`

### Mobile (Clan)
- Username: `mobile`
- Password: `test`

## Pokretanje backend-a (Docker)

Preduvjeti: Docker i Docker Compose

```bash
cd Stronghold
docker-compose up --build
```

Ovo pokrece 4 servisa:
- **SQL Server** - baza podataka (port 1401)
- **RabbitMQ** - message broker (port 5672, management UI na 15672)
- **API** - .NET 8 Web API (port 5034)
- **Worker** - background servis za slanje email notifikacija

API je dostupan na `http://localhost:5034`, Swagger UI na `http://localhost:5034/swagger`.

Baza se automatski kreira, migrira i popunjava seed podacima pri prvom pokretanju.

Za reset baze:
```bash
docker-compose down -v
docker-compose up --build
```

## Pokretanje Flutter aplikacija

Preduvjeti: Flutter SDK

```bash
# Desktop
cd stronghold_desktop
flutter pub get
flutter run
```

```bash
# Mobile
cd stronghold_mobile
flutter pub get
flutter run
```

API adresa je konfigurabilna:
```bash
flutter run --dart-define=API_BASE_URL=http://localhost:5034
```

Za Android emulator: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5034`
Za fizicki uredaj: `flutter run --dart-define=API_BASE_URL=http://192.168.x.x:5034`

Default vrijednosti (`localhost:5034` za desktop, `10.0.2.2:5034` za mobile) rade bez dodatne konfiguracije.

## Struktura projekta

```
Stronghold/
├── Stronghold.API/              # Web API, kontroleri, middleware
├── Stronghold.Application/      # Servisi, DTO-ovi, interfejsi
├── Stronghold.Core/             # Entiteti, enumi
├── Stronghold.Infrastructure/   # EF Core, konfiguracije, implementacije servisa
├── Stronghold.Messaging/        # RabbitMQ modeli i konstante
├── Stronghold.Worker/           # Email queue consumer
├── docker-compose.yml
└── .env                         # Konfiguracijski podaci

stronghold_desktop/              # Flutter desktop (admin)
stronghold_mobile/               # Flutter mobile (clan)
packages/stronghold_core/        # Dijeljeni Flutter paket (modeli, servisi, API klijent)
```

## Konfiguracijski podaci

Svi konfiguracijski podaci (baza, JWT, Stripe, SMTP, RabbitMQ) su smjesteni u `Stronghold/.env` fajl i proslijedjuju se kontejnerima kroz docker-compose.

## Notifikacije

Sistem koristi RabbitMQ za asinkrono slanje email notifikacija:
- API objavljuje poruku na `email_queue`
- Worker servis prima poruku i salje email preko SMTP-a
- Notifikacije se salju pri isteku clanarine (3 dana i 1 dan prije)

## Tehnologije

**Backend:** .NET 8, Entity Framework Core, SQL Server, RabbitMQ, JWT, Stripe

**Frontend:** Flutter, Riverpod, Dart

**Infrastruktura:** Docker, Docker Compose
