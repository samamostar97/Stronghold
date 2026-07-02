# Stronghold

Sistem za upravljanje teretanom — seminarski rad iz predmeta Razvoj softvera II.

## Komponente

| Komponenta | Tehnologija | Namjena |
|---|---|---|
| Backend API | .NET 8 Web API (Clean Architecture) + SQL Server | REST servis za obje aplikacije |
| Worker servis | .NET Worker Service + RabbitMQ | E-mailovi i periodični podsjetnici |
| Desktop aplikacija | Flutter (Windows) | Administrator teretane |
| Mobilna aplikacija | Flutter (Android) | Članovi teretane |

## Pokretanje

Potreban je samo Docker (Docker Desktop na Windowsu):

```bash
docker compose up --build
```

Time se podižu SQL Server, RabbitMQ, API i Worker. Baza se automatski kreira,
migrira i puni test podacima pri prvom startu — nije potreban nijedan ručni korak.

- API + Swagger: http://localhost:5000/swagger
- RabbitMQ management: http://localhost:15672

Napomena: SQL Serveru na svježoj mašini treba 20–60 sekundi da postane spreman;
API čeka i automatski ponavlja povezivanje.

### Flutter aplikacije

```bash
# Desktop (Windows)
cd UI/stronghold_desktop
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:5000

# Mobile (Android emulator)
cd UI/stronghold_mobile
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000
```

## Kredencijali

| Kontekst | Korisničko ime | Lozinka |
|---|---|---|
| Desktop verzija | `desktop` | `test` |
| Mobilna verzija | `mobile` | `test` |
| Više korisničkih uloga (Admin) | `admin` | `test` |
| Više korisničkih uloga (GymMember) | `gymmember` | `test` |
