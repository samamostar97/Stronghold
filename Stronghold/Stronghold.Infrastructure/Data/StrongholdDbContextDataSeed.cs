using Microsoft.EntityFrameworkCore;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;

namespace Stronghold.Infrastructure.Data;

public static class StrongholdDbContextDataSeed
{
    public static async Task ClearDatabaseAsync(StrongholdDbContext context)
    {
        // Delete data in correct order (respecting foreign key constraints)
        // Using IgnoreQueryFilters to load ALL records including soft-deleted ones

        var reviews = await context.Reviews.IgnoreQueryFilters().ToListAsync();
        context.Reviews.RemoveRange(reviews);
        await context.SaveChangesAsync();

        var orderItems = await context.OrderItems.IgnoreQueryFilters().ToListAsync();
        context.OrderItems.RemoveRange(orderItems);
        await context.SaveChangesAsync();

        var orders = await context.Orders.IgnoreQueryFilters().ToListAsync();
        context.Orders.RemoveRange(orders);
        await context.SaveChangesAsync();

        var seminarAttendees = await context.SeminarAttendees.IgnoreQueryFilters().ToListAsync();
        context.SeminarAttendees.RemoveRange(seminarAttendees);
        await context.SaveChangesAsync();

        var appointments = await context.Appointments.IgnoreQueryFilters().ToListAsync();
        context.Appointments.RemoveRange(appointments);
        await context.SaveChangesAsync();

        var paymentHistory = await context.MembershipPaymentHistory.IgnoreQueryFilters().ToListAsync();
        context.MembershipPaymentHistory.RemoveRange(paymentHistory);
        await context.SaveChangesAsync();

        var memberships = await context.Memberships.IgnoreQueryFilters().ToListAsync();
        context.Memberships.RemoveRange(memberships);
        await context.SaveChangesAsync();

        var gymVisits = await context.GymVisits.IgnoreQueryFilters().ToListAsync();
        context.GymVisits.RemoveRange(gymVisits);
        await context.SaveChangesAsync();

        var passwordResetTokens = await context.PasswordResetTokens.IgnoreQueryFilters().ToListAsync();
        context.PasswordResetTokens.RemoveRange(passwordResetTokens);
        await context.SaveChangesAsync();

        var users = await context.Users.IgnoreQueryFilters().ToListAsync();
        context.Users.RemoveRange(users);
        await context.SaveChangesAsync();

        var seminars = await context.Seminars.IgnoreQueryFilters().ToListAsync();
        context.Seminars.RemoveRange(seminars);
        await context.SaveChangesAsync();

        var supplements = await context.Supplements.IgnoreQueryFilters().ToListAsync();
        context.Supplements.RemoveRange(supplements);
        await context.SaveChangesAsync();

        var suppliers = await context.Suppliers.IgnoreQueryFilters().ToListAsync();
        context.Suppliers.RemoveRange(suppliers);
        await context.SaveChangesAsync();

        var categories = await context.SupplementCategories.IgnoreQueryFilters().ToListAsync();
        context.SupplementCategories.RemoveRange(categories);
        await context.SaveChangesAsync();

        var nutritionists = await context.Nutritionists.IgnoreQueryFilters().ToListAsync();
        context.Nutritionists.RemoveRange(nutritionists);
        await context.SaveChangesAsync();

        var trainers = await context.Trainers.IgnoreQueryFilters().ToListAsync();
        context.Trainers.RemoveRange(trainers);
        await context.SaveChangesAsync();

        var packages = await context.MembershipPackages.IgnoreQueryFilters().ToListAsync();
        context.MembershipPackages.RemoveRange(packages);
        await context.SaveChangesAsync();

        var faqs = await context.FAQs.IgnoreQueryFilters().ToListAsync();
        context.FAQs.RemoveRange(faqs);
        await context.SaveChangesAsync();

        Console.WriteLine("All data cleared successfully.");
    }

    public static async Task SeedAsync(StrongholdDbContext context)
    {
        await context.Database.MigrateAsync();

        await SeedMembershipPackagesAsync(context);
        await SeedSupplementCategoriesAsync(context);
        await SeedSuppliersAsync(context);
        await SeedSupplementsAsync(context);
        await SeedTrainersAsync(context);
        await SeedNutritionistsAsync(context);
        await SeedFAQsAsync(context);
        await SeedSeminarsAsync(context);
        await SeedUsersAsync(context);
        await SeedGymVisitsAsync(context);
        await SeedSeminarAttendeesAsync(context);
        await SeedMembershipsAsync(context);
        await SeedAppointmentsAsync(context);
        await SeedOrdersAsync(context);
        await SeedReviewsAsync(context);
        await SeedAddressesAsync(context);

        await context.SaveChangesAsync();
    }

    private static async Task SeedMembershipPackagesAsync(StrongholdDbContext context)
    {
        if (await context.MembershipPackages.AnyAsync()) return;

        var packages = new List<MembershipPackage>
        {
            new() { PackageName = "Basic Standard", PackagePrice = 60.00m, Description = "24/7 pristup teretani" },
            new() { PackageName = "Premium Standard", PackagePrice = 90.00m, Description = "24/7 pristup teretani sa uključenim grupnim treninzima" },
            new() { PackageName = "Basic Duo", PackagePrice = 100.00m, Description = "24/7 pristup teretani za parove" },
            new() { PackageName = "Premium Duo", PackagePrice = 150.00m, Description = "24/7 pristup teretani za parove sa uključenim grupnim treninzima" }
        };

        await context.MembershipPackages.AddRangeAsync(packages);
        await context.SaveChangesAsync();
    }

    private static async Task SeedSupplementCategoriesAsync(StrongholdDbContext context)
    {
        if (await context.SupplementCategories.AnyAsync()) return;

        var categories = new List<SupplementCategory>
        {
            new() { Name = "Proteini" },
            new() { Name = "Kreatin" },
            new() { Name = "Aminokiseline" },
            new() { Name = "Vitamini i minerali" },
            new() { Name = "Pre-workout" },
            new() { Name = "Mass gaineri" }
        };

        await context.SupplementCategories.AddRangeAsync(categories);
        await context.SaveChangesAsync();
    }

    private static async Task SeedSuppliersAsync(StrongholdDbContext context)
    {
        if (await context.Suppliers.AnyAsync()) return;

        var suppliers = new List<Supplier>
        {
            new() { Name = "Nutrifit BiH", Website = "https://nutrifit.ba" },
            new() { Name = "Supplement Centar Sarajevo", Website = "https://supplementcentar.ba" },
            new() { Name = "Gym Nutrition", Website = "https://gymnutrition.ba" },
            new() { Name = "Protein Shop Mostar", Website = "https://proteinshop.ba" },
            new() { Name = "FitLine BiH", Website = "https://fitline.ba" },
            new() { Name = "MaxPower Suplementi", Website = "https://maxpower.ba" }
        };

        await context.Suppliers.AddRangeAsync(suppliers);
        await context.SaveChangesAsync();
    }

    private static async Task SeedSupplementsAsync(StrongholdDbContext context)
    {
        if (await context.Supplements.AnyAsync()) return;

        var categories = await context.SupplementCategories.ToListAsync();
        var suppliers = await context.Suppliers.ToListAsync();

        var proteini = categories.First(c => c.Name == "Proteini").Id;
        var kreatin = categories.First(c => c.Name == "Kreatin").Id;
        var amino = categories.First(c => c.Name == "Aminokiseline").Id;
        var vitamini = categories.First(c => c.Name == "Vitamini i minerali").Id;
        var preworkout = categories.First(c => c.Name == "Pre-workout").Id;
        var gaineri = categories.First(c => c.Name == "Mass gaineri").Id;

        // 25 supplements total (indices 0-24)
        var supplements = new List<Supplement>
        {
            // Proteini (0-3)
            new() { Name = "Whey Protein Gold 2kg", Price = 89.00m, Description = "Premium whey protein izolat sa 24g proteina po porciji", SupplementCategoryId = proteini, SupplierId = suppliers[0].Id, SupplementImageUrl = "/uploads/supplements/seed_whey-protein-gold.png" },
            new() { Name = "Casein Protein 1kg", Price = 65.00m, Description = "Sporo oslobađajući kazein protein idealan za noć", SupplementCategoryId = proteini, SupplierId = suppliers[1].Id, SupplementImageUrl = "/uploads/supplements/seed_casein-protein.png" },
            new() { Name = "Vegan Protein Mix 1kg", Price = 55.00m, Description = "Biljni protein od graška i riže", SupplementCategoryId = proteini, SupplierId = suppliers[2].Id, SupplementImageUrl = "/uploads/supplements/seed_vegan-protein.png" },
            new() { Name = "Whey Isolate 1kg", Price = 75.00m, Description = "Čisti whey izolat sa minimalnim mastima i ugljikohidratima", SupplementCategoryId = proteini, SupplierId = suppliers[0].Id, SupplementImageUrl = "/uploads/supplements/seed_whey-isolate.png" },

            // Kreatin (4-6)
            new() { Name = "Kreatin Monohidrat 500g", Price = 35.00m, Description = "Čisti kreatin monohidrat za povećanje snage", SupplementCategoryId = kreatin, SupplierId = suppliers[1].Id, SupplementImageUrl = "/uploads/supplements/seed_kreatin-monohidrat.png" },
            new() { Name = "Kreatin HCL 120 kapsula", Price = 45.00m, Description = "Kreatin hidrohlorid za bolju apsorpciju", SupplementCategoryId = kreatin, SupplierId = suppliers[4].Id, SupplementImageUrl = "/uploads/supplements/seed_kreatin-hcl.png" },
            new() { Name = "Kre-Alkalyn 120 kapsula", Price = 50.00m, Description = "Puferovani kreatin bez potrebe za fazom punjenja", SupplementCategoryId = kreatin, SupplierId = suppliers[5].Id, SupplementImageUrl = "/uploads/supplements/seed_kre-alkalyn.png" },

            // Aminokiseline (7-11)
            new() { Name = "BCAA 2:1:1 400g", Price = 40.00m, Description = "Razgranati aminokiselinski lanac za oporavak mišića", SupplementCategoryId = amino, SupplierId = suppliers[0].Id, SupplementImageUrl = "/uploads/supplements/seed_bcaa.png" },
            new() { Name = "EAA 350g", Price = 48.00m, Description = "Esencijalne aminokiseline za kompletnu podršku mišićima", SupplementCategoryId = amino, SupplierId = suppliers[3].Id, SupplementImageUrl = "/uploads/supplements/seed_eaa.png" },
            new() { Name = "Glutamin 500g", Price = 38.00m, Description = "L-Glutamin za oporavak i imunitet", SupplementCategoryId = amino, SupplierId = suppliers[1].Id, SupplementImageUrl = "/uploads/supplements/seed_glutamin.png" },
            new() { Name = "L-Karnitin 1000ml", Price = 32.00m, Description = "Tečni L-karnitin za sagorijevanje masti", SupplementCategoryId = amino, SupplierId = suppliers[4].Id, SupplementImageUrl = "/uploads/supplements/seed_l-karnitin.png" },
            new() { Name = "Beta Alanin 300g", Price = 35.00m, Description = "Za povećanje izdržljivosti tokom treninga", SupplementCategoryId = amino, SupplierId = suppliers[5].Id, SupplementImageUrl = "/uploads/supplements/seed_beta-alanin.png" },

            // Vitamini i minerali (12-16)
            new() { Name = "Multivitamin kompleks 60 tableta", Price = 25.00m, Description = "Kompletan multivitamin za sportiste", SupplementCategoryId = vitamini, SupplierId = suppliers[2].Id, SupplementImageUrl = "/uploads/supplements/seed_multivitamin.png" },
            new() { Name = "Vitamin D3 5000IU 120 kapsula", Price = 18.00m, Description = "Vitamin D3 za kosti i imunitet", SupplementCategoryId = vitamini, SupplierId = suppliers[0].Id, SupplementImageUrl = "/uploads/supplements/seed_vitamin-d3.png" },
            new() { Name = "Omega 3 120 kapsula", Price = 28.00m, Description = "Riblje ulje sa EPA i DHA", SupplementCategoryId = vitamini, SupplierId = suppliers[1].Id, SupplementImageUrl = "/uploads/supplements/seed_omega-3.png" },
            new() { Name = "ZMA 90 kapsula", Price = 22.00m, Description = "Cink, magnezijum i vitamin B6 za bolji san i oporavak", SupplementCategoryId = vitamini, SupplierId = suppliers[3].Id, SupplementImageUrl = "/uploads/supplements/seed_zma.png" },
            new() { Name = "Magnezijum Citrat 120 tableta", Price = 15.00m, Description = "Magnezijum za mišiće i nervni sistem", SupplementCategoryId = vitamini, SupplierId = suppliers[4].Id, SupplementImageUrl = "/uploads/supplements/seed_magnezijum-citrat.png" },

            // Pre-workout (17-20)
            new() { Name = "Pre-Workout Extreme 300g", Price = 42.00m, Description = "Snažna pre-workout formula sa kofeinom i beta alaninom", SupplementCategoryId = preworkout, SupplierId = suppliers[5].Id, SupplementImageUrl = "/uploads/supplements/seed_pre-workout-extreme.png" },
            new() { Name = "Pump Matrix 350g", Price = 38.00m, Description = "Pre-workout bez stimulansa za bolju pumpu", SupplementCategoryId = preworkout, SupplierId = suppliers[0].Id, SupplementImageUrl = "/uploads/supplements/seed_pump-matrix.png" },
            new() { Name = "Energy Boost 250g", Price = 30.00m, Description = "Lagani pre-workout za početnike", SupplementCategoryId = preworkout, SupplierId = suppliers[2].Id, SupplementImageUrl = "/uploads/supplements/seed_energy-boost.png" },
            new() { Name = "Nitric Oxide Booster 200g", Price = 35.00m, Description = "Za poboljšanje protoka krvi i izdržljivosti", SupplementCategoryId = preworkout, SupplierId = suppliers[1].Id, SupplementImageUrl = "/uploads/supplements/seed_nitric-oxide-booster.png" },

            // Mass gaineri (21-24)
            new() { Name = "Mass Gainer 3kg", Price = 70.00m, Description = "Visokokalorični gainer za povećanje mase", SupplementCategoryId = gaineri, SupplierId = suppliers[3].Id, SupplementImageUrl = "/uploads/supplements/seed_mass-gainer.png" },
            new() { Name = "Serious Mass 2.7kg", Price = 65.00m, Description = "Gainer sa kompleksnim ugljikohidratima", SupplementCategoryId = gaineri, SupplierId = suppliers[4].Id, SupplementImageUrl = "/uploads/supplements/seed_serious-mass.png" },
            new() { Name = "Clean Gainer 2kg", Price = 58.00m, Description = "Gainer sa manje šećera i više proteina", SupplementCategoryId = gaineri, SupplierId = suppliers[5].Id, SupplementImageUrl = "/uploads/supplements/seed_clean-gainer.png" },
            new() { Name = "Weight Gainer Pro 4kg", Price = 85.00m, Description = "Profesionalni gainer za hard gainere", SupplementCategoryId = gaineri, SupplierId = suppliers[0].Id, SupplementImageUrl = "/uploads/supplements/seed_weight-gainer-pro.png" }
        };

        await context.Supplements.AddRangeAsync(supplements);
        await context.SaveChangesAsync();
    }

    private static async Task SeedTrainersAsync(StrongholdDbContext context)
    {
        if (await context.Trainers.AnyAsync()) return;

        var trainers = new List<Trainer>
        {
            new() { FirstName = "Amar", LastName = "Hadžić", Email = "amar.hadzic@stronghold.ba", PhoneNumber = "+38761123456" },
            new() { FirstName = "Eldin", LastName = "Mahmutović", Email = "eldin.mahmutovic@stronghold.ba", PhoneNumber = "+38761234567" },
            new() { FirstName = "Lejla", LastName = "Begović", Email = "lejla.begovic@stronghold.ba", PhoneNumber = "+38761345678" },
            new() { FirstName = "Mirza", LastName = "Delić", Email = "mirza.delic@stronghold.ba", PhoneNumber = "+38761456789" },
            new() { FirstName = "Amina", LastName = "Kovačević", Email = "amina.kovacevic@stronghold.ba", PhoneNumber = "+38761567890" },
            new() { FirstName = "Kenan", LastName = "Ibrahimović", Email = "kenan.ibrahimovic@stronghold.ba", PhoneNumber = "+38761678901" }
        };

        await context.Trainers.AddRangeAsync(trainers);
        await context.SaveChangesAsync();
    }

    private static async Task SeedNutritionistsAsync(StrongholdDbContext context)
    {
        if (await context.Nutritionists.AnyAsync()) return;

        var nutritionists = new List<Nutritionist>
        {
            new() { FirstName = "Selma", LastName = "Hodžić", Email = "selma.hodzic@stronghold.ba", PhoneNumber = "+38762123456" },
            new() { FirstName = "Adnan", LastName = "Mujić", Email = "adnan.mujic@stronghold.ba", PhoneNumber = "+38762234567" },
            new() { FirstName = "Amra", LastName = "Karić", Email = "amra.karic@stronghold.ba", PhoneNumber = "+38762345678" },
            new() { FirstName = "Emir", LastName = "Softić", Email = "emir.softic@stronghold.ba", PhoneNumber = "+38762456789" },
            new() { FirstName = "Lamija", LastName = "Bašić", Email = "lamija.basic@stronghold.ba", PhoneNumber = "+38762567890" },
            new() { FirstName = "Dženan", LastName = "Čolić", Email = "dzenan.colic@stronghold.ba", PhoneNumber = "+38762678901" }
        };

        await context.Nutritionists.AddRangeAsync(nutritionists);
        await context.SaveChangesAsync();
    }

    private static async Task SeedFAQsAsync(StrongholdDbContext context)
    {
        if (await context.FAQs.AnyAsync()) return;

        var faqs = new List<FAQ>
        {
            new() { Question = "Koje je radno vrijeme teretane?", Answer = "Teretana je otvorena 24/7 za sve članove sa aktivnom članarinom." },
            new() { Question = "Da li mogu zamrznuti članarinu?", Answer = "Da, članarinu možete zamrznuti do 30 dana godišnje uz prethodnu najavu od 7 dana." },
            new() { Question = "Da li nudite probni trening?", Answer = "Da, nudimo besplatan probni trening za sve nove članove. Kontaktirajte nas za zakazivanje." },
            new() { Question = "Šta je uključeno u Premium paket?", Answer = "Premium paket uključuje 24/7 pristup teretani i neograničene grupne treninge (yoga, pilates, crossfit, spinning)." },
            new() { Question = "Kako mogu otkazati članarinu?", Answer = "Članarinu možete otkazati u bilo kojem trenutku sa otkaznim rokom od 30 dana." },
            new() { Question = "Da li imate parking?", Answer = "Da, imamo besplatan parking za članove sa preko 50 parking mjesta." },
            new() { Question = "Kako funkcioniše XP sistem?", Answer = "XP sistem nagrađuje vašu aktivnost u teretani. Dobijate 150 XP za svaki sat treninga. Ako propustite dan treninga (u okviru zadnjih 30 dana), gubite 100 XP. Za svaki level potrebno je 2500 XP, a maksimalan level je 10. Pratite svoj napredak u sekciji 'Moj napredak'." },
            new() { Question = "Da li mogu dovesti prijatelja na probni trening?", Answer = "Da, svaki član može dovesti jednog prijatelja na besplatan probni trening jednom mjesečno. Prijatelj mora popuniti pristupnicu na recepciji." },
            new() { Question = "Koje grupne treninge nudite?", Answer = "Nudimo raznovrsne grupne treninge: yoga, pilates, crossfit, spinning, HIIT, funkcionalni trening i boks. Raspored treninga možete pogledati u aplikaciji ili na recepciji." },
            new() { Question = "Kako mogu pratiti svoj napredak?", Answer = "Vaš napredak možete pratiti kroz mobilnu aplikaciju u sekciji 'Moj napredak'. Tamo ćete vidjeti vaš XP, level, historiju posjeta teretani, kao i statistike vaših treninga." }
        };

        await context.FAQs.AddRangeAsync(faqs);
        await context.SaveChangesAsync();
    }

    private static async Task SeedSeminarsAsync(StrongholdDbContext context)
    {
        if (await context.Seminars.AnyAsync()) return;

        var seminars = new List<Seminar>
        {
            new() { Topic = "Osnove pravilne ishrane za sportiste", SpeakerName = "Dr. Selma Hodžić", EventDate = DateTime.UtcNow.AddDays(14), MaxCapacity = 25 },
            new() { Topic = "Kako izbjeći povrede tokom treninga", SpeakerName = "Amar Hadžić", EventDate = DateTime.UtcNow.AddDays(21), MaxCapacity = 20 },
            new() { Topic = "Suplementacija za početnike", SpeakerName = "Adnan Mujić", EventDate = DateTime.UtcNow.AddDays(28), MaxCapacity = 30 },
            new() { Topic = "Mentalna priprema i motivacija", SpeakerName = "Lejla Begović", EventDate = DateTime.UtcNow.AddDays(35), MaxCapacity = 20 },
            new() { Topic = "Trening snage vs. kardio - šta je bolje?", SpeakerName = "Eldin Mahmutović", EventDate = DateTime.UtcNow.AddDays(42), MaxCapacity = 25 },
            new() { Topic = "Pravilna tehnika deadlifta i čučnja", SpeakerName = "Mirza Delić", EventDate = DateTime.UtcNow.AddDays(49), MaxCapacity = 15 },
            new() { Topic = "Oporavak i regeneracija nakon treninga", SpeakerName = "Amra Karić", EventDate = DateTime.UtcNow.AddDays(56), MaxCapacity = 20 },
            new() { Topic = "Planiranje obroka za sportiste", SpeakerName = "Dr. Selma Hodžić", EventDate = DateTime.UtcNow.AddDays(63), MaxCapacity = 25 }
        };

        await context.Seminars.AddRangeAsync(seminars);
        await context.SaveChangesAsync();
    }

    private static async Task SeedUsersAsync(StrongholdDbContext context)
    {
        if (await context.Users.AnyAsync()) return;

        var users = new List<User>
        {
            // Admin
            new()
            {
                FirstName = "Admin",
                LastName = "Stronghold",
                Username = "admin",
                Email = "admin@stronghold.ba",
                PhoneNumber = "+38761000000",
                Gender = Gender.Male,
                Role = Role.Admin,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                ProfileImageUrl = "/uploads/profile-pictures/seed_admin.jpg"
            },
            // Gym Members (indices 0-8 after filtering by Role)
            new()
            {
                FirstName = "Member",
                LastName = "Stronghold",
                Username = "member",
                Email = "member@stronghold.ba",
                PhoneNumber = "+38761999999",
                Gender = Gender.Male,
                Role = Role.GymMember,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                ProfileImageUrl = "/uploads/profile-pictures/seed_member.jpg"
            },
            new()
            {
                FirstName = "Haris",
                LastName = "Muslimović",
                Username = "haris.muslimovic",
                Email = "haris.muslimovic@gmail.com",
                PhoneNumber = "+38761111111",
                Gender = Gender.Male,
                Role = Role.GymMember,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("haris123"),
                ProfileImageUrl = "/uploads/profile-pictures/seed_haris.muslimovic.jpg"
            },
            new()
            {
                FirstName = "Amela",
                LastName = "Šabanović",
                Username = "amela.sabanovic",
                Email = "amela.sabanovic@gmail.com",
                PhoneNumber = "+38761222222",
                Gender = Gender.Female,
                Role = Role.GymMember,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("amela123"),
                ProfileImageUrl = "/uploads/profile-pictures/seed_amela.sabanovic.jpg"
            },
            new()
            {
                FirstName = "Dino",
                LastName = "Čaušević",
                Username = "dino.causevic",
                Email = "dino.causevic@gmail.com",
                PhoneNumber = "+38761333333",
                Gender = Gender.Male,
                Role = Role.GymMember,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("dino123"),
                ProfileImageUrl = "/uploads/profile-pictures/seed_dino.causevic.jpg"
            },
            new()
            {
                FirstName = "Lejla",
                LastName = "Imamović",
                Username = "lejla.imamovic",
                Email = "lejla.imamovic@gmail.com",
                PhoneNumber = "+38761444444",
                Gender = Gender.Female,
                Role = Role.GymMember,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("lejla123"),
                ProfileImageUrl = "/uploads/profile-pictures/seed_lejla.imamovic.jpg"
            },
            new()
            {
                FirstName = "Armin",
                LastName = "Fazlić",
                Username = "armin.fazlic",
                Email = "armin.fazlic@gmail.com",
                PhoneNumber = "+38761555555",
                Gender = Gender.Male,
                Role = Role.GymMember,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("armin123"),
                ProfileImageUrl = "/uploads/profile-pictures/seed_armin.fazlic.jpg"
            },
            new()
            {
                FirstName = "Naida",
                LastName = "Hrustić",
                Username = "naida.hrustic",
                Email = "naida.hrustic@gmail.com",
                PhoneNumber = "+38761666666",
                Gender = Gender.Female,
                Role = Role.GymMember,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("naida123"),
                ProfileImageUrl = "/uploads/profile-pictures/seed_naida.hrustic.jpg"
            },
            new()
            {
                FirstName = "Emina",
                LastName = "Hadžić",
                Username = "member2",
                Email = "emina.hadzic@gmail.com",
                PhoneNumber = "+38761777777",
                Gender = Gender.Female,
                Role = Role.GymMember,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                ProfileImageUrl = "/uploads/profile-pictures/seed_member2.jpg"
            },
            new()
            {
                FirstName = "Tarik",
                LastName = "Hodžić",
                Username = "tarik.hodzic",
                Email = "tarik.hodzic@gmail.com",
                PhoneNumber = "+38761888888",
                Gender = Gender.Male,
                Role = Role.GymMember,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("tarik123"),
                ProfileImageUrl = "/uploads/profile-pictures/seed_tarik.hodzic.jpg"
            }
        };

        await context.Users.AddRangeAsync(users);
        await context.SaveChangesAsync();
    }

    private static async Task SeedMembershipsAsync(StrongholdDbContext context)
    {
        if (await context.Memberships.AnyAsync()) return;

        var users = await context.Users.Where(u => u.Role == Role.GymMember).ToListAsync();
        var packages = await context.MembershipPackages.ToListAsync();

        var memberships = new List<Membership>
        {
            new() { UserId = users[0].Id, MembershipPackageId = packages[0].Id, StartDate = DateTime.UtcNow.AddMonths(-2), EndDate = DateTime.UtcNow.AddMonths(1) },
            new() { UserId = users[1].Id, MembershipPackageId = packages[1].Id, StartDate = DateTime.UtcNow.AddMonths(-1), EndDate = DateTime.UtcNow.AddMonths(2) },
            new() { UserId = users[2].Id, MembershipPackageId = packages[2].Id, StartDate = DateTime.UtcNow.AddDays(-15), EndDate = DateTime.UtcNow.AddMonths(1).AddDays(-15) },
            new() { UserId = users[3].Id, MembershipPackageId = packages[3].Id, StartDate = DateTime.UtcNow.AddMonths(-3), EndDate = DateTime.UtcNow },
            new() { UserId = users[4].Id, MembershipPackageId = packages[0].Id, StartDate = DateTime.UtcNow, EndDate = DateTime.UtcNow.AddMonths(3) },
            new() { UserId = users[5].Id, MembershipPackageId = packages[1].Id, StartDate = DateTime.UtcNow.AddDays(-7), EndDate = DateTime.UtcNow.AddMonths(1).AddDays(-7) },
            new() { UserId = users[6].Id, MembershipPackageId = packages[0].Id, StartDate = DateTime.UtcNow.AddDays(-20), EndDate = DateTime.UtcNow.AddMonths(1).AddDays(-20) },
            new() { UserId = users[7].Id, MembershipPackageId = packages[1].Id, StartDate = DateTime.UtcNow.AddDays(-10), EndDate = DateTime.UtcNow.AddMonths(2).AddDays(-10) },
            new() { UserId = users[8].Id, MembershipPackageId = packages[0].Id, StartDate = DateTime.UtcNow.AddDays(-5), EndDate = DateTime.UtcNow.AddMonths(1).AddDays(-5) }
        };

        await context.Memberships.AddRangeAsync(memberships);
        await context.SaveChangesAsync();

        // Payment history for each membership
        var paymentHistory = new List<MembershipPaymentHistory>();
        foreach (var membership in memberships)
        {
            var package = packages.First(p => p.Id == membership.MembershipPackageId);
            paymentHistory.Add(new MembershipPaymentHistory
            {
                UserId = membership.UserId,
                MembershipPackageId = membership.MembershipPackageId,
                AmountPaid = package.PackagePrice,
                PaymentDate = membership.StartDate.AddDays(-1),
                StartDate = membership.StartDate,
                EndDate = membership.EndDate
            });
        }

        // Extra historical payments for some users (shows renewal history)
        var memberUser = users[0];
        paymentHistory.Add(new MembershipPaymentHistory
        {
            UserId = memberUser.Id,
            MembershipPackageId = packages[0].Id,
            AmountPaid = packages[0].PackagePrice,
            PaymentDate = DateTime.UtcNow.AddMonths(-5).AddDays(-1),
            StartDate = DateTime.UtcNow.AddMonths(-5),
            EndDate = DateTime.UtcNow.AddMonths(-2)
        });

        var haris = users[1];
        paymentHistory.Add(new MembershipPaymentHistory
        {
            UserId = haris.Id,
            MembershipPackageId = packages[1].Id,
            AmountPaid = packages[1].PackagePrice,
            PaymentDate = DateTime.UtcNow.AddMonths(-4).AddDays(-1),
            StartDate = DateTime.UtcNow.AddMonths(-4),
            EndDate = DateTime.UtcNow.AddMonths(-1)
        });

        await context.MembershipPaymentHistory.AddRangeAsync(paymentHistory);
        await context.SaveChangesAsync();
    }

    private static async Task SeedAppointmentsAsync(StrongholdDbContext context)
    {
        if (await context.Appointments.AnyAsync()) return;

        var users = await context.Users.Where(u => u.Role == Role.GymMember).ToListAsync();
        var trainers = await context.Trainers.ToListAsync();
        var nutritionists = await context.Nutritionists.ToListAsync();

        var appointments = new List<Appointment>
        {
            // Trainer appointments
            new() { UserId = users[0].Id, TrainerId = trainers[0].Id, AppointmentDate = DateTime.UtcNow.AddDays(2).AddHours(10) },
            new() { UserId = users[1].Id, TrainerId = trainers[1].Id, AppointmentDate = DateTime.UtcNow.AddDays(3).AddHours(14) },
            new() { UserId = users[2].Id, TrainerId = trainers[2].Id, AppointmentDate = DateTime.UtcNow.AddDays(4).AddHours(16) },
            new() { UserId = users[3].Id, TrainerId = trainers[0].Id, AppointmentDate = DateTime.UtcNow.AddDays(5).AddHours(9) },
            new() { UserId = users[4].Id, TrainerId = trainers[3].Id, AppointmentDate = DateTime.UtcNow.AddDays(6).AddHours(11) },
            new() { UserId = users[5].Id, TrainerId = trainers[4].Id, AppointmentDate = DateTime.UtcNow.AddDays(7).AddHours(15) },
            new() { UserId = users[6].Id, TrainerId = trainers[5].Id, AppointmentDate = DateTime.UtcNow.AddDays(8).AddHours(10) },
            new() { UserId = users[7].Id, TrainerId = trainers[0].Id, AppointmentDate = DateTime.UtcNow.AddDays(9).AddHours(13) },
            new() { UserId = users[8].Id, TrainerId = trainers[1].Id, AppointmentDate = DateTime.UtcNow.AddDays(10).AddHours(16) },
            new() { UserId = users[0].Id, TrainerId = trainers[2].Id, AppointmentDate = DateTime.UtcNow.AddDays(11).AddHours(8) },
            // Nutritionist appointments
            new() { UserId = users[0].Id, NutritionistId = nutritionists[0].Id, AppointmentDate = DateTime.UtcNow.AddDays(3).AddHours(13) },
            new() { UserId = users[2].Id, NutritionistId = nutritionists[1].Id, AppointmentDate = DateTime.UtcNow.AddDays(5).AddHours(15) },
            new() { UserId = users[5].Id, NutritionistId = nutritionists[2].Id, AppointmentDate = DateTime.UtcNow.AddDays(7).AddHours(10) },
            new() { UserId = users[7].Id, NutritionistId = nutritionists[3].Id, AppointmentDate = DateTime.UtcNow.AddDays(9).AddHours(11) },
            new() { UserId = users[8].Id, NutritionistId = nutritionists[4].Id, AppointmentDate = DateTime.UtcNow.AddDays(11).AddHours(14) },
            new() { UserId = users[1].Id, NutritionistId = nutritionists[5].Id, AppointmentDate = DateTime.UtcNow.AddDays(12).AddHours(9) },
            new() { UserId = users[4].Id, NutritionistId = nutritionists[0].Id, AppointmentDate = DateTime.UtcNow.AddDays(13).AddHours(16) },
            new() { UserId = users[6].Id, NutritionistId = nutritionists[1].Id, AppointmentDate = DateTime.UtcNow.AddDays(14).AddHours(12) }
        };

        await context.Appointments.AddRangeAsync(appointments);
        await context.SaveChangesAsync();
    }

    private static async Task SeedOrdersAsync(StrongholdDbContext context)
    {
        if (await context.Orders.AnyAsync()) return;

        var users = await context.Users.Where(u => u.Role == Role.GymMember).ToListAsync();
        var supplements = await context.Supplements.ToListAsync();

        // 18 orders spread across ~85 days, 14 Delivered + 4 Processing
        var orders = new List<Order>
        {
            // Order 1: Armin - Casein + Omega 3
            new()
            {
                UserId = users[5].Id,
                TotalAmount = 93.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-85),
                Status = OrderStatus.Delivered,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[1].Id, Quantity = 1, UnitPrice = supplements[1].Price },
                    new() { SupplementId = supplements[14].Id, Quantity = 1, UnitPrice = supplements[14].Price }
                }
            },
            // Order 2: Naida - Vegan Protein
            new()
            {
                UserId = users[6].Id,
                TotalAmount = 55.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-75),
                Status = OrderStatus.Delivered,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[2].Id, Quantity = 1, UnitPrice = supplements[2].Price }
                }
            },
            // Order 3: Haris - Pre-Workout + BCAA
            new()
            {
                UserId = users[1].Id,
                TotalAmount = 82.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-65),
                Status = OrderStatus.Delivered,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[17].Id, Quantity = 1, UnitPrice = supplements[17].Price },
                    new() { SupplementId = supplements[7].Id, Quantity = 1, UnitPrice = supplements[7].Price }
                }
            },
            // Order 4: Armin - Pre-Workout
            new()
            {
                UserId = users[5].Id,
                TotalAmount = 42.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-55),
                Status = OrderStatus.Delivered,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[17].Id, Quantity = 1, UnitPrice = supplements[17].Price }
                }
            },
            // Order 5: Amela - Whey Isolate
            new()
            {
                UserId = users[2].Id,
                TotalAmount = 75.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-50),
                Status = OrderStatus.Delivered,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[3].Id, Quantity = 1, UnitPrice = supplements[3].Price }
                }
            },
            // Order 6: Dino - Kreatin 500g + Multivitamin
            new()
            {
                UserId = users[3].Id,
                TotalAmount = 60.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-45),
                Status = OrderStatus.Delivered,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[4].Id, Quantity = 1, UnitPrice = supplements[4].Price },
                    new() { SupplementId = supplements[12].Id, Quantity = 1, UnitPrice = supplements[12].Price }
                }
            },
            // Order 7: Emina - Whey Gold + Glutamin
            new()
            {
                UserId = users[7].Id,
                TotalAmount = 127.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-40),
                Status = OrderStatus.Delivered,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[0].Id, Quantity = 1, UnitPrice = supplements[0].Price },
                    new() { SupplementId = supplements[9].Id, Quantity = 1, UnitPrice = supplements[9].Price }
                }
            },
            // Order 8: Tarik - Mass Gainer + Pre-Workout
            new()
            {
                UserId = users[8].Id,
                TotalAmount = 112.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-35),
                Status = OrderStatus.Delivered,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[21].Id, Quantity = 1, UnitPrice = supplements[21].Price },
                    new() { SupplementId = supplements[17].Id, Quantity = 1, UnitPrice = supplements[17].Price }
                }
            },
            // Order 9: Member - Serious Mass + Beta Alanin
            new()
            {
                UserId = users[0].Id,
                TotalAmount = 100.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-30),
                Status = OrderStatus.Delivered,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[22].Id, Quantity = 1, UnitPrice = supplements[22].Price },
                    new() { SupplementId = supplements[11].Id, Quantity = 1, UnitPrice = supplements[11].Price }
                }
            },
            // Order 10: Lejla - Multivitamin + Omega 3
            new()
            {
                UserId = users[4].Id,
                TotalAmount = 53.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-25),
                Status = OrderStatus.Delivered,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[12].Id, Quantity = 1, UnitPrice = supplements[12].Price },
                    new() { SupplementId = supplements[14].Id, Quantity = 1, UnitPrice = supplements[14].Price }
                }
            },
            // Order 11: Lejla - Whey Gold + Pre-Workout + Kreatin HCL
            new()
            {
                UserId = users[4].Id,
                TotalAmount = 176.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-20),
                Status = OrderStatus.Delivered,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[0].Id, Quantity = 1, UnitPrice = supplements[0].Price },
                    new() { SupplementId = supplements[17].Id, Quantity = 1, UnitPrice = supplements[17].Price },
                    new() { SupplementId = supplements[5].Id, Quantity = 1, UnitPrice = supplements[5].Price }
                }
            },
            // Order 12: Naida - Kre-Alkalyn + EAA
            new()
            {
                UserId = users[6].Id,
                TotalAmount = 98.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-15),
                Status = OrderStatus.Delivered,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[6].Id, Quantity = 1, UnitPrice = supplements[6].Price },
                    new() { SupplementId = supplements[8].Id, Quantity = 1, UnitPrice = supplements[8].Price }
                }
            },
            // Order 13: Member - Whey Gold + Kreatin 500g
            new()
            {
                UserId = users[0].Id,
                TotalAmount = 124.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-10),
                Status = OrderStatus.Delivered,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[0].Id, Quantity = 1, UnitPrice = supplements[0].Price },
                    new() { SupplementId = supplements[4].Id, Quantity = 1, UnitPrice = supplements[4].Price }
                }
            },
            // Order 14: Emina - Pump Matrix (Processing)
            new()
            {
                UserId = users[7].Id,
                TotalAmount = 38.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-7),
                Status = OrderStatus.Processing,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[18].Id, Quantity = 1, UnitPrice = supplements[18].Price }
                }
            },
            // Order 15: Haris - Whey Gold
            new()
            {
                UserId = users[1].Id,
                TotalAmount = 89.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-5),
                Status = OrderStatus.Delivered,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[0].Id, Quantity = 1, UnitPrice = supplements[0].Price }
                }
            },
            // Order 16: Tarik - Whey Isolate + ZMA (Processing)
            new()
            {
                UserId = users[8].Id,
                TotalAmount = 97.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-4),
                Status = OrderStatus.Processing,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[3].Id, Quantity = 1, UnitPrice = supplements[3].Price },
                    new() { SupplementId = supplements[15].Id, Quantity = 1, UnitPrice = supplements[15].Price }
                }
            },
            // Order 17: Amela - BCAA x2 + Multivitamin + ZMA (Processing)
            new()
            {
                UserId = users[2].Id,
                TotalAmount = 127.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-3),
                Status = OrderStatus.Processing,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[7].Id, Quantity = 2, UnitPrice = supplements[7].Price },
                    new() { SupplementId = supplements[12].Id, Quantity = 1, UnitPrice = supplements[12].Price },
                    new() { SupplementId = supplements[15].Id, Quantity = 1, UnitPrice = supplements[15].Price }
                }
            },
            // Order 18: Dino - Mass Gainer (Processing)
            new()
            {
                UserId = users[3].Id,
                TotalAmount = 70.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-1),
                Status = OrderStatus.Processing,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[21].Id, Quantity = 1, UnitPrice = supplements[21].Price }
                }
            }
        };

        await context.Orders.AddRangeAsync(orders);
        await context.SaveChangesAsync();
    }

    private static async Task SeedReviewsAsync(StrongholdDbContext context)
    {
        if (await context.Reviews.AnyAsync()) return;

        var users = await context.Users.Where(u => u.Role == Role.GymMember).ToListAsync();
        var supplements = await context.Supplements.ToListAsync();

        // 16 reviews - each respects purchase rules (only Delivered orders, 1 review per user per supplement)
        var reviews = new List<Review>
        {
            // Member reviewed: Whey Gold (order 13), Kreatin 500g (order 13), Serious Mass (order 9)
            new() { UserId = users[0].Id, SupplementId = supplements[0].Id, Rating = 5, Comment = "Odličan protein, ukus je fantastičan i dobro se otapa!" },
            new() { UserId = users[0].Id, SupplementId = supplements[4].Id, Rating = 5, Comment = "Primjetio sam poboljšanje snage već nakon 2 sedmice korištenja." },
            new() { UserId = users[0].Id, SupplementId = supplements[22].Id, Rating = 4, Comment = "Dobar gainer za one koji teško dobijaju na masi." },
            // Haris reviewed: Whey Gold (order 15), BCAA (order 3)
            new() { UserId = users[1].Id, SupplementId = supplements[0].Id, Rating = 4, Comment = "Dobar proizvod, ali cijena je malo visoka." },
            new() { UserId = users[1].Id, SupplementId = supplements[7].Id, Rating = 4, Comment = "BCAA pomaže sa oporavkom nakon teških treninga, preporučujem." },
            // Amela reviewed: Whey Isolate (order 5)
            new() { UserId = users[2].Id, SupplementId = supplements[3].Id, Rating = 5, Comment = "Kazein je super kvalitete, lako se miješa i ima odličan ukus." },
            // Dino reviewed: Kreatin 500g (order 6)
            new() { UserId = users[3].Id, SupplementId = supplements[4].Id, Rating = 4, Comment = "Klasičan kreatin, radi posao. Dobra vrijednost za novac." },
            // Lejla reviewed: Pre-Workout (order 11), Multivitamin (order 10)
            new() { UserId = users[4].Id, SupplementId = supplements[17].Id, Rating = 5, Comment = "Najbolji pre-workout koji sam probala, daje energiju bez nervoze." },
            new() { UserId = users[4].Id, SupplementId = supplements[12].Id, Rating = 3, Comment = "Solidan multivitamin, ništa posebno ali radi posao." },
            // Armin reviewed: Casein (order 1), Pre-Workout (order 4)
            new() { UserId = users[5].Id, SupplementId = supplements[1].Id, Rating = 3, Comment = "Okej kazein, ukus mogao biti bolji ali kvaliteta je tu." },
            new() { UserId = users[5].Id, SupplementId = supplements[17].Id, Rating = 5, Comment = "Fantastičan pre-workout, osjećam razliku na svakom treningu." },
            // Naida reviewed: Vegan Protein (order 2), Kre-Alkalyn (order 12)
            new() { UserId = users[6].Id, SupplementId = supplements[2].Id, Rating = 4, Comment = "Odličan vegan protein, nema teškog osjećaja u stomaku." },
            new() { UserId = users[6].Id, SupplementId = supplements[6].Id, Rating = 5, Comment = "Kre-Alkalyn je super, nema nadutosti kao kod običnog kreatina." },
            // Emina reviewed: Whey Gold (order 7)
            new() { UserId = users[7].Id, SupplementId = supplements[0].Id, Rating = 5, Comment = "Vrhunski protein, čokoladni ukus je savršen! Definitivno kupujem opet." },
            // Tarik reviewed: Mass Gainer (order 8), Pre-Workout (order 8)
            new() { UserId = users[8].Id, SupplementId = supplements[21].Id, Rating = 4, Comment = "Dobar mass gainer, pomaže sa kalorijskim sufiksom." },
            new() { UserId = users[8].Id, SupplementId = supplements[17].Id, Rating = 4, Comment = "Solidan pre-workout, daje dobru energiju za trening." }
        };

        await context.Reviews.AddRangeAsync(reviews);
        await context.SaveChangesAsync();
    }

    private static async Task SeedGymVisitsAsync(StrongholdDbContext context)
    {
        if (await context.GymVisits.AnyAsync()) return;

        var users = await context.Users.Where(u => u.Role == Role.GymMember).ToListAsync();
        var haris = users.First(u => u.FirstName == "Haris");
        var amela = users.First(u => u.FirstName == "Amela");
        var dino = users.First(u => u.FirstName == "Dino");
        var lejla = users.First(u => u.FirstName == "Lejla");
        var armin = users.First(u => u.FirstName == "Armin");
        var naida = users.First(u => u.FirstName == "Naida");
        var emina = users.First(u => u.FirstName == "Emina");
        var tarik = users.First(u => u.FirstName == "Tarik");

        var now = DateTime.UtcNow;
        var gymVisits = new List<GymVisit>();

        void AddVisit(int userId, DateTime date, int startHour, int durationMinutes)
        {
            var checkIn = date.Date.AddHours(startHour);
            gymVisits.Add(new GymVisit
            {
                UserId = userId,
                CheckInTime = checkIn,
                CheckOutTime = checkIn.AddMinutes(durationMinutes)
            });
        }

        for (int daysAgo = 45; daysAgo >= 0; daysAgo--)
        {
            var date = now.AddDays(-daysAgo);
            var dayOfWeek = date.DayOfWeek;

            // Haris: ~5-6 visits/week, 1.5-2h each (skips ~1 day/week, usually Sunday)
            if (dayOfWeek != DayOfWeek.Sunday || daysAgo % 3 == 0)
                AddVisit(haris.Id, date, 7, 90 + (daysAgo % 4) * 10);

            // Amela: ~4 visits/week, 1-1.5h each (skips Wed, Sat, sometimes Sun)
            if (dayOfWeek != DayOfWeek.Wednesday && dayOfWeek != DayOfWeek.Saturday && dayOfWeek != DayOfWeek.Sunday)
                AddVisit(amela.Id, date, 17, 60 + (daysAgo % 3) * 15);

            // Dino: ~3-4 visits/week, 1-2h each (Mon, Tue, Thu, Sat)
            if (dayOfWeek is DayOfWeek.Monday or DayOfWeek.Tuesday or DayOfWeek.Thursday or DayOfWeek.Saturday)
                AddVisit(dino.Id, date, 18, 60 + (daysAgo % 5) * 15);

            // Lejla: ~2-3 visits/week, 1h each (Mon, Wed, Fri but sometimes skips Fri)
            if (dayOfWeek == DayOfWeek.Monday || dayOfWeek == DayOfWeek.Wednesday ||
                (dayOfWeek == DayOfWeek.Friday && daysAgo % 3 != 0))
                AddVisit(lejla.Id, date, 10, 55 + (daysAgo % 2) * 10);

            // Armin: ~1-2 visits/week, 0.5-1h each (scattered, mostly Tue and Sat)
            if ((dayOfWeek == DayOfWeek.Tuesday && daysAgo % 2 == 0) ||
                (dayOfWeek == DayOfWeek.Saturday))
                AddVisit(armin.Id, date, 20, 30 + (daysAgo % 4) * 10);

            // Naida: ~4-5 visits/week, 1-1.5h each (skips Thu and sometimes Sun)
            if (dayOfWeek != DayOfWeek.Thursday && (dayOfWeek != DayOfWeek.Sunday || daysAgo % 2 == 0))
                AddVisit(naida.Id, date, 8, 60 + (daysAgo % 3) * 15);

            // Emina: ~3-4 visits/week, 1-1.5h each (Mon, Wed, Fri, sometimes Sat)
            if (dayOfWeek == DayOfWeek.Monday || dayOfWeek == DayOfWeek.Wednesday ||
                dayOfWeek == DayOfWeek.Friday || (dayOfWeek == DayOfWeek.Saturday && daysAgo % 2 == 0))
                AddVisit(emina.Id, date, 16, 60 + (daysAgo % 3) * 15);

            // Tarik: ~5 visits/week, 1-2h each (skips Sunday)
            if (dayOfWeek != DayOfWeek.Sunday)
                AddVisit(tarik.Id, date, 19, 60 + (daysAgo % 5) * 15);
        }

        await context.GymVisits.AddRangeAsync(gymVisits);
        await context.SaveChangesAsync();
    }

    private static async Task SeedSeminarAttendeesAsync(StrongholdDbContext context)
    {
        if (await context.SeminarAttendees.AnyAsync()) return;

        var users = await context.Users.Where(u => u.Role == Role.GymMember).ToListAsync();
        var seminars = await context.Seminars.ToListAsync();

        var attendees = new List<SeminarAttendee>();

        // Seminar 0 (Ishrana): 4 attendees
        attendees.Add(new SeminarAttendee { UserId = users[0].Id, SeminarId = seminars[0].Id, RegisteredAt = DateTime.UtcNow.AddDays(-5) });
        attendees.Add(new SeminarAttendee { UserId = users[1].Id, SeminarId = seminars[0].Id, RegisteredAt = DateTime.UtcNow.AddDays(-4) });
        attendees.Add(new SeminarAttendee { UserId = users[5].Id, SeminarId = seminars[0].Id, RegisteredAt = DateTime.UtcNow.AddDays(-3) });
        attendees.Add(new SeminarAttendee { UserId = users[7].Id, SeminarId = seminars[0].Id, RegisteredAt = DateTime.UtcNow.AddDays(-2) });

        // Seminar 1 (Povrede): 5 attendees
        attendees.Add(new SeminarAttendee { UserId = users[0].Id, SeminarId = seminars[1].Id, RegisteredAt = DateTime.UtcNow.AddDays(-4) });
        attendees.Add(new SeminarAttendee { UserId = users[2].Id, SeminarId = seminars[1].Id, RegisteredAt = DateTime.UtcNow.AddDays(-3) });
        attendees.Add(new SeminarAttendee { UserId = users[3].Id, SeminarId = seminars[1].Id, RegisteredAt = DateTime.UtcNow.AddDays(-2) });
        attendees.Add(new SeminarAttendee { UserId = users[4].Id, SeminarId = seminars[1].Id, RegisteredAt = DateTime.UtcNow.AddDays(-1) });
        attendees.Add(new SeminarAttendee { UserId = users[8].Id, SeminarId = seminars[1].Id, RegisteredAt = DateTime.UtcNow.AddDays(-1) });

        // Seminar 2 (Suplementacija): 3 attendees
        attendees.Add(new SeminarAttendee { UserId = users[1].Id, SeminarId = seminars[2].Id, RegisteredAt = DateTime.UtcNow.AddDays(-2) });
        attendees.Add(new SeminarAttendee { UserId = users[3].Id, SeminarId = seminars[2].Id, RegisteredAt = DateTime.UtcNow.AddDays(-1) });
        attendees.Add(new SeminarAttendee { UserId = users[7].Id, SeminarId = seminars[2].Id, RegisteredAt = DateTime.UtcNow.AddDays(-1) });

        // Seminar 3 (Mentalna priprema): 4 attendees
        attendees.Add(new SeminarAttendee { UserId = users[2].Id, SeminarId = seminars[3].Id, RegisteredAt = DateTime.UtcNow.AddDays(-3) });
        attendees.Add(new SeminarAttendee { UserId = users[4].Id, SeminarId = seminars[3].Id, RegisteredAt = DateTime.UtcNow.AddDays(-2) });
        attendees.Add(new SeminarAttendee { UserId = users[5].Id, SeminarId = seminars[3].Id, RegisteredAt = DateTime.UtcNow.AddDays(-1) });
        attendees.Add(new SeminarAttendee { UserId = users[6].Id, SeminarId = seminars[3].Id, RegisteredAt = DateTime.UtcNow.AddDays(-1) });

        // Seminar 4 (Snaga vs kardio): 3 attendees
        attendees.Add(new SeminarAttendee { UserId = users[0].Id, SeminarId = seminars[4].Id, RegisteredAt = DateTime.UtcNow.AddDays(-1) });
        attendees.Add(new SeminarAttendee { UserId = users[5].Id, SeminarId = seminars[4].Id, RegisteredAt = DateTime.UtcNow });
        attendees.Add(new SeminarAttendee { UserId = users[8].Id, SeminarId = seminars[4].Id, RegisteredAt = DateTime.UtcNow });

        // Seminar 5 (Deadlift i cucanj): 5 attendees
        attendees.Add(new SeminarAttendee { UserId = users[1].Id, SeminarId = seminars[5].Id, RegisteredAt = DateTime.UtcNow.AddDays(-2) });
        attendees.Add(new SeminarAttendee { UserId = users[3].Id, SeminarId = seminars[5].Id, RegisteredAt = DateTime.UtcNow.AddDays(-1) });
        attendees.Add(new SeminarAttendee { UserId = users[4].Id, SeminarId = seminars[5].Id, RegisteredAt = DateTime.UtcNow.AddDays(-1) });
        attendees.Add(new SeminarAttendee { UserId = users[6].Id, SeminarId = seminars[5].Id, RegisteredAt = DateTime.UtcNow });
        attendees.Add(new SeminarAttendee { UserId = users[8].Id, SeminarId = seminars[5].Id, RegisteredAt = DateTime.UtcNow });

        // Seminar 6 (Oporavak): 3 attendees
        attendees.Add(new SeminarAttendee { UserId = users[0].Id, SeminarId = seminars[6].Id, RegisteredAt = DateTime.UtcNow.AddDays(-1) });
        attendees.Add(new SeminarAttendee { UserId = users[2].Id, SeminarId = seminars[6].Id, RegisteredAt = DateTime.UtcNow });
        attendees.Add(new SeminarAttendee { UserId = users[7].Id, SeminarId = seminars[6].Id, RegisteredAt = DateTime.UtcNow });

        // Seminar 7 (Planiranje obroka): 4 attendees
        attendees.Add(new SeminarAttendee { UserId = users[1].Id, SeminarId = seminars[7].Id, RegisteredAt = DateTime.UtcNow });
        attendees.Add(new SeminarAttendee { UserId = users[4].Id, SeminarId = seminars[7].Id, RegisteredAt = DateTime.UtcNow });
        attendees.Add(new SeminarAttendee { UserId = users[6].Id, SeminarId = seminars[7].Id, RegisteredAt = DateTime.UtcNow });
        attendees.Add(new SeminarAttendee { UserId = users[7].Id, SeminarId = seminars[7].Id, RegisteredAt = DateTime.UtcNow });

        await context.SeminarAttendees.AddRangeAsync(attendees);
        await context.SaveChangesAsync();
    }

    private static async Task SeedAddressesAsync(StrongholdDbContext context)
    {
        if (await context.Addresses.AnyAsync()) return;

        var members = await context.Users
            .Where(u => u.Role == Role.GymMember)
            .OrderBy(u => u.Id)
            .ToListAsync();

        var addresses = new List<Address>
        {
            new() { UserId = members[0].Id, Street = "Marsala Tita 25", City = "Sarajevo", PostalCode = "71000" },
            new() { UserId = members[1].Id, Street = "Zmaja od Bosne 8", City = "Sarajevo", PostalCode = "71000" },
            new() { UserId = members[2].Id, Street = "Kralja Tvrtka 15", City = "Mostar", PostalCode = "88000" },
            new() { UserId = members[3].Id, Street = "Ferhadija 30", City = "Sarajevo", PostalCode = "71000" },
            new() { UserId = members[4].Id, Street = "Bulevar Meše Selimovića 12", City = "Sarajevo", PostalCode = "71000" },
            new() { UserId = members[5].Id, Street = "Branilaca Sarajeva 20", City = "Sarajevo", PostalCode = "71000" },
            new() { UserId = members[6].Id, Street = "Titova 7", City = "Tuzla", PostalCode = "75000" },
            new() { UserId = members[7].Id, Street = "Kulina bana 5", City = "Zenica", PostalCode = "72000" },
            new() { UserId = members[8].Id, Street = "Obala Kulina bana 18", City = "Sarajevo", PostalCode = "71000" },
        };

        await context.Addresses.AddRangeAsync(addresses);
        await context.SaveChangesAsync();
    }
}
