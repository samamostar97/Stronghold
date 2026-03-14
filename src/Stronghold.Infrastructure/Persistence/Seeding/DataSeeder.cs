using Microsoft.EntityFrameworkCore;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Enums;

namespace Stronghold.Infrastructure.Persistence.Seeding;

public static class DataSeeder
{
    public static async Task SeedAsync(StrongholdDbContext context)
    {
        if (await context.Users.AnyAsync(u => u.Role == Role.User))
            return;

        var now = DateTime.UtcNow;

        // ─── USERS (10) ───
        var users = new List<User>
        {
            new()
            {
                FirstName = "Amir", LastName = "Hadžić", Username = "amir.hadzic",
                Email = "amir.hadzic@gmail.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                Phone = "061-111-222", Address = "Titova 15, Sarajevo",
                ProfileImageUrl = "/profile-images/b2c3d4e5-2222-2222-2222-000000000001.jpg",
                Role = Role.User, Level = 4, XP = 620, TotalGymMinutes = 620, CreatedAt = now.AddDays(-90)
            },
            new()
            {
                FirstName = "Emina", LastName = "Kovačević", Username = "emina.kovacevic",
                Email = "emina.kovacevic@gmail.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                Phone = "062-222-333", Address = "Maršala Tita 5, Mostar",
                ProfileImageUrl = "/profile-images/b2c3d4e5-2222-2222-2222-000000000002.jpg",
                Role = Role.User, Level = 3, XP = 310, TotalGymMinutes = 310, CreatedAt = now.AddDays(-75)
            },
            new()
            {
                FirstName = "Tarik", LastName = "Bašić", Username = "tarik.basic",
                Email = "tarik.basic@gmail.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                Phone = "063-333-444", Address = "Zmaja od Bosne 8, Sarajevo",
                ProfileImageUrl = "/profile-images/b2c3d4e5-2222-2222-2222-000000000003.jpg",
                Role = Role.User, Level = 5, XP = 1150, TotalGymMinutes = 1150, CreatedAt = now.AddDays(-120)
            },
            new()
            {
                FirstName = "Lejla", LastName = "Muhić", Username = "lejla.muhic",
                Email = "lejla.muhic@gmail.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                Phone = "064-444-555", Address = "Ferhadija 22, Sarajevo",
                ProfileImageUrl = "/profile-images/b2c3d4e5-2222-2222-2222-000000000004.jpg",
                Role = Role.User, Level = 2, XP = 180, TotalGymMinutes = 180, CreatedAt = now.AddDays(-45)
            },
            new()
            {
                FirstName = "Dino", LastName = "Selimović", Username = "dino.selimovic",
                Email = "dino.selimovic@gmail.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                Phone = "065-555-666", Address = "Mehmeda Spahe 3, Zenica",
                ProfileImageUrl = "/profile-images/b2c3d4e5-2222-2222-2222-000000000005.jpg",
                Role = Role.User, Level = 6, XP = 2200, TotalGymMinutes = 2200, CreatedAt = now.AddDays(-180)
            },
            new()
            {
                FirstName = "Amra", LastName = "Delić", Username = "amra.delic",
                Email = "amra.delic@gmail.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                Phone = "066-666-777", Address = "Branilaca Sarajeva 10, Sarajevo",
                ProfileImageUrl = "/profile-images/b2c3d4e5-2222-2222-2222-000000000006.jpg",
                Role = Role.User, Level = 1, XP = 50, TotalGymMinutes = 50, CreatedAt = now.AddDays(-10)
            },
            new()
            {
                FirstName = "Kenan", LastName = "Hodžić", Username = "kenan.hodzic",
                Email = "kenan.hodzic@gmail.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                Phone = "067-777-888", Address = "Kulina bana 7, Tuzla",
                ProfileImageUrl = "/profile-images/b2c3d4e5-2222-2222-2222-000000000007.jpg",
                Role = Role.User, Level = 3, XP = 400, TotalGymMinutes = 400, CreatedAt = now.AddDays(-60)
            },
            new()
            {
                FirstName = "Sara", LastName = "Ibrahimović", Username = "sara.ibrahimovic",
                Email = "sara.ibrahimovic@gmail.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                Phone = "068-888-999", Address = "Hamze Hume 12, Sarajevo",
                ProfileImageUrl = "/profile-images/b2c3d4e5-2222-2222-2222-000000000008.jpg",
                Role = Role.User, Level = 2, XP = 130, TotalGymMinutes = 130, CreatedAt = now.AddDays(-30)
            },
            new()
            {
                FirstName = "Edin", LastName = "Jusufović", Username = "edin.jusufovic",
                Email = "edin.jusufovic@gmail.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                Phone = "069-999-000", Address = "Safvet-bega Bašagića 4, Bihać",
                ProfileImageUrl = "/profile-images/b2c3d4e5-2222-2222-2222-000000000009.jpg",
                Role = Role.User, Level = 4, XP = 750, TotalGymMinutes = 750, CreatedAt = now.AddDays(-100)
            },
            new()
            {
                FirstName = "Test", LastName = "Korisnik", Username = "mobile",
                Email = "stronghold_mobile@gmail.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                Phone = "060-000-111", Address = "Obala Kulina bana 1, Sarajevo",
                ProfileImageUrl = "/profile-images/b2c3d4e5-2222-2222-2222-000000000010.jpg",
                Role = Role.User, Level = 3, XP = 280, TotalGymMinutes = 280, CreatedAt = now.AddDays(-50)
            }
        };

        await context.Users.AddRangeAsync(users);
        await context.SaveChangesAsync();

        // ─── STAFF (5) ───
        var staff = new List<Staff>
        {
            new()
            {
                FirstName = "Adnan", LastName = "Kovačević",
                Email = "adnan.kovacevic@stronghold.com", Phone = "061-100-200",
                Bio = "Certificirani osobni trener sa 8 godina iskustva u funkcionalnom treningu i bodybuilding-u.",
                ProfileImageUrl = "/staff-images/c3d4e5f6-3333-3333-3333-000000000001.jpg",
                StaffType = StaffType.Trainer, IsActive = true, CreatedAt = now.AddDays(-200)
            },
            new()
            {
                FirstName = "Mirza", LastName = "Halilović",
                Email = "mirza.halilovic@stronghold.com", Phone = "062-200-300",
                Bio = "Specijalist za snagu i kondiciju. Radi sa sportistima i rekreativcima svih nivoa.",
                ProfileImageUrl = "/staff-images/c3d4e5f6-3333-3333-3333-000000000002.jpg",
                StaffType = StaffType.Trainer, IsActive = true, CreatedAt = now.AddDays(-180)
            },
            new()
            {
                FirstName = "Amina", LastName = "Begović",
                Email = "amina.begovic@stronghold.com", Phone = "063-300-400",
                Bio = "Nutricionistica sa magistarskim zvanjem. Specijalizirana za sportsku ishranu i planove prehrane.",
                ProfileImageUrl = "/staff-images/c3d4e5f6-3333-3333-3333-000000000003.jpg",
                StaffType = StaffType.Nutritionist, IsActive = true, CreatedAt = now.AddDays(-160)
            },
            new()
            {
                FirstName = "Faruk", LastName = "Mešić",
                Email = "faruk.mesic@stronghold.com", Phone = "064-400-500",
                Bio = "Trener sa fokusom na gubitak težine i transformacije tijela. NASM certificiran.",
                ProfileImageUrl = "/staff-images/c3d4e5f6-3333-3333-3333-000000000004.jpg",
                StaffType = StaffType.Trainer, IsActive = true, CreatedAt = now.AddDays(-140)
            },
            new()
            {
                FirstName = "Nejra", LastName = "Osmić",
                Email = "nejra.osmic@stronghold.com", Phone = "065-500-600",
                Bio = "Nutricionistica specijalizirana za veganske i vegetarijanske planove prehrane za sportiste.",
                ProfileImageUrl = "/staff-images/c3d4e5f6-3333-3333-3333-000000000005.jpg",
                StaffType = StaffType.Nutritionist, IsActive = true, CreatedAt = now.AddDays(-120)
            }
        };

        await context.Staff.AddRangeAsync(staff);
        await context.SaveChangesAsync();

        // ─── MEMBERSHIP PACKAGES (3) ───
        var packages = new List<MembershipPackage>
        {
            new() { Name = "Basic", Description = "Pristup teretani u standardnim terminima (06:00-22:00). Idealno za početnike.", Price = 30m, CreatedAt = now.AddDays(-200) },
            new() { Name = "Premium", Description = "Neograničen pristup teretani 24/7. Uključuje pristup grupnim treninzima.", Price = 50m, CreatedAt = now.AddDays(-200) },
            new() { Name = "VIP", Description = "Sve iz Premium paketa plus jedan besplatan termin sa trenerom mjesečno.", Price = 80m, CreatedAt = now.AddDays(-200) }
        };

        await context.MembershipPackages.AddRangeAsync(packages);
        await context.SaveChangesAsync();

        // ─── USER MEMBERSHIPS ───
        var memberships = new List<UserMembership>
        {
            // Active memberships
            new()
            {
                UserId = users[0].Id, MembershipPackageId = packages[1].Id,
                UserFullName = $"{users[0].FirstName} {users[0].LastName}",
                PackageName = packages[1].Name, PackagePrice = packages[1].Price,
                StartDate = now.AddDays(-15), EndDate = now.AddDays(15), IsActive = true,
                CreatedAt = now.AddDays(-15)
            },
            new()
            {
                UserId = users[2].Id, MembershipPackageId = packages[2].Id,
                UserFullName = $"{users[2].FirstName} {users[2].LastName}",
                PackageName = packages[2].Name, PackagePrice = packages[2].Price,
                StartDate = now.AddDays(-10), EndDate = now.AddDays(20), IsActive = true,
                CreatedAt = now.AddDays(-10)
            },
            new()
            {
                UserId = users[4].Id, MembershipPackageId = packages[2].Id,
                UserFullName = $"{users[4].FirstName} {users[4].LastName}",
                PackageName = packages[2].Name, PackagePrice = packages[2].Price,
                StartDate = now.AddDays(-5), EndDate = now.AddDays(25), IsActive = true,
                CreatedAt = now.AddDays(-5)
            },
            new()
            {
                UserId = users[6].Id, MembershipPackageId = packages[0].Id,
                UserFullName = $"{users[6].FirstName} {users[6].LastName}",
                PackageName = packages[0].Name, PackagePrice = packages[0].Price,
                StartDate = now.AddDays(-20), EndDate = now.AddDays(10), IsActive = true,
                CreatedAt = now.AddDays(-20)
            },
            new()
            {
                UserId = users[9].Id, MembershipPackageId = packages[1].Id,
                UserFullName = $"{users[9].FirstName} {users[9].LastName}",
                PackageName = packages[1].Name, PackagePrice = packages[1].Price,
                StartDate = now.AddDays(-8), EndDate = now.AddDays(22), IsActive = true,
                CreatedAt = now.AddDays(-8)
            },
            // Expired memberships (history)
            new()
            {
                UserId = users[0].Id, MembershipPackageId = packages[0].Id,
                UserFullName = $"{users[0].FirstName} {users[0].LastName}",
                PackageName = packages[0].Name, PackagePrice = packages[0].Price,
                StartDate = now.AddDays(-75), EndDate = now.AddDays(-45), IsActive = false,
                CreatedAt = now.AddDays(-75)
            },
            new()
            {
                UserId = users[1].Id, MembershipPackageId = packages[1].Id,
                UserFullName = $"{users[1].FirstName} {users[1].LastName}",
                PackageName = packages[1].Name, PackagePrice = packages[1].Price,
                StartDate = now.AddDays(-60), EndDate = now.AddDays(-30), IsActive = false,
                CreatedAt = now.AddDays(-60)
            },
            new()
            {
                UserId = users[3].Id, MembershipPackageId = packages[0].Id,
                UserFullName = $"{users[3].FirstName} {users[3].LastName}",
                PackageName = packages[0].Name, PackagePrice = packages[0].Price,
                StartDate = now.AddDays(-50), EndDate = now.AddDays(-20), IsActive = false,
                CreatedAt = now.AddDays(-50)
            },
        };

        await context.UserMemberships.AddRangeAsync(memberships);
        await context.SaveChangesAsync();

        // ─── GYM VISITS ───
        var gymVisits = new List<GymVisit>
        {
            new()
            {
                UserId = users[0].Id, UserFullName = $"{users[0].FirstName} {users[0].LastName}", Username = users[0].Username,
                CheckInAt = now.AddDays(-14).AddHours(8), CheckOutAt = now.AddDays(-14).AddHours(9).AddMinutes(30),
                DurationMinutes = 90, CreatedAt = now.AddDays(-14)
            },
            new()
            {
                UserId = users[0].Id, UserFullName = $"{users[0].FirstName} {users[0].LastName}", Username = users[0].Username,
                CheckInAt = now.AddDays(-12).AddHours(17), CheckOutAt = now.AddDays(-12).AddHours(18).AddMinutes(15),
                DurationMinutes = 75, CreatedAt = now.AddDays(-12)
            },
            new()
            {
                UserId = users[2].Id, UserFullName = $"{users[2].FirstName} {users[2].LastName}", Username = users[2].Username,
                CheckInAt = now.AddDays(-9).AddHours(6), CheckOutAt = now.AddDays(-9).AddHours(7).AddMinutes(45),
                DurationMinutes = 105, CreatedAt = now.AddDays(-9)
            },
            new()
            {
                UserId = users[4].Id, UserFullName = $"{users[4].FirstName} {users[4].LastName}", Username = users[4].Username,
                CheckInAt = now.AddDays(-4).AddHours(16), CheckOutAt = now.AddDays(-4).AddHours(18),
                DurationMinutes = 120, CreatedAt = now.AddDays(-4)
            },
            new()
            {
                UserId = users[6].Id, UserFullName = $"{users[6].FirstName} {users[6].LastName}", Username = users[6].Username,
                CheckInAt = now.AddDays(-3).AddHours(10), CheckOutAt = now.AddDays(-3).AddHours(11).AddMinutes(30),
                DurationMinutes = 90, CreatedAt = now.AddDays(-3)
            },
            new()
            {
                UserId = users[9].Id, UserFullName = $"{users[9].FirstName} {users[9].LastName}", Username = users[9].Username,
                CheckInAt = now.AddDays(-2).AddHours(7), CheckOutAt = now.AddDays(-2).AddHours(8).AddMinutes(20),
                DurationMinutes = 80, CreatedAt = now.AddDays(-2)
            },
            new()
            {
                UserId = users[2].Id, UserFullName = $"{users[2].FirstName} {users[2].LastName}", Username = users[2].Username,
                CheckInAt = now.AddDays(-1).AddHours(15), CheckOutAt = now.AddDays(-1).AddHours(16).AddMinutes(45),
                DurationMinutes = 105, CreatedAt = now.AddDays(-1)
            },
            // Currently checked in (no checkout)
            new()
            {
                UserId = users[0].Id, UserFullName = $"{users[0].FirstName} {users[0].LastName}", Username = users[0].Username,
                CheckInAt = now.AddHours(-1), CreatedAt = now
            },
            new()
            {
                UserId = users[4].Id, UserFullName = $"{users[4].FirstName} {users[4].LastName}", Username = users[4].Username,
                CheckInAt = now.AddMinutes(-45), CreatedAt = now
            },
        };

        await context.GymVisits.AddRangeAsync(gymVisits);
        await context.SaveChangesAsync();

        // ─── PRODUCT CATEGORIES (4) ───
        var categories = new List<ProductCategory>
        {
            new() { Name = "Suplementi", Description = "Proteini, kreatin, BCAA i ostali suplementi za sportiste.", CreatedAt = now.AddDays(-200) },
            new() { Name = "Oprema", Description = "Shakeri, rukavice, trake za vježbanje i ostala oprema.", CreatedAt = now.AddDays(-200) },
            new() { Name = "Odjeća", Description = "Sportska odjeća za trening i teretanu.", CreatedAt = now.AddDays(-200) },
            new() { Name = "Dodaci", Description = "Torbe, pojasevi i ostali dodaci za teretanu.", CreatedAt = now.AddDays(-200) }
        };

        await context.ProductCategories.AddRangeAsync(categories);
        await context.SaveChangesAsync();

        // ─── SUPPLIERS (3) ───
        var suppliers = new List<Supplier>
        {
            new()
            {
                Name = "Optimum Nutrition", Email = "wholesale@optimumnutrition.com",
                Phone = "+1-800-705-5226", Website = "https://www.optimumnutrition.com",
                CreatedAt = now.AddDays(-200)
            },
            new()
            {
                Name = "MyProtein", Email = "partners@myprotein.com",
                Phone = "+44-161-786-5300", Website = "https://www.myprotein.com",
                CreatedAt = now.AddDays(-200)
            },
            new()
            {
                Name = "Under Armour", Email = "sales@underarmour.com",
                Phone = "+1-888-727-6687", Website = "https://www.underarmour.com",
                CreatedAt = now.AddDays(-200)
            }
        };

        await context.Suppliers.AddRangeAsync(suppliers);
        await context.SaveChangesAsync();

        // ─── PRODUCTS (10) ───
        var products = new List<Product>
        {
            new()
            {
                Name = "Gold Standard 100% Whey", Description = "Najprodavaniji whey protein na svijetu. 24g proteina po serving-u. Dostupan u čokoladnom ukusu.",
                Price = 65.00m, ImageUrl = "/product-images/a1b2c3d4-1111-1111-1111-000000000001.jpg",
                StockQuantity = 25, CategoryId = categories[0].Id, SupplierId = suppliers[0].Id, CreatedAt = now.AddDays(-150)
            },
            new()
            {
                Name = "Impact Whey Protein", Description = "Visokokvalitetni whey protein sa 21g proteina po serving-u. Odličan omjer cijene i kvaliteta.",
                Price = 45.00m, ImageUrl = "/product-images/a1b2c3d4-1111-1111-1111-000000000002.jpg",
                StockQuantity = 30, CategoryId = categories[0].Id, SupplierId = suppliers[1].Id, CreatedAt = now.AddDays(-140)
            },
            new()
            {
                Name = "BCAA 1000 Caps", Description = "Aminokiseline razgranatog lanca za oporavak mišića. 1000mg po kapsuli.",
                Price = 30.00m, ImageUrl = "/product-images/a1b2c3d4-1111-1111-1111-000000000003.jpg",
                StockQuantity = 40, CategoryId = categories[0].Id, SupplierId = suppliers[0].Id, CreatedAt = now.AddDays(-130)
            },
            new()
            {
                Name = "Creatine Monohydrate", Description = "Mikronizovani kreatin monohidrat za povećanje snage i performansi. 5g po serving-u.",
                Price = 25.00m, ImageUrl = "/product-images/a1b2c3d4-1111-1111-1111-000000000004.jpg",
                StockQuantity = 35, CategoryId = categories[0].Id, SupplierId = suppliers[1].Id, CreatedAt = now.AddDays(-120)
            },
            new()
            {
                Name = "C4 Original Pre-Workout", Description = "Eksplozivna energija za trening. Sadrži beta-alanin, kofein i kreatin nitrat.",
                Price = 40.00m, ImageUrl = "/product-images/a1b2c3d4-1111-1111-1111-000000000005.jpg",
                StockQuantity = 20, CategoryId = categories[0].Id, SupplierId = suppliers[0].Id, CreatedAt = now.AddDays(-110)
            },
            new()
            {
                Name = "BlenderBottle Classic Shaker", Description = "BPA-free shaker sa BlenderBall žicom za glatke proteine bez grudvica. 600ml.",
                Price = 12.00m, ImageUrl = "/product-images/a1b2c3d4-1111-1111-1111-000000000006.jpg",
                StockQuantity = 50, CategoryId = categories[1].Id, SupplierId = suppliers[1].Id, CreatedAt = now.AddDays(-100)
            },
            new()
            {
                Name = "Gym Rukavice Pro", Description = "Profesionalne rukavice za trening sa pojačanim dlanovima i podrškom za zglobove.",
                Price = 20.00m, ImageUrl = "/product-images/a1b2c3d4-1111-1111-1111-000000000007.jpg",
                StockQuantity = 30, CategoryId = categories[1].Id, SupplierId = suppliers[2].Id, CreatedAt = now.AddDays(-90)
            },
            new()
            {
                Name = "Resistance Bands Set", Description = "Set od 5 elastičnih traka različitih otpora za zagrijavanje i vježbe snage.",
                Price = 18.00m, ImageUrl = "/product-images/a1b2c3d4-1111-1111-1111-000000000008.jpg",
                StockQuantity = 25, CategoryId = categories[1].Id, SupplierId = suppliers[1].Id, CreatedAt = now.AddDays(-80)
            },
            new()
            {
                Name = "Training T-Shirt DryFit", Description = "Lagana majica za trening sa DryFit tehnologijom koja odvodi znoj.",
                Price = 35.00m, ImageUrl = "/product-images/a1b2c3d4-1111-1111-1111-000000000009.jpg",
                StockQuantity = 40, CategoryId = categories[2].Id, SupplierId = suppliers[2].Id, CreatedAt = now.AddDays(-70)
            },
            new()
            {
                Name = "Gym Torba SportPack", Description = "Prostrana sportska torba sa odvojenim pretincem za obuću i mokru odjeću.",
                Price = 45.00m, ImageUrl = "/product-images/a1b2c3d4-1111-1111-1111-000000000010.jpg",
                StockQuantity = 15, CategoryId = categories[3].Id, SupplierId = suppliers[2].Id, CreatedAt = now.AddDays(-60)
            }
        };

        await context.Products.AddRangeAsync(products);
        await context.SaveChangesAsync();

        // ─── ORDERS + ORDER ITEMS ───
        var order1 = new Order
        {
            UserId = users[0].Id, UserFullName = $"{users[0].FirstName} {users[0].LastName}",
            TotalAmount = 110.00m, DeliveryAddress = users[0].Address!,
            Status = OrderStatus.Shipped, StripePaymentIntentId = "pi_seed_001",
            CreatedAt = now.AddDays(-30),
            Items = new List<OrderItem>
            {
                new() { ProductId = products[0].Id, Quantity = 1, UnitPrice = 65.00m, ProductName = products[0].Name, ProductImageUrl = products[0].ImageUrl },
                new() { ProductId = products[5].Id, Quantity = 1, UnitPrice = 12.00m, ProductName = products[5].Name, ProductImageUrl = products[5].ImageUrl },
                new() { ProductId = products[3].Id, Quantity = 1, UnitPrice = 25.00m, ProductName = products[3].Name, ProductImageUrl = products[3].ImageUrl },
                new() { ProductId = products[7].Id, Quantity = 1, UnitPrice = 18.00m, ProductName = products[7].Name, ProductImageUrl = products[7].ImageUrl, CreatedAt = now.AddDays(-30) }
            }
        };

        var order2 = new Order
        {
            UserId = users[2].Id, UserFullName = $"{users[2].FirstName} {users[2].LastName}",
            TotalAmount = 75.00m, DeliveryAddress = users[2].Address!,
            Status = OrderStatus.Confirmed, StripePaymentIntentId = "pi_seed_002",
            CreatedAt = now.AddDays(-7),
            Items = new List<OrderItem>
            {
                new() { ProductId = products[1].Id, Quantity = 1, UnitPrice = 45.00m, ProductName = products[1].Name, ProductImageUrl = products[1].ImageUrl },
                new() { ProductId = products[4].Id, Quantity = 1, UnitPrice = 40.00m, ProductName = products[4].Name, ProductImageUrl = products[4].ImageUrl, CreatedAt = now.AddDays(-7) }
            }
        };

        var order3 = new Order
        {
            UserId = users[4].Id, UserFullName = $"{users[4].FirstName} {users[4].LastName}",
            TotalAmount = 100.00m, DeliveryAddress = users[4].Address!,
            Status = OrderStatus.Shipped, StripePaymentIntentId = "pi_seed_003",
            CreatedAt = now.AddDays(-45),
            Items = new List<OrderItem>
            {
                new() { ProductId = products[0].Id, Quantity = 1, UnitPrice = 65.00m, ProductName = products[0].Name, ProductImageUrl = products[0].ImageUrl },
                new() { ProductId = products[8].Id, Quantity = 1, UnitPrice = 35.00m, ProductName = products[8].Name, ProductImageUrl = products[8].ImageUrl, CreatedAt = now.AddDays(-45) }
            }
        };

        var order4 = new Order
        {
            UserId = users[9].Id, UserFullName = $"{users[9].FirstName} {users[9].LastName}",
            TotalAmount = 57.00m, DeliveryAddress = users[9].Address!,
            Status = OrderStatus.Pending, StripePaymentIntentId = "pi_seed_004",
            CreatedAt = now.AddDays(-1),
            Items = new List<OrderItem>
            {
                new() { ProductId = products[6].Id, Quantity = 1, UnitPrice = 20.00m, ProductName = products[6].Name, ProductImageUrl = products[6].ImageUrl },
                new() { ProductId = products[2].Id, Quantity = 1, UnitPrice = 30.00m, ProductName = products[2].Name, ProductImageUrl = products[2].ImageUrl, CreatedAt = now.AddDays(-1) }
            }
        };

        var order5 = new Order
        {
            UserId = users[1].Id, UserFullName = $"{users[1].FirstName} {users[1].LastName}",
            TotalAmount = 80.00m, DeliveryAddress = users[1].Address!,
            Status = OrderStatus.Shipped, StripePaymentIntentId = "pi_seed_005",
            CreatedAt = now.AddDays(-20),
            Items = new List<OrderItem>
            {
                new() { ProductId = products[8].Id, Quantity = 1, UnitPrice = 35.00m, ProductName = products[8].Name, ProductImageUrl = products[8].ImageUrl },
                new() { ProductId = products[9].Id, Quantity = 1, UnitPrice = 45.00m, ProductName = products[9].Name, ProductImageUrl = products[9].ImageUrl, CreatedAt = now.AddDays(-20) }
            }
        };

        await context.Orders.AddRangeAsync(order1, order2, order3, order4, order5);
        await context.SaveChangesAsync();

        // ─── APPOINTMENTS ───
        var appointments = new List<Appointment>
        {
            // Completed
            new()
            {
                UserId = users[0].Id, StaffId = staff[0].Id,
                UserFullName = $"{users[0].FirstName} {users[0].LastName}",
                StaffFullName = $"{staff[0].FirstName} {staff[0].LastName}",
                ScheduledAt = now.AddDays(-20).Date.AddHours(9), DurationMinutes = 60,
                Status = AppointmentStatus.Completed, Notes = "Inicijalni trening plan",
                CreatedAt = now.AddDays(-25)
            },
            new()
            {
                UserId = users[2].Id, StaffId = staff[2].Id,
                UserFullName = $"{users[2].FirstName} {users[2].LastName}",
                StaffFullName = $"{staff[2].FirstName} {staff[2].LastName}",
                ScheduledAt = now.AddDays(-15).Date.AddHours(10), DurationMinutes = 60,
                Status = AppointmentStatus.Completed, Notes = "Konsultacija o prehrani",
                CreatedAt = now.AddDays(-20)
            },
            new()
            {
                UserId = users[4].Id, StaffId = staff[1].Id,
                UserFullName = $"{users[4].FirstName} {users[4].LastName}",
                StaffFullName = $"{staff[1].FirstName} {staff[1].LastName}",
                ScheduledAt = now.AddDays(-10).Date.AddHours(14), DurationMinutes = 60,
                Status = AppointmentStatus.Completed,
                CreatedAt = now.AddDays(-15)
            },
            // Approved (upcoming)
            new()
            {
                UserId = users[6].Id, StaffId = staff[0].Id,
                UserFullName = $"{users[6].FirstName} {users[6].LastName}",
                StaffFullName = $"{staff[0].FirstName} {staff[0].LastName}",
                ScheduledAt = now.AddDays(2).Date.AddHours(11), DurationMinutes = 60,
                Status = AppointmentStatus.Approved, Notes = "Personalizirani trening",
                CreatedAt = now.AddDays(-3)
            },
            new()
            {
                UserId = users[9].Id, StaffId = staff[4].Id,
                UserFullName = $"{users[9].FirstName} {users[9].LastName}",
                StaffFullName = $"{staff[4].FirstName} {staff[4].LastName}",
                ScheduledAt = now.AddDays(3).Date.AddHours(9), DurationMinutes = 60,
                Status = AppointmentStatus.Approved, Notes = "Plan prehrane za mršavljenje",
                CreatedAt = now.AddDays(-2)
            },
            // Pending
            new()
            {
                UserId = users[1].Id, StaffId = staff[3].Id,
                UserFullName = $"{users[1].FirstName} {users[1].LastName}",
                StaffFullName = $"{staff[3].FirstName} {staff[3].LastName}",
                ScheduledAt = now.AddDays(5).Date.AddHours(15), DurationMinutes = 60,
                Status = AppointmentStatus.Pending, Notes = "Trening za gubitak težine",
                CreatedAt = now.AddDays(-1)
            },
            new()
            {
                UserId = users[3].Id, StaffId = staff[2].Id,
                UserFullName = $"{users[3].FirstName} {users[3].LastName}",
                StaffFullName = $"{staff[2].FirstName} {staff[2].LastName}",
                ScheduledAt = now.AddDays(4).Date.AddHours(10), DurationMinutes = 60,
                Status = AppointmentStatus.Pending,
                CreatedAt = now.AddDays(-1)
            },
            // Rejected
            new()
            {
                UserId = users[7].Id, StaffId = staff[0].Id,
                UserFullName = $"{users[7].FirstName} {users[7].LastName}",
                StaffFullName = $"{staff[0].FirstName} {staff[0].LastName}",
                ScheduledAt = now.AddDays(-5).Date.AddHours(8), DurationMinutes = 60,
                Status = AppointmentStatus.Rejected, Notes = "Termin zauzet",
                CreatedAt = now.AddDays(-8)
            },
        };

        await context.Appointments.AddRangeAsync(appointments);
        await context.SaveChangesAsync();

        // ─── REVIEWS ───
        var reviews = new List<Review>
        {
            // Product reviews
            new()
            {
                UserId = users[0].Id, UserFullName = $"{users[0].FirstName} {users[0].LastName}",
                Rating = 5, Comment = "Odličan protein! Ukus čokolade je fantastičan i miješa se bez grudvica.",
                ReviewType = ReviewType.Product, ProductId = products[0].Id, CreatedAt = now.AddDays(-25)
            },
            new()
            {
                UserId = users[0].Id, UserFullName = $"{users[0].FirstName} {users[0].LastName}",
                Rating = 4, Comment = "Dobar kreatin, primjetio sam razliku u snazi nakon 2 sedmice.",
                ReviewType = ReviewType.Product, ProductId = products[3].Id, CreatedAt = now.AddDays(-22)
            },
            new()
            {
                UserId = users[2].Id, UserFullName = $"{users[2].FirstName} {users[2].LastName}",
                Rating = 4, Comment = "Kvalitetan whey protein za ovu cijenu. Preporučujem vanila ukus.",
                ReviewType = ReviewType.Product, ProductId = products[1].Id, CreatedAt = now.AddDays(-5)
            },
            new()
            {
                UserId = users[4].Id, UserFullName = $"{users[4].FirstName} {users[4].LastName}",
                Rating = 5, Comment = "Najbolji whey protein na tržištu. Koristim ga godinama.",
                ReviewType = ReviewType.Product, ProductId = products[0].Id, CreatedAt = now.AddDays(-40)
            },
            new()
            {
                UserId = users[1].Id, UserFullName = $"{users[1].FirstName} {users[1].LastName}",
                Rating = 5, Comment = "Super kvalitetna majica, materijal je laganan i brzo se suši.",
                ReviewType = ReviewType.Product, ProductId = products[8].Id, CreatedAt = now.AddDays(-15)
            },
            // Appointment reviews
            new()
            {
                UserId = users[0].Id, UserFullName = $"{users[0].FirstName} {users[0].LastName}",
                Rating = 5, Comment = "Adnan je odličan trener! Napravio mi je savršen plan treninga.",
                ReviewType = ReviewType.Appointment, AppointmentId = appointments[0].Id, CreatedAt = now.AddDays(-18)
            },
            new()
            {
                UserId = users[2].Id, UserFullName = $"{users[2].FirstName} {users[2].LastName}",
                Rating = 4, Comment = "Korisne informacije o prehrani. Amina je vrlo stručna.",
                ReviewType = ReviewType.Appointment, AppointmentId = appointments[1].Id, CreatedAt = now.AddDays(-12)
            },
            new()
            {
                UserId = users[4].Id, UserFullName = $"{users[4].FirstName} {users[4].LastName}",
                Rating = 5, Comment = "Mirza zna svoj posao. Trening je bio intenzivan ali efektivan.",
                ReviewType = ReviewType.Appointment, AppointmentId = appointments[2].Id, CreatedAt = now.AddDays(-8)
            },
        };

        await context.Reviews.AddRangeAsync(reviews);
        await context.SaveChangesAsync();

        // ─── WISHLIST ITEMS ───
        var wishlistItems = new List<WishlistItem>
        {
            new() { UserId = users[0].Id, ProductId = products[4].Id, CreatedAt = now.AddDays(-5) },
            new() { UserId = users[0].Id, ProductId = products[9].Id, CreatedAt = now.AddDays(-3) },
            new() { UserId = users[2].Id, ProductId = products[6].Id, CreatedAt = now.AddDays(-2) },
            new() { UserId = users[9].Id, ProductId = products[0].Id, CreatedAt = now.AddDays(-4) },
            new() { UserId = users[9].Id, ProductId = products[8].Id, CreatedAt = now.AddDays(-1) },
        };

        await context.WishlistItems.AddRangeAsync(wishlistItems);
        await context.SaveChangesAsync();

        // ─── CART ITEMS ───
        var cartItems = new List<CartItem>
        {
            new() { UserId = users[1].Id, ProductId = products[0].Id, Quantity = 1 },
            new() { UserId = users[1].Id, ProductId = products[5].Id, Quantity = 2 },
            new() { UserId = users[3].Id, ProductId = products[3].Id, Quantity = 1 },
            new() { UserId = users[9].Id, ProductId = products[4].Id, Quantity = 1 },
        };

        await context.CartItems.AddRangeAsync(cartItems);
        await context.SaveChangesAsync();

        // ─── NOTIFICATIONS ───
        var notifications = new List<Notification>
        {
            new()
            {
                Title = "Nova narudžba", Message = $"Nova narudžba #{order4.Id} je kreirana.",
                Type = NotificationType.NewOrder, ReferenceId = order4.Id, IsRead = false, CreatedAt = now.AddDays(-1)
            },
            new()
            {
                Title = "Nova rezervacija", Message = $"Korisnik {users[1].FirstName} {users[1].LastName} je zakazao termin sa {staff[3].FirstName} {staff[3].LastName}.",
                Type = NotificationType.NewAppointment, ReferenceId = appointments[5].Id, IsRead = false, CreatedAt = now.AddDays(-1)
            },
            new()
            {
                Title = "Nova rezervacija", Message = $"Korisnik {users[3].FirstName} {users[3].LastName} je zakazao termin sa {staff[2].FirstName} {staff[2].LastName}.",
                Type = NotificationType.NewAppointment, ReferenceId = appointments[6].Id, IsRead = false, CreatedAt = now.AddDays(-1)
            },
            new()
            {
                Title = "Nova narudžba", Message = $"Nova narudžba #{order2.Id} je kreirana.",
                Type = NotificationType.NewOrder, ReferenceId = order2.Id, IsRead = true, CreatedAt = now.AddDays(-7)
            },
            new()
            {
                Title = "Nova narudžba", Message = $"Nova narudžba #{order1.Id} je kreirana.",
                Type = NotificationType.NewOrder, ReferenceId = order1.Id, IsRead = true, CreatedAt = now.AddDays(-30)
            },
        };

        await context.Notifications.AddRangeAsync(notifications);
        await context.SaveChangesAsync();
    }
}
