# Sistem preporuke — dokumentacija

Stronghold koristi **content-based filtering** za sekciju „Preporučeno za tebe" u
mobilnoj prodavnici, u skladu s prijavom rada: sličnost proizvoda se računa preko
**kategorije**, **dobavljača** i **recenzija**.

Implementacija: `Stronghold.Infrastructure/Services/RecommendationService.cs`
Endpoint: `GET /api/supplements/recommended` (rola `GymMember`)

## Ulazni signali

Svi signali nastaju stvarnim korištenjem aplikacije (ne postoje samo u seedu):

| Signal | Izvor | Kako nastaje |
|---|---|---|
| Kupovine | `OrderItems` (narudžbe koje nisu otkazane) | Stripe checkout u mobilnoj aplikaciji |
| Vlastite ocjene | `Reviews` korisnika | Recenzija dostavljenog proizvoda (1–5) |
| Ocjena zajednice | prosjek `Reviews` po proizvodu | Recenzije svih članova |

## Koraci algoritma

1. **Profil preferenci korisnika.** Za svaki kupljeni proizvod dodaje se težina
   afinitetu njegove kategorije i njegovog dobavljača. Osnovna težina kupovine je
   `1.0`, a množi se korisnikovom ocjenom tog proizvoda ako postoji:

   | Vlastita ocjena | Množilac |
   |---|---|
   | 5 | 2.0 |
   | 4 | 1.5 |
   | 3 | 1.0 |
   | 1–2 | 0.25 |

   Time visoko ocijenjeni kupljeni proizvodi jače „vuku" preporuke prema svojoj
   kategoriji/dobavljaču, a loše ocijenjeni ih gotovo isključuju.

2. **Kandidati.** Svi proizvodi koje korisnik **nije** kupio i koji su na stanju.

3. **Scoring.** Za svakog kandidata:

   ```
   score = 3.0 * afinitetKategorije(kandidat.kategorija)
         + 2.0 * afinitetDobavljača(kandidat.dobavljač)
         + 1.0 * (prosječnaOcjenaZajednice / 5)
   ```

   Sva tri signala stvarno učestvuju u konačnom poretku: kategorija nosi najviše
   (najjači indikator namjere), dobavljač srednje (lojalnost brendu), a ocjena
   zajednice razbija izjednačenja i gura kvalitetnije proizvode naviše.

4. **Rezultat.** Kandidati sa `score > 0` sortirani opadajuće; vraća se top 6.

## Objašnjivost

Uz svaku preporuku korisniku se prikazuje **zašto** je preporučena — poruka prati
dominantan signal u scoringu te preporuke:

- „Zato što ste kupili *Jumbo* iz kategorije *Mass gaineri*"
- „Zato što ste kupili *Iso Whey Zero* od proizvođača *BioTech USA*"
- dodatak „— visoko ocijenjen (4.5)" kada je prosječna ocjena zajednice ≥ 4.

## Hladan start

Korisnik bez ijedne kupovine dobija najbolje ocijenjene proizvode zajednice s
objašnjenjem „Popularno među članovima (prosječna ocjena X.X)", odnosno „Novo u
ponudi" za proizvode bez recenzija.
