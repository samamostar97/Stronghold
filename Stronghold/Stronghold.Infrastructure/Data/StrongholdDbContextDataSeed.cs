using Microsoft.EntityFrameworkCore;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;

namespace Stronghold.Infrastructure.Data;

public static class StrongholdDbContextDataSeed
{
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
        await SeedMembershipsAsync(context);
        await SeedAppointmentsAsync(context);
        await SeedOrdersAsync(context);
        await SeedReviewsAsync(context);

        await context.SaveChangesAsync();
    }

    private static async Task SeedMembershipPackagesAsync(StrongholdDbContext context)
    {
        if (await context.MembershipPackages.AnyAsync()) return;

        var packages = new List<MembershipPackage>
        {
            new() { PackageName = "Basic Standard", PackagePrice = 60.00m, Description = "24/7 pristup teretani", IsActive = true },
            new() { PackageName = "Premium Standard", PackagePrice = 90.00m, Description = "24/7 pristup teretani sa uključenim grupnim treninzima", IsActive = true },
            new() { PackageName = "Basic Duo", PackagePrice = 100.00m, Description = "24/7 pristup teretani za parove", IsActive = true },
            new() { PackageName = "Premium Duo", PackagePrice = 150.00m, Description = "24/7 pristup teretani za parove sa uključenim grupnim treninzima", IsActive = true }
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

        var supplements = new List<Supplement>
        {
            // Proteini
            new() { Name = "Whey Protein Gold 2kg", Price = 89.00m, Description = "Premium whey protein izolat sa 24g proteina po porciji", SupplementCategoryId = proteini, SupplierId = suppliers[0].Id },
            new() { Name = "Casein Protein 1kg", Price = 65.00m, Description = "Sporo oslobađajući kazein protein idealan za noć", SupplementCategoryId = proteini, SupplierId = suppliers[1].Id },
            new() { Name = "Vegan Protein Mix 1kg", Price = 55.00m, Description = "Biljni protein od graška i riže", SupplementCategoryId = proteini, SupplierId = suppliers[2].Id },
            new() { Name = "Whey Isolate 1kg", Price = 75.00m, Description = "Čisti whey izolat sa minimalnim mastima i ugljikohidratima", SupplementCategoryId = proteini, SupplierId = suppliers[0].Id },
            new() { Name = "Egg Protein 900g", Price = 60.00m, Description = "Protein iz jaja, odličan za one sa intolerancijom na laktozu", SupplementCategoryId = proteini, SupplierId = suppliers[3].Id },

            // Kreatin
            new() { Name = "Kreatin Monohidrat 500g", Price = 35.00m, Description = "Čisti kreatin monohidrat za povećanje snage", SupplementCategoryId = kreatin, SupplierId = suppliers[1].Id },
            new() { Name = "Kreatin HCL 120 kapsula", Price = 45.00m, Description = "Kreatin hidrohlorid za bolju apsorpciju", SupplementCategoryId = kreatin, SupplierId = suppliers[4].Id },
            new() { Name = "Kre-Alkalyn 120 kapsula", Price = 50.00m, Description = "Puferovani kreatin bez potrebe za fazom punjenja", SupplementCategoryId = kreatin, SupplierId = suppliers[5].Id },
            new() { Name = "Kreatin Monohidrat 1kg", Price = 55.00m, Description = "Ekonomično pakovanje kreatina za dugoročnu upotrebu", SupplementCategoryId = kreatin, SupplierId = suppliers[2].Id },

            // Aminokiseline
            new() { Name = "BCAA 2:1:1 400g", Price = 40.00m, Description = "Razgranati aminokiselinski lanac za oporavak mišića", SupplementCategoryId = amino, SupplierId = suppliers[0].Id },
            new() { Name = "EAA 350g", Price = 48.00m, Description = "Esencijalne aminokiseline za kompletnu podršku mišićima", SupplementCategoryId = amino, SupplierId = suppliers[3].Id },
            new() { Name = "Glutamin 500g", Price = 38.00m, Description = "L-Glutamin za oporavak i imunitet", SupplementCategoryId = amino, SupplierId = suppliers[1].Id },
            new() { Name = "L-Karnitin 1000ml", Price = 32.00m, Description = "Tečni L-karnitin za sagorijevanje masti", SupplementCategoryId = amino, SupplierId = suppliers[4].Id },
            new() { Name = "Beta Alanin 300g", Price = 35.00m, Description = "Za povećanje izdržljivosti tokom treninga", SupplementCategoryId = amino, SupplierId = suppliers[5].Id },

            // Vitamini i minerali
            new() { Name = "Multivitamin kompleks 60 tableta", Price = 25.00m, Description = "Kompletan multivitamin za sportiste", SupplementCategoryId = vitamini, SupplierId = suppliers[2].Id },
            new() { Name = "Vitamin D3 5000IU 120 kapsula", Price = 18.00m, Description = "Vitamin D3 za kosti i imunitet", SupplementCategoryId = vitamini, SupplierId = suppliers[0].Id },
            new() { Name = "Omega 3 120 kapsula", Price = 28.00m, Description = "Riblje ulje sa EPA i DHA", SupplementCategoryId = vitamini, SupplierId = suppliers[1].Id },
            new() { Name = "ZMA 90 kapsula", Price = 22.00m, Description = "Cink, magnezijum i vitamin B6 za bolji san i oporavak", SupplementCategoryId = vitamini, SupplierId = suppliers[3].Id },
            new() { Name = "Magnezijum Citrat 120 tableta", Price = 15.00m, Description = "Magnezijum za mišiće i nervni sistem", SupplementCategoryId = vitamini, SupplierId = suppliers[4].Id },

            // Pre-workout
            new() { Name = "Pre-Workout Extreme 300g", Price = 42.00m, Description = "Snažna pre-workout formula sa kofeinom i beta alaninom", SupplementCategoryId = preworkout, SupplierId = suppliers[5].Id },
            new() { Name = "Pump Matrix 350g", Price = 38.00m, Description = "Pre-workout bez stimulansa za bolju pumpu", SupplementCategoryId = preworkout, SupplierId = suppliers[0].Id },
            new() { Name = "Energy Boost 250g", Price = 30.00m, Description = "Lagani pre-workout za početnike", SupplementCategoryId = preworkout, SupplierId = suppliers[2].Id },
            new() { Name = "Nitric Oxide Booster 200g", Price = 35.00m, Description = "Za poboljšanje protoka krvi i izdržljivosti", SupplementCategoryId = preworkout, SupplierId = suppliers[1].Id },

            // Mass gaineri
            new() { Name = "Mass Gainer 3kg", Price = 70.00m, Description = "Visokokalorični gainer za povećanje mase", SupplementCategoryId = gaineri, SupplierId = suppliers[3].Id },
            new() { Name = "Serious Mass 2.7kg", Price = 65.00m, Description = "Gainer sa kompleksnim ugljikohidratima", SupplementCategoryId = gaineri, SupplierId = suppliers[4].Id },
            new() { Name = "Clean Gainer 2kg", Price = 58.00m, Description = "Gainer sa manje šećera i više proteina", SupplementCategoryId = gaineri, SupplierId = suppliers[5].Id },
            new() { Name = "Weight Gainer Pro 4kg", Price = 85.00m, Description = "Profesionalni gainer za hard gainere", SupplementCategoryId = gaineri, SupplierId = suppliers[0].Id }
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
            new() { FirstName = "Lamija", LastName = "Bašić", Email = "lamija.basic@stronghold.ba", PhoneNumber = "+38762567890" }
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
            new() { Question = "Da li imate parking?", Answer = "Da, imamo besplatan parking za članove sa preko 50 parking mjesta." }
        };

        await context.FAQs.AddRangeAsync(faqs);
        await context.SaveChangesAsync();
    }

    private static async Task SeedSeminarsAsync(StrongholdDbContext context)
    {
        if (await context.Seminars.AnyAsync()) return;

        var seminars = new List<Seminar>
        {
            new() { Topic = "Osnove pravilne ishrane za sportiste", SpeakerName = "Dr. Selma Hodžić", EventDate = DateTime.UtcNow.AddDays(14) },
            new() { Topic = "Kako izbjeći povrede tokom treninga", SpeakerName = "Amar Hadžić", EventDate = DateTime.UtcNow.AddDays(21) },
            new() { Topic = "Suplementacija za početnike", SpeakerName = "Adnan Mujić", EventDate = DateTime.UtcNow.AddDays(28) },
            new() { Topic = "Mentalna priprema i motivacija", SpeakerName = "Lejla Begović", EventDate = DateTime.UtcNow.AddDays(35) },
            new() { Topic = "Trening snage vs. kardio - šta je bolje?", SpeakerName = "Eldin Mahmutović", EventDate = DateTime.UtcNow.AddDays(42) }
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
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin")
            },
            // Gym Members
            new()
            {
                FirstName = "Haris",
                LastName = "Muslimović",
                Username = "haris.muslimovic",
                Email = "haris.muslimovic@gmail.com",
                PhoneNumber = "+38761111111",
                Gender = Gender.Male,
                Role = Role.GymMember,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("haris123")
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
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("amela123")
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
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("dino123")
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
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("lejla123")
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
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("armin123")
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
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("naida123")
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
            new() { UserId = users[5].Id, MembershipPackageId = packages[1].Id, StartDate = DateTime.UtcNow.AddDays(-7), EndDate = DateTime.UtcNow.AddMonths(1).AddDays(-7) }
        };

        await context.Memberships.AddRangeAsync(memberships);
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
            // Trener appointments
            new() { UserId = users[0].Id, TrainerId = trainers[0].Id, AppointmentDate = DateTime.UtcNow.AddDays(2).AddHours(10) },
            new() { UserId = users[1].Id, TrainerId = trainers[1].Id, AppointmentDate = DateTime.UtcNow.AddDays(3).AddHours(14) },
            new() { UserId = users[2].Id, TrainerId = trainers[2].Id, AppointmentDate = DateTime.UtcNow.AddDays(4).AddHours(16) },
            new() { UserId = users[3].Id, TrainerId = trainers[0].Id, AppointmentDate = DateTime.UtcNow.AddDays(5).AddHours(9) },
            new() { UserId = users[4].Id, TrainerId = trainers[3].Id, AppointmentDate = DateTime.UtcNow.AddDays(6).AddHours(11) },
            // Nutritionist appointments
            new() { UserId = users[0].Id, NutritionistId = nutritionists[0].Id, AppointmentDate = DateTime.UtcNow.AddDays(7).AddHours(13) },
            new() { UserId = users[2].Id, NutritionistId = nutritionists[1].Id, AppointmentDate = DateTime.UtcNow.AddDays(8).AddHours(15) },
            new() { UserId = users[5].Id, NutritionistId = nutritionists[2].Id, AppointmentDate = DateTime.UtcNow.AddDays(9).AddHours(10) }
        };

        await context.Appointments.AddRangeAsync(appointments);
        await context.SaveChangesAsync();
    }

    private static async Task SeedOrdersAsync(StrongholdDbContext context)
    {
        if (await context.Orders.AnyAsync()) return;

        var users = await context.Users.Where(u => u.Role == Role.GymMember).ToListAsync();
        var supplements = await context.Supplements.ToListAsync();

        var orders = new List<Order>
        {
            new()
            {
                UserId = users[0].Id,
                TotalAmount = 124.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-10),
                Status = OrderStatus.Delivered,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[0].Id, Quantity = 1, UnitPrice = supplements[0].Price },
                    new() { SupplementId = supplements[5].Id, Quantity = 1, UnitPrice = supplements[5].Price }
                }
            },
            new()
            {
                UserId = users[1].Id,
                TotalAmount = 89.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-5),
                Status = OrderStatus.Shipped,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[0].Id, Quantity = 1, UnitPrice = supplements[0].Price }
                }
            },
            new()
            {
                UserId = users[2].Id,
                TotalAmount = 147.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-3),
                Status = OrderStatus.Processing,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[9].Id, Quantity = 2, UnitPrice = supplements[9].Price },
                    new() { SupplementId = supplements[14].Id, Quantity = 1, UnitPrice = supplements[14].Price },
                    new() { SupplementId = supplements[17].Id, Quantity = 1, UnitPrice = supplements[17].Price }
                }
            },
            new()
            {
                UserId = users[3].Id,
                TotalAmount = 70.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-1),
                Status = OrderStatus.Pending,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[23].Id, Quantity = 1, UnitPrice = supplements[23].Price }
                }
            },
            new()
            {
                UserId = users[4].Id,
                TotalAmount = 180.00m,
                PurchaseDate = DateTime.UtcNow.AddDays(-20),
                Status = OrderStatus.Delivered,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = supplements[0].Id, Quantity = 1, UnitPrice = supplements[0].Price },
                    new() { SupplementId = supplements[19].Id, Quantity = 1, UnitPrice = supplements[19].Price },
                    new() { SupplementId = supplements[6].Id, Quantity = 1, UnitPrice = supplements[6].Price }
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

        var reviews = new List<Review>
        {
            new() { UserId = users[0].Id, SupplementId = supplements[0].Id, Rating = 5, Comment = "Odličan protein, ukus je fantastičan i dobro se otapa!" },
            new() { UserId = users[1].Id, SupplementId = supplements[0].Id, Rating = 4, Comment = "Dobar proizvod, ali cijena je malo visoka." },
            new() { UserId = users[2].Id, SupplementId = supplements[5].Id, Rating = 5, Comment = "Primjetio sam poboljšanje snage već nakon 2 sedmice korištenja." },
            new() { UserId = users[3].Id, SupplementId = supplements[9].Id, Rating = 4, Comment = "BCAA pomaže sa oporavkom, preporučujem." },
            new() { UserId = users[4].Id, SupplementId = supplements[19].Id, Rating = 5, Comment = "Najbolji pre-workout koji sam probao, daje energiju bez nervoze." },
            new() { UserId = users[5].Id, SupplementId = supplements[14].Id, Rating = 3, Comment = "Solidan multivitamin, ništa posebno ali radi posao." },
            new() { UserId = users[0].Id, SupplementId = supplements[23].Id, Rating = 4, Comment = "Dobar gainer za one koji teško dobijaju na masi." },
            new() { UserId = users[2].Id, SupplementId = supplements[1].Id, Rating = 5, Comment = "Kazein je super za prije spavanja, osjećam se manje gladan ujutro." }
        };

        await context.Reviews.AddRangeAsync(reviews);
        await context.SaveChangesAsync();
    }
}
