using System.Reflection;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Security;

namespace Stronghold.Infrastructure.Data;

/// <summary>
/// Puni bazu test podacima pri prvom pokretanju - dovoljno zapisa da svaki ekran
/// i grafikon odmah ima podatke. Propisani test nalozi: desktop/test, mobile/test,
/// admin/test, gymmember/test.
/// </summary>
public static class DatabaseSeeder
{
    private const string TestPassword = "test";

    public static async Task SeedAsync(StrongholdDbContext db, ILogger logger)
    {
        if (await db.Users.AnyAsync())
        {
            logger.LogInformation("Baza vec sadrzi podatke - seed preskocen.");
            return;
        }

        logger.LogInformation("Seedanje baze...");
        var now = DateTime.UtcNow;
        var random = new Random(2024);

        await using var transaction = await db.Database.BeginTransactionAsync();

        // ---------- Gradovi ----------
        var cityNames = new[]
        {
            "Mostar", "Sarajevo", "Banja Luka", "Tuzla", "Zenica", "Bihać",
            "Travnik", "Široki Brijeg", "Konjic", "Čapljina", "Trebinje", "Doboj"
        };
        var cities = cityNames.Select(n => new City { Name = n }).ToList();
        db.Cities.AddRange(cities);

        // ---------- Korisnici ----------
        User NewUser(string username, string firstName, string lastName, string email, string phone,
            UserRole role, string image, City city, string street, int createdDaysAgo)
        {
            var salt = PasswordHasher.GenerateSalt();
            return new User
            {
                Username = username,
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                Phone = phone,
                Role = role,
                ImageData = LoadImage(image),
                City = city,
                StreetAddress = street,
                PasswordSalt = salt,
                PasswordHash = PasswordHasher.Hash(TestPassword, salt),
                CreatedAt = now.AddDays(-createdDaysAgo)
            };
        }

        var desktop = NewUser("desktop", "Sanin", "Šehić", "sanin.sehic@stronghold.ba", "061-111-222",
            UserRole.Admin, "user_desktop.png", cities[0], "Maršala Tita 15", 120);
        var admin = NewUser("admin", "Ajla", "Kurtović", "ajla.kurtovic@stronghold.ba", "061-111-333",
            UserRole.Admin, "user_admin.png", cities[0], "Braće Fejića 4", 120);
        var mobile = NewUser("mobile", "Amar", "Begić", "amar.begic@gmail.com", "062-333-444",
            UserRole.GymMember, "user_mobile.png", cities[0], "Kneza Domagoja 12", 90);
        var gymMember = NewUser("gymmember", "Goran", "Perić", "goran.peric@gmail.com", "063-555-666",
            UserRole.GymMember, "user_gymmember.png", cities[7], "Fra Didaka Buntića 8", 30);
        var dino = NewUser("dino.hadzic", "Dino", "Hadžić", "dino.hadzic@gmail.com", "061-234-567",
            UserRole.GymMember, "user_dino.png", cities[1], "Ferhadija 21", 85);
        var lejla = NewUser("lejla.mujic", "Lejla", "Mujić", "lejla.mujic@gmail.com", "062-345-678",
            UserRole.GymMember, "user_lejla.png", cities[0], "Splitska 3", 80);
        var tarik = NewUser("tarik.kovacevic", "Tarik", "Kovačević", "tarik.kovacevic@gmail.com", "063-456-789",
            UserRole.GymMember, "user_tarik.png", cities[3], "Turalibegova 40", 75);
        var amina = NewUser("amina.softic", "Amina", "Softić", "amina.softic@gmail.com", "061-567-890",
            UserRole.GymMember, "user_amina.png", cities[1], "Zmaja od Bosne 12", 70);
        var haris = NewUser("haris.delic", "Haris", "Delić", "haris.delic@gmail.com", "062-678-901",
            UserRole.GymMember, "user_haris.png", cities[4], "Masarikova 9", 65);
        var sara = NewUser("sara.omerovic", "Sara", "Omerović", "sara.omerovic@gmail.com", "063-789-012",
            UserRole.GymMember, "user_sara.png", cities[0], "Bulevar 22", 60);
        var kenan = NewUser("kenan.basic", "Kenan", "Bašić", "kenan.basic@gmail.com", "061-890-123",
            UserRole.GymMember, "user_kenan.png", cities[8], "Sarajevska 5", 55);
        var ilma = NewUser("ilma.zukic", "Ilma", "Zukić", "ilma.zukic@gmail.com", "062-901-234",
            UserRole.GymMember, "user_ilma.png", cities[5], "Bosanska 17", 50);
        var adnan = NewUser("adnan.colic", "Adnan", "Čolić", "adnan.colic@gmail.com", "063-012-345",
            UserRole.GymMember, "user_adnan.png", cities[9], "Trg kralja Tomislava 2", 55);
        var merima = NewUser("merima.hodzic", "Merima", "Hodžić", "merima.hodzic@gmail.com", "061-123-456",
            UserRole.GymMember, "user_merima.png", cities[2], "Kralja Petra I 30", 45);

        var users = new[]
        {
            desktop, admin, mobile, gymMember, dino, lejla, tarik,
            amina, haris, sara, kenan, ilma, adnan, merima
        };
        db.Users.AddRange(users);

        // korisnici se snimaju odmah da bi narudzbe imale StatusChangedByUserId (audit polje)
        await db.SaveChangesAsync();

        // ---------- Paketi clanarina ----------
        var monthly = new MembershipPackage
        {
            Name = "Mjesečni",
            Price = 40.00m,
            DurationDays = 30,
            Description = "Neograničen pristup teretani tokom 30 dana. Idealno za isprobavanje ili kraći boravak."
        };
        var quarterly = new MembershipPackage
        {
            Name = "Tromjesečni",
            Price = 105.00m,
            DurationDays = 90,
            Description = "Tri mjeseca treniranja po povoljnijoj cijeni - ušteda 15 KM u odnosu na mjesečno plaćanje."
        };
        var halfYear = new MembershipPackage
        {
            Name = "Polugodišnji",
            Price = 190.00m,
            DurationDays = 180,
            Description = "Šest mjeseci neograničenog pristupa uz značajnu uštedu za redovne vježbače."
        };
        var yearly = new MembershipPackage
        {
            Name = "Godišnji",
            Price = 350.00m,
            DurationDays = 365,
            Description = "Najisplativiji paket - cijela godina treniranja uz najveću uštedu i prioritet pri zakazivanju termina."
        };
        db.MembershipPackages.AddRange(monthly, quarterly, halfYear, yearly);

        // ---------- Clanarine i uplate ----------
        var memberships = new List<Membership>();

        Membership NewMembership(User user, MembershipPackage package, int startDaysAgo,
            bool revoked = false, int? revokedDaysAgo = null, string? reason = null)
        {
            var start = now.AddDays(-startDaysAgo);
            var membership = new Membership
            {
                User = user,
                Package = package,
                StartDate = start,
                EndDate = start.AddDays(package.DurationDays),
                IsRevoked = revoked,
                RevokedAt = revokedDaysAgo.HasValue ? now.AddDays(-revokedDaysAgo.Value) : null,
                RevocationReason = reason
            };
            membership.Payments.Add(new Payment { Amount = package.Price, PaidAt = start });
            memberships.Add(membership);
            return membership;
        }

        // aktivne clanarine koje pokrivaju zadnjih ~60 dana (radi posjeta i grafikona)
        NewMembership(mobile, quarterly, 60);
        NewMembership(dino, quarterly, 62);
        NewMembership(lejla, quarterly, 58);
        NewMembership(tarik, halfYear, 70);
        NewMembership(amina, quarterly, 61);
        NewMembership(haris, quarterly, 59);
        NewMembership(sara, yearly, 60);
        // krace aktivne
        NewMembership(kenan, monthly, 15);
        NewMembership(ilma, monthly, 12);
        NewMembership(gymMember, monthly, 5);
        // istekla (adnan) - posjete samo unutar tog perioda
        NewMembership(adnan, monthly, 50);
        // ukinuta (merima)
        NewMembership(merima, quarterly, 40, revoked: true, revokedDaysAgo: 10,
            reason: "Zahtjev korisnika - preseljenje u drugi grad");
        // historijska istekla clanarina za mobile (historija uplata)
        NewMembership(mobile, monthly, 95);

        db.Memberships.AddRange(memberships);

        // ---------- Posjete (osnova za XP i leaderboard) ----------
        var visits = new List<GymVisit>();

        void AddVisits(User user, int windowStartDaysAgo, int windowEndDaysAgo, int visitsPerWeek)
        {
            for (var d = windowStartDaysAgo; d > windowEndDaysAgo; d--)
            {
                if (random.Next(7) >= visitsPerWeek)
                {
                    continue;
                }
                var checkIn = now.Date.AddDays(-d).AddHours(random.Next(8, 21)).AddMinutes(random.Next(60));
                var durationMinutes = random.Next(50, 130);
                visits.Add(new GymVisit
                {
                    User = user,
                    CheckInAt = checkIn,
                    CheckOutAt = checkIn.AddMinutes(durationMinutes)
                });
            }
        }

        AddVisits(mobile, 60, 0, 5);
        AddVisits(dino, 62, 0, 3);
        AddVisits(lejla, 58, 0, 4);
        AddVisits(tarik, 70, 0, 6);
        AddVisits(amina, 61, 0, 2);
        AddVisits(haris, 59, 0, 3);
        AddVisits(sara, 60, 0, 4);
        AddVisits(kenan, 15, 0, 4);
        AddVisits(ilma, 12, 0, 3);
        AddVisits(gymMember, 5, 0, 3);
        AddVisits(adnan, 50, 20, 3);
        AddVisits(merima, 40, 10, 2);

        // trenutno u teretani (desktop "trenutno u teretani" + mobile kartica "Stanje u teretani")
        visits.Add(new GymVisit { User = mobile, CheckInAt = now.AddHours(-1), CheckOutAt = null });
        visits.Add(new GymVisit { User = tarik, CheckInAt = now.AddMinutes(-45), CheckOutAt = null });
        visits.Add(new GymVisit { User = lejla, CheckInAt = now.AddMinutes(-25), CheckOutAt = null });
        visits.Add(new GymVisit { User = sara, CheckInAt = now.AddMinutes(-10), CheckOutAt = null });
        db.GymVisits.AddRange(visits);

        // ---------- Kategorije suplemenata ----------
        var proteins = new SupplementCategory { Name = "Proteini", Description = "Proteinski prahovi za oporavak i rast mišićne mase." };
        var creatine = new SupplementCategory { Name = "Kreatini", Description = "Kreatin za snagu i eksplozivnost tokom treninga." };
        var aminoAcids = new SupplementCategory { Name = "Aminokiseline", Description = "BCAA i esencijalne aminokiseline za oporavak mišića." };
        var vitamins = new SupplementCategory { Name = "Vitamini i minerali", Description = "Podrška imunitetu i općem zdravlju sportista." };
        var gainers = new SupplementCategory { Name = "Mass gaineri", Description = "Visokokalorijski dodaci za povećanje tjelesne mase." };
        var preWorkout = new SupplementCategory { Name = "Pre-workout", Description = "Formule za energiju i fokus prije treninga." };
        db.SupplementCategories.AddRange(proteins, creatine, aminoAcids, vitamins, gainers, preWorkout);

        // ---------- Dobavljaci ----------
        var optimum = new Supplier { Name = "Optimum Nutrition", ContactEmail = "orders@optimumnutrition.com", ContactPhone = "+1-800-705-5226" };
        var muscleTech = new Supplier { Name = "MuscleTech", ContactEmail = "sales@muscletech.com", ContactPhone = "+1-888-334-4448" };
        var bioTech = new Supplier { Name = "BioTech USA", ContactEmail = "info@biotechusa.com", ContactPhone = "+36-1-453-2716" };
        var scitec = new Supplier { Name = "Scitec Nutrition", ContactEmail = "office@scitecnutrition.com", ContactPhone = "+36-23-880-955" };
        var dymatize = new Supplier { Name = "Dymatize", ContactEmail = "support@dymatize.com", ContactPhone = "+1-214-221-1893" };
        db.Suppliers.AddRange(optimum, muscleTech, bioTech, scitec, dymatize);

        // ---------- Suplementi ----------
        Supplement NewSupplement(string name, string image, decimal price, string description,
            SupplementCategory category, Supplier supplier, int stock)
        {
            return new Supplement
            {
                Name = name,
                ImageData = LoadImage(image),
                Price = price,
                Description = description,
                Category = category,
                Supplier = supplier,
                StockQuantity = stock
            };
        }

        var goldStandard = NewSupplement("Gold Standard 100% Whey 908g", "supp_01.png", 89.90m,
            "Najprodavaniji whey protein na svijetu - 24g proteina po dozi, brza apsorpcija, idealan nakon treninga.",
            proteins, optimum, 45);
        var hydrowhey = NewSupplement("Platinum Hydrowhey 1.6kg", "supp_02.png", 129.90m,
            "Hidrolizovani whey izolat najvišeg kvaliteta - 30g proteina po dozi uz minimalno masti i šećera.",
            proteins, optimum, 20);
        var nitroTech = NewSupplement("Nitro-Tech Whey 1.8kg", "supp_03.png", 99.90m,
            "Whey protein obogaćen kreatinom za snagu i masu - 30g proteina i 3g kreatina po dozi.",
            proteins, muscleTech, 30);
        var massTech = NewSupplement("Mass-Tech Extreme 2000 3.2kg", "supp_04.png", 119.90m,
            "Napredni mass gainer - preko 2000 kalorija po dozi za najteže hard gainere.",
            gainers, muscleTech, 15);
        var seriousMass = NewSupplement("Serious Mass 5.4kg", "supp_05.png", 109.90m,
            "Klasik među gainerima - 1250 kalorija i 50g proteina po dozi, 25 vitamina i minerala.",
            gainers, optimum, 25);
        var isoWheyZero = NewSupplement("Iso Whey Zero 2.27kg", "supp_06.png", 94.90m,
            "Whey izolat bez laktoze, glutena i šećera - 21g proteina po dozi, preko 10 okusa.",
            proteins, bioTech, 40);
        var creatineMono = NewSupplement("100% Creatine Monohydrate 500g", "supp_07.png", 39.90m,
            "Čisti mikronizirani kreatin monohidrat - dokazana formula za snagu i volumen mišića.",
            creatine, bioTech, 60);
        var platinumCreatine = NewSupplement("Platinum 100% Creatine 400g", "supp_08.png", 44.90m,
            "HPLC testirani kreatin monohidrat premium čistoće za maksimalne rezultate.",
            creatine, muscleTech, 35);
        var bcaaZero = NewSupplement("BCAA Zero 360g", "supp_09.png", 49.90m,
            "Instant BCAA 2:1:1 formula bez šećera - oporavak mišića tokom i nakon treninga.",
            aminoAcids, bioTech, 50);
        var amino5600 = NewSupplement("Amino 5600 500 tableta", "supp_10.png", 54.90m,
            "Kompletan aminokiselinski profil iz whey proteina - 5600mg aminokiselina po dozi.",
            aminoAcids, scitec, 28);
        var jumbo = NewSupplement("Jumbo 3.52kg", "supp_11.png", 99.90m,
            "Moćni gainer sa 6 vrsta ugljikohidrata, kreatinom i aminokiselinama za brzo napredovanje.",
            gainers, scitec, 18);
        var megaDaily = NewSupplement("Mega Daily One Plus 120 kapsula", "supp_12.png", 29.90m,
            "Multivitaminski kompleks za sportiste - 12 vitamina i 9 minerala u jednoj kapsuli dnevno.",
            vitamins, bioTech, 55);
        var iso100 = NewSupplement("ISO100 Hydrolyzed 2.2kg", "supp_13.png", 134.90m,
            "Hidrolizovani whey izolat - 25g proteina, manje od 1g masti, najbrža moguća apsorpcija.",
            proteins, dymatize, 22);
        var hotBlood = NewSupplement("Hot Blood 3.0 300g", "supp_14.png", 59.90m,
            "Pre-workout formula sa kreatinom, kofeinom i beta-alaninom za eksplozivne treninge.",
            preWorkout, scitec, 32);
        var omega3 = NewSupplement("Omega 3 90 kapsula", "supp_15.png", 24.90m,
            "Riblje ulje bogato EPA i DHA masnim kiselinama - podrška srcu, zglobovima i oporavku.",
            vitamins, bioTech, 48);

        var supplements = new[]
        {
            goldStandard, hydrowhey, nitroTech, massTech, seriousMass, isoWheyZero, creatineMono,
            platinumCreatine, bcaaZero, amino5600, jumbo, megaDaily, iso100, hotBlood, omega3
        };
        db.Supplements.AddRange(supplements);

        // ---------- Narudzbe ----------
        var orderCounter = 0;

        Order NewOrder(User user, int daysAgo, OrderStatus status,
            (Supplement supplement, int quantity)[] items, User? statusChangedBy = null, string? cancellationReason = null)
        {
            orderCounter++;
            var order = new Order
            {
                User = user,
                CreatedAt = now.AddDays(-daysAgo),
                Status = status,
                StripePaymentIntentId = $"seed_pi_{orderCounter:D4}",
                DeliveryStreet = user.StreetAddress!,
                DeliveryCity = user.City!,
                StatusChangedAt = status == OrderStatus.Processing ? null : now.AddDays(-daysAgo + 2),
                StatusChangedByUserId = null,
                CancellationReason = cancellationReason
            };
            foreach (var (supplement, quantity) in items)
            {
                order.Items.Add(new OrderItem
                {
                    Supplement = supplement,
                    Quantity = quantity,
                    UnitPrice = supplement.Price
                });
            }
            order.TotalAmount = order.Items.Sum(i => i.UnitPrice * i.Quantity);
            order.StatusChangedByUserId = statusChangedBy?.Id;
            return order;
        }

        var orders = new List<Order>
        {
            NewOrder(mobile, 20, OrderStatus.Delivered, new[] { (goldStandard, 1), (creatineMono, 2) }, desktop),
            NewOrder(mobile, 8, OrderStatus.Delivered, new[] { (iso100, 1) }, desktop),
            NewOrder(mobile, 1, OrderStatus.Processing, new[] { (bcaaZero, 1), (omega3, 1) }),
            NewOrder(mobile, 3, OrderStatus.Shipped, new[] { (platinumCreatine, 1) }, desktop),
            NewOrder(lejla, 15, OrderStatus.Delivered, new[] { (isoWheyZero, 1) }, desktop),
            NewOrder(tarik, 12, OrderStatus.Delivered, new[] { (jumbo, 1), (amino5600, 1) }, desktop),
            NewOrder(amina, 2, OrderStatus.Processing, new[] { (megaDaily, 1) }),
            NewOrder(haris, 5, OrderStatus.Cancelled, new[] { (nitroTech, 1) }, desktop, "Kupac odustao od narudžbe"),
            NewOrder(sara, 25, OrderStatus.Delivered, new[] { (seriousMass, 1), (hotBlood, 1) }, desktop)
        };
        db.Orders.AddRange(orders);

        // ---------- Recenzije (samo za dostavljene narudzbe) ----------
        Review NewReview(User user, Supplement supplement, int rating, string comment, int daysAgo)
        {
            return new Review
            {
                User = user,
                Supplement = supplement,
                Rating = rating,
                Comment = comment,
                CreatedAt = now.AddDays(-daysAgo)
            };
        }

        db.Reviews.AddRange(
            NewReview(mobile, goldStandard, 5, "Odličan okus i miješa se bez grudvica. Preporučujem svima!", 16),
            NewReview(mobile, creatineMono, 4, "Radi posao, cijena super. Jedino pakovanje moglo biti praktičnije.", 15),
            NewReview(mobile, iso100, 5, "Najbolji izolat koji sam probao, vrijedi svake marke.", 5),
            NewReview(lejla, isoWheyZero, 4, "Super za osobe netolerantne na laktozu. Čokolada okus odličan.", 10),
            NewReview(tarik, jumbo, 5, "Za dva mjeseca +4kg. Gainer koji stvarno radi.", 8),
            NewReview(tarik, amino5600, 3, "Solidne tablete ali ih treba puno po dozi.", 7),
            NewReview(sara, seriousMass, 4, "Klasika, uvijek se vraćam na njega.", 20)
        );

        // ---------- Osoblje ----------
        StaffMember NewStaff(string firstName, string lastName, StaffType type, string image,
            string biography, string email, string phone, int workStart, int workEnd)
        {
            return new StaffMember
            {
                FirstName = firstName,
                LastName = lastName,
                StaffType = type,
                ImageData = LoadImage(image),
                Biography = biography,
                Email = email,
                Phone = phone,
                WorkStartHour = workStart,
                WorkEndHour = workEnd
            };
        }

        var emir = NewStaff("Emir", "Pintul", StaffType.Trainer, "staff_emir.png",
            "Certificirani trener snage sa 10 godina iskustva. Specijalizovan za powerlifting i pripremu takmičara.",
            "emir.pintul@stronghold.ba", "061-200-100", 8, 16);
        var jasmin = NewStaff("Jasmin", "Vila", StaffType.Trainer, "staff_jasmin.png",
            "Trener funkcionalnog treninga i kondicije. Radi sa rekreativcima i sportskim ekipama.",
            "jasmin.vila@stronghold.ba", "061-200-101", 10, 18);
        var selma = NewStaff("Selma", "Krupalija", StaffType.Trainer, "staff_selma.png",
            "Trenerica grupnih programa i oblikovanja tijela. Certifikati iz pilatesa i HIIT treninga.",
            "selma.krupalija@stronghold.ba", "061-200-102", 12, 20);
        var nejra = NewStaff("Nejra", "Fazlić", StaffType.Nutritionist, "staff_nejra.png",
            "Magistrica nutricionizma. Kreira individualne planove ishrane za mršavljenje i dobijanje mase.",
            "nejra.fazlic@stronghold.ba", "061-200-103", 9, 15);
        var damir = NewStaff("Damir", "Šarić", StaffType.Nutritionist, "staff_damir.png",
            "Sportski nutricionista sa fokusom na suplementaciju i ishranu izdržljivostnih sportista.",
            "damir.saric@stronghold.ba", "061-200-104", 11, 17);
        db.StaffMembers.AddRange(emir, jasmin, selma, nejra, damir);

        // ---------- Termini ----------
        Appointment NewAppointment(User user, StaffMember staff, int daysFromNow, int hour,
            AppointmentStatus status, int createdDaysAgo, CancellationActor? cancelledBy = null, string? reason = null)
        {
            return new Appointment
            {
                User = user,
                StaffMember = staff,
                Date = DateOnly.FromDateTime(now.AddDays(daysFromNow)),
                StartHour = hour,
                Status = status,
                CreatedAt = now.AddDays(-createdDaysAgo),
                StatusChangedAt = status == AppointmentStatus.Pending ? null : now.AddDays(-createdDaysAgo + 1),
                CancelledBy = cancelledBy,
                CancellationReason = reason
            };
        }

        db.Appointments.AddRange(
            NewAppointment(mobile, emir, 3, 10, AppointmentStatus.Confirmed, 4),
            NewAppointment(mobile, nejra, 5, 12, AppointmentStatus.Pending, 1),
            NewAppointment(lejla, emir, 3, 11, AppointmentStatus.Confirmed, 3),
            NewAppointment(tarik, jasmin, 4, 15, AppointmentStatus.Pending, 2),
            NewAppointment(amina, selma, 6, 13, AppointmentStatus.Confirmed, 2),
            NewAppointment(mobile, emir, -7, 10, AppointmentStatus.Completed, 10),
            NewAppointment(sara, damir, -3, 12, AppointmentStatus.Completed, 6),
            NewAppointment(dino, jasmin, -5, 16, AppointmentStatus.Cancelled, 8,
                CancellationActor.Admin, "Trener spriječen zbog bolesti"),
            NewAppointment(haris, selma, 2, 14, AppointmentStatus.Cancelled, 3,
                CancellationActor.User, "Spriječenost zbog posla")
        );

        // ---------- Seminari ----------
        var seminarIshrana = new Seminar
        {
            Topic = "Pravilna ishrana u fazi hipertrofije",
            Speaker = "Nejra Fazlić",
            ScheduledAt = now.Date.AddDays(10).AddHours(18),
            MaxCapacity = 30
        };
        var seminarSnaga = new Seminar
        {
            Topic = "Osnove snage: tehnika čučnja i mrtvog dizanja",
            Speaker = "Emir Pintul",
            ScheduledAt = now.Date.AddDays(17).AddHours(19),
            MaxCapacity = 25
        };
        var seminarSuplementi = new Seminar
        {
            Topic = "Suplementacija za početnike - šta stvarno radi",
            Speaker = "Damir Šarić",
            ScheduledAt = now.Date.AddDays(24).AddHours(18),
            MaxCapacity = 40
        };
        var seminarPovrede = new Seminar
        {
            Topic = "Prevencija povreda ramena u treningu",
            Speaker = "Jasmin Vila",
            ScheduledAt = now.Date.AddDays(-12).AddHours(18),
            MaxCapacity = 30
        };
        var seminarKardio = new Seminar
        {
            Topic = "Kardio bez gubitka mišićne mase",
            Speaker = "Selma Krupalija",
            ScheduledAt = now.Date.AddDays(6).AddHours(17),
            MaxCapacity = 20,
            IsCancelled = true,
            CancelledAt = now.AddDays(-1),
            CancellationReason = "Predavač spriječen, novi termin će biti objavljen"
        };
        db.Seminars.AddRange(seminarIshrana, seminarSnaga, seminarSuplementi, seminarPovrede, seminarKardio);

        SeminarRegistration NewRegistration(Seminar seminar, User user, int daysAgo)
        {
            return new SeminarRegistration { Seminar = seminar, User = user, RegisteredAt = now.AddDays(-daysAgo) };
        }

        db.SeminarRegistrations.AddRange(
            NewRegistration(seminarIshrana, mobile, 3),
            NewRegistration(seminarIshrana, lejla, 2),
            NewRegistration(seminarIshrana, amina, 1),
            NewRegistration(seminarSnaga, mobile, 2),
            NewRegistration(seminarSnaga, tarik, 4),
            NewRegistration(seminarSuplementi, dino, 1),
            NewRegistration(seminarPovrede, mobile, 20),
            NewRegistration(seminarPovrede, haris, 18),
            NewRegistration(seminarPovrede, kenan, 16)
        );

        // ---------- Notifikacije ----------
        Notification NewNotification(User user, string title, string message, NotificationType type,
            bool isRead, int daysAgo)
        {
            return new Notification
            {
                User = user,
                Title = title,
                Message = message,
                Type = type,
                IsRead = isRead,
                CreatedAt = now.AddDays(-daysAgo)
            };
        }

        db.Notifications.AddRange(
            NewNotification(mobile, "Narudžba dostavljena",
                "Vaša narudžba #2 je dostavljena. Prijatno korištenje!", NotificationType.OrderStatusChanged, true, 6),
            NewNotification(mobile, "Termin potvrđen",
                "Trener Emir Pintul je potvrdio vaš termin.", NotificationType.AppointmentStatusChanged, false, 3),
            NewNotification(mobile, "Nadolazeći seminar",
                "Seminar \"Pravilna ishrana u fazi hipertrofije\" počinje za 10 dana.", NotificationType.UpcomingSeminar, false, 1),
            NewNotification(kenan, "Članarina uskoro ističe",
                "Vaša članarina ističe za 15 dana. Produžite je na vrijeme.", NotificationType.MembershipExpiry, false, 1),
            NewNotification(adnan, "Članarina istekla",
                "Vaša članarina je istekla. Obnovite je da nastavite trenirati.", NotificationType.MembershipExpiry, true, 19)
        );

        // ---------- FAQ ----------
        db.Faqs.AddRange(
            new Faq
            {
                Question = "Koje je radno vrijeme teretane?",
                Answer = "Teretana je otvorena radnim danima od 07:00 do 23:00, subotom od 08:00 do 22:00, a nedjeljom od 09:00 do 20:00."
            },
            new Faq
            {
                Question = "Kako mogu produžiti članarinu?",
                Answer = "Članarinu produžavate na recepciji teretane. Uplata odmah aktivira ili produžava vašu članarinu, a potvrdu vidite u aplikaciji."
            },
            new Faq
            {
                Question = "Kako zakazujem termin kod trenera ili nutricioniste?",
                Answer = "U mobilnoj aplikaciji odaberite trenera ili nutricionistu, datum i jednu od slobodnih satnica. Termin je potvrđen kada ga osoblje odobri."
            },
            new Faq
            {
                Question = "Šta je XP i kako se računa?",
                Answer = "XP dobijate za vrijeme provedeno u teretani - 150 XP po satu boravka. Svaki nivo traži 2500 XP, a neaktivnost donosi blagi gubitak XP-a."
            },
            new Faq
            {
                Question = "Kako mogu platiti suplemente?",
                Answer = "Suplementi se plaćaju karticom direktno u mobilnoj aplikaciji. Nakon uspješne uplate narudžba ide u obradu i dostavlja se na vašu adresu."
            },
            new Faq
            {
                Question = "Mogu li otkazati narudžbu?",
                Answer = "Narudžbu u obradi možete otkazati kontaktiranjem osoblja. Za plaćene narudžbe novac se vraća na karticu putem Stripe povrata."
            }
        );

        await db.SaveChangesAsync();
        await transaction.CommitAsync();

        logger.LogInformation("Seed zavrsen: {Users} korisnika, {Supplements} suplemenata, {Visits} posjeta.",
            users.Length, supplements.Length, visits.Count);
    }

    private static byte[] LoadImage(string fileName)
    {
        var assembly = Assembly.GetExecutingAssembly();
        var resourceName = $"Stronghold.Infrastructure.SeedAssets.{fileName}";
        using var stream = assembly.GetManifestResourceStream(resourceName)
            ?? throw new InvalidOperationException($"Seed slika '{resourceName}' nije pronađena u resursima.");
        using var memory = new MemoryStream();
        stream.CopyTo(memory);
        return memory.ToArray();
    }
}
