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
- RabbitMQ management: http://localhost:15672 (stronghold / stronghold123)

## Funkcionalnosti

**Desktop (administrator):** dashboard sa statistikom i nedavnim aktivnostima
(undo u roku 1h), biznis report sa PDF/Excel exportom, leaderboard, korisnici,
članarine i uplate, check-in praćenje posjeta, treneri i nutricionisti, termini
sa slobodnim satnicama, suplementi/kategorije/dobavljači, narudžbe (isporuka i
otkazivanje uz Stripe refund), seminari sa učesnicima, recenzije, FAQ, gradovi,
paketi članarina.

**Mobile (član):** registracija i prijava, reset lozinke kodom na e-mail, profil
sa XP nivoom i analitikom napretka, rang lista, prodavnica sa personalizovanim
preporukama ("Preporučeno za tebe"), korpa i Stripe checkout (test kartica
`4242 4242 4242 4242`, bilo koji budući datum i CVC), historija narudžbi sa
recenzijama, zakazivanje termina, seminari, notifikacije, FAQ.

**Pozadinski servisi:** RabbitMQ + Worker šalju stvarne e-mailove (potvrde
narudžbi, termini, podsjetnici o isteku članarine i seminarima).

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
