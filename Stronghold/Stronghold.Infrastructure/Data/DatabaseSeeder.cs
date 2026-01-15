using Microsoft.EntityFrameworkCore;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;

namespace Stronghold.Infrastructure.Data;

public class DatabaseSeeder
{
    private readonly StrongholdDbContext _context;

    public DatabaseSeeder(StrongholdDbContext context)
    {
        _context = context;
    }

    public async Task SeedAsync()
    {
        // Core entities (must be seeded first)
        await SeedAdminAsync();
        await SeedGymMembersAsync();
        await SeedMembershipPackagesAsync();

        // Products and staff
        await SeedSupplementCategoriesAsync();
        await SeedSuppliersAsync();
        await SeedSupplementsAsync();
        await SeedTrainersAsync();
        await SeedNutritionistsAsync();
        await SeedSeminarsAsync();
        await SeedFAQsAsync();

        // Business data (depends on users, packages, supplements)
        await SeedMembershipsAsync();
        await SeedMembershipPaymentsAsync();
        await SeedGymVisitsAsync();
        await SeedOrdersAsync();
    }

    private async Task SeedAdminAsync()
    {
        if (await _context.Users.AnyAsync(u => u.Role == Role.Admin))
            return;

        var admin = new User
        {
            FirstName = "Admin",
            LastName = "User",
            Username = "admin",
            Email = "admin@stronghold.com",
            PhoneNumber = "0000000000",
            Gender = Gender.Male,
            Role = Role.Admin,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin")
        };

        _context.Users.Add(admin);
        await _context.SaveChangesAsync();
    }
    private async Task SeedGymMembersAsync()
    {
        if (await _context.Users.AnyAsync(u => u.Role == Role.GymMember))
            return;

        var members = new List<User>
    {
        new()
        {
            FirstName = "Samir",
            LastName = "Obradovic",
            Username = "samir",
            Email = "samir@stronghold.com",
            PhoneNumber = "061111111",
            Gender = Gender.Male,
            Role = Role.GymMember,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("test123")
        },
        new()
        {
            FirstName = "Marko",
            LastName = "Kovacevic",
            Username = "marko",
            Email = "marko@stronghold.com",
            PhoneNumber = "062222222",
            Gender = Gender.Male,
            Role = Role.GymMember,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("test123")
        },
        new()
        {
            FirstName = "Ana",
            LastName = "Petrovic",
            Username = "ana",
            Email = "ana@stronghold.com",
            PhoneNumber = "063333333",
            Gender = Gender.Female,
            Role = Role.GymMember,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("test123")
        },
        new()
        {
            FirstName = "Ivana",
            LastName = "Jukic",
            Username = "ivana",
            Email = "ivana@stronghold.com",
            PhoneNumber = "064444444",
            Gender = Gender.Female,
            Role = Role.GymMember,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("test123")
        },
        new()
        {
            FirstName = "Denis",
            LastName = "Basic",
            Username = "denis",
            Email = "denis@stronghold.com",
            PhoneNumber = "065555555",
            Gender = Gender.Male,
            Role = Role.GymMember,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("test123")
        }
    };

        _context.Users.AddRange(members);
        await _context.SaveChangesAsync();
    }

    private async Task SeedMembershipPackagesAsync()
    {
        if (await _context.MembershipPackages.AnyAsync())
            return;

        var packages = new List<MembershipPackage>
        {
            new()
            {
                PackageName = "Basic Monthly",
                PackagePrice = 60.00m,
                Description = "Basic membership, with a 24/7 access to the gym",
                IsActive = true
            },
            new()
            {
                PackageName = "Premium Monthly",
                PackagePrice = 90.00m,
                Description = "Premium membership, with a 24/7 access to the gym and access to group workouts",
                IsActive = true
            },
            new()
            {
                PackageName = "Basic Duo Monthly",
                PackagePrice = 100.00m,
                Description = "Basic membership for partners, 24/7 access to the gym",
                IsActive = true
            },
            new()
            {
                PackageName = "Premium Duo Monthly",
                PackagePrice = 150.00m,
                Description = "Premium membership for partners, 24/7 access to the gym, and access to group workouts for both partners",
                IsActive = true
            }
        };

        _context.MembershipPackages.AddRange(packages);
        await _context.SaveChangesAsync();
    }

    private async Task SeedSupplementCategoriesAsync()
    {
        if (await _context.SupplementCategories.AnyAsync())
            return;

        var categories = new List<SupplementCategory>
        {
            new() { Name = "Protein" },
            new() { Name = "Pre-Workout" },
            new() { Name = "Creatine" },
            new() { Name = "Vitamins" },
            new() { Name = "Amino Acids" }
        };

        _context.SupplementCategories.AddRange(categories);
        await _context.SaveChangesAsync();
    }

    private async Task SeedSuppliersAsync()
    {
        if (await _context.Suppliers.AnyAsync())
            return;

        var suppliers = new List<Supplier>
        {
            new() { Name = "Optimum Nutrition", Website = "https://www.optimumnutrition.com" },
            new() { Name = "MuscleTech", Website = "https://www.muscletech.com" },
            new() { Name = "BSN", Website = "https://www.bsnonline.com" },
            new() { Name = "Dymatize", Website = "https://www.dymatize.com" }
        };

        _context.Suppliers.AddRange(suppliers);
        await _context.SaveChangesAsync();
    }

    private async Task SeedSupplementsAsync()
    {
        if (await _context.Supplements.AnyAsync())
            return;

        var proteinCategory = await _context.SupplementCategories.FirstAsync(c => c.Name == "Protein");
        var preWorkoutCategory = await _context.SupplementCategories.FirstAsync(c => c.Name == "Pre-Workout");
        var creatineCategory = await _context.SupplementCategories.FirstAsync(c => c.Name == "Creatine");

        var optimum = await _context.Suppliers.FirstAsync(s => s.Name == "Optimum Nutrition");
        var muscleTech = await _context.Suppliers.FirstAsync(s => s.Name == "MuscleTech");

        var supplements = new List<Supplement>
        {
            new() { Name = "Gold Standard Whey", Price = 59.99m, Description = "24g protein per serving", SupplementCategoryId = proteinCategory.Id, SupplierId = optimum.Id },
            new() { Name = "Nitro-Tech Whey", Price = 54.99m, Description = "30g protein per serving", SupplementCategoryId = proteinCategory.Id, SupplierId = muscleTech.Id },
            new() { Name = "C4 Original", Price = 29.99m, Description = "Pre-workout energy boost", SupplementCategoryId = preWorkoutCategory.Id, SupplierId = optimum.Id },
            new() { Name = "Cell-Tech Creatine", Price = 34.99m, Description = "Creatine monohydrate formula", SupplementCategoryId = creatineCategory.Id, SupplierId = muscleTech.Id }
        };

        _context.Supplements.AddRange(supplements);
        await _context.SaveChangesAsync();
    }

    private async Task SeedTrainersAsync()
    {
        if (await _context.Trainers.AnyAsync())
            return;

        var trainers = new List<Trainer>
        {
            new() { FirstName = "John", LastName = "Smith", Email = "john.smith@stronghold.com", PhoneNumber = "1234567890" },
            new() { FirstName = "Sarah", LastName = "Johnson", Email = "sarah.johnson@stronghold.com", PhoneNumber = "1234567891" },
            new() { FirstName = "Mike", LastName = "Williams", Email = "mike.williams@stronghold.com", PhoneNumber = "1234567892" }
        };

        _context.Trainers.AddRange(trainers);
        await _context.SaveChangesAsync();
    }

    private async Task SeedNutritionistsAsync()
    {
        if (await _context.Nutritionists.AnyAsync())
            return;

        var nutritionists = new List<Nutritionist>
        {
            new() { FirstName = "Emily", LastName = "Davis", Email = "emily.davis@stronghold.com", PhoneNumber = "1234567893" },
            new() { FirstName = "David", LastName = "Brown", Email = "david.brown@stronghold.com", PhoneNumber = "1234567894" }
        };

        _context.Nutritionists.AddRange(nutritionists);
        await _context.SaveChangesAsync();
    }

    private async Task SeedSeminarsAsync()
    {
        if (await _context.Seminars.AnyAsync())
            return;

        var seminars = new List<Seminar>
        {
            new() { Topic = "Nutrition Basics for Muscle Building", SpeakerName = "Dr. Emily Davis", EventDate = DateTime.UtcNow.AddDays(14) },
            new() { Topic = "Advanced Training Techniques", SpeakerName = "John Smith", EventDate = DateTime.UtcNow.AddDays(21) },
            new() { Topic = "Recovery and Rest Days", SpeakerName = "Sarah Johnson", EventDate = DateTime.UtcNow.AddDays(28) }
        };

        _context.Seminars.AddRange(seminars);
        await _context.SaveChangesAsync();
    }

    private async Task SeedFAQsAsync()
    {
        if (await _context.FAQs.AnyAsync())
            return;

        var faqs = new List<FAQ>
        {
            new() { Question = "What are the gym opening hours?", Answer = "We are open Monday to Friday 6 AM - 10 PM, Saturday and Sunday 8 AM - 8 PM." },
            new() { Question = "How do I cancel my membership?", Answer = "You can cancel your membership by contacting our front desk or through your account settings." },
            new() { Question = "Do you offer personal training?", Answer = "Yes, we have certified personal trainers available. You can book sessions through the app." },
            new() { Question = "Is there a free trial available?", Answer = "Yes, we offer a 7-day free trial for new members." }
        };

        _context.FAQs.AddRange(faqs);
        await _context.SaveChangesAsync();
    }

    private async Task SeedMembershipsAsync()
    {
        if (await _context.Memberships.AnyAsync())
            return;

        // Get gym members (skip admin)
        var gymMembers = await _context.Users
            .Where(u => u.Role == Role.GymMember)
            .Take(4) // Leave 1 member without membership for testing
            .ToListAsync();

        // Get packages
        var basicPackage = await _context.MembershipPackages.FirstAsync(p => p.PackageName == "Basic Monthly");
        var premiumPackage = await _context.MembershipPackages.FirstAsync(p => p.PackageName == "Premium Monthly");

        var now = DateTime.UtcNow;

        var memberships = new List<Membership>
        {
            // 3 members with Basic package
            new() { UserId = gymMembers[0].Id, MembershipPackageId = basicPackage.Id, StartDate = now.AddDays(-20), EndDate = now.AddDays(10) },
            new() { UserId = gymMembers[1].Id, MembershipPackageId = basicPackage.Id, StartDate = now.AddDays(-15), EndDate = now.AddDays(15) },
            new() { UserId = gymMembers[2].Id, MembershipPackageId = basicPackage.Id, StartDate = now.AddDays(-25), EndDate = now.AddDays(5) },
            // 1 member with Premium package
            new() { UserId = gymMembers[3].Id, MembershipPackageId = premiumPackage.Id, StartDate = now.AddDays(-10), EndDate = now.AddDays(20) }
        };

        _context.Memberships.AddRange(memberships);
        await _context.SaveChangesAsync();
    }

    private async Task SeedMembershipPaymentsAsync()
    {
        if (await _context.MembershipPaymentHistory.AnyAsync())
            return;

        var gymMembers = await _context.Users
            .Where(u => u.Role == Role.GymMember)
            .Take(4)
            .ToListAsync();

        var basicPackage = await _context.MembershipPackages.FirstAsync(p => p.PackageName == "Basic Monthly");
        var premiumPackage = await _context.MembershipPackages.FirstAsync(p => p.PackageName == "Premium Monthly");

        var now = DateTime.UtcNow;
        var thisMonth = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
        var lastMonth = thisMonth.AddMonths(-1);

        var payments = new List<MembershipPaymentHistory>
        {
            // Last month payments (3 payments = 180 KM from basic)
            new()
            {
                UserId = gymMembers[0].Id,
                MembershipPackageId = basicPackage.Id,
                AmountPaid = basicPackage.PackagePrice,
                PaymentDate = lastMonth.AddDays(5),
                StartDate = lastMonth.AddDays(5),
                EndDate = lastMonth.AddDays(35)
            },
            new()
            {
                UserId = gymMembers[1].Id,
                MembershipPackageId = basicPackage.Id,
                AmountPaid = basicPackage.PackagePrice,
                PaymentDate = lastMonth.AddDays(10),
                StartDate = lastMonth.AddDays(10),
                EndDate = lastMonth.AddDays(40)
            },
            new()
            {
                UserId = gymMembers[2].Id,
                MembershipPackageId = basicPackage.Id,
                AmountPaid = basicPackage.PackagePrice,
                PaymentDate = lastMonth.AddDays(15),
                StartDate = lastMonth.AddDays(15),
                EndDate = lastMonth.AddDays(45)
            },

            // This month payments (4 payments = 270 KM, showing growth!)
            new()
            {
                UserId = gymMembers[0].Id,
                MembershipPackageId = basicPackage.Id,
                AmountPaid = basicPackage.PackagePrice,
                PaymentDate = thisMonth.AddDays(2),
                StartDate = thisMonth.AddDays(2),
                EndDate = thisMonth.AddDays(32)
            },
            new()
            {
                UserId = gymMembers[1].Id,
                MembershipPackageId = basicPackage.Id,
                AmountPaid = basicPackage.PackagePrice,
                PaymentDate = thisMonth.AddDays(5),
                StartDate = thisMonth.AddDays(5),
                EndDate = thisMonth.AddDays(35)
            },
            new()
            {
                UserId = gymMembers[2].Id,
                MembershipPackageId = basicPackage.Id,
                AmountPaid = basicPackage.PackagePrice,
                PaymentDate = thisMonth.AddDays(8),
                StartDate = thisMonth.AddDays(8),
                EndDate = thisMonth.AddDays(38)
            },
            new()
            {
                UserId = gymMembers[3].Id,
                MembershipPackageId = premiumPackage.Id,
                AmountPaid = premiumPackage.PackagePrice,
                PaymentDate = thisMonth.AddDays(10),
                StartDate = thisMonth.AddDays(10),
                EndDate = thisMonth.AddDays(40)
            }
        };

        _context.MembershipPaymentHistory.AddRange(payments);
        await _context.SaveChangesAsync();
    }

    private async Task SeedGymVisitsAsync()
    {
        if (await _context.GymVisits.AnyAsync())
            return;

        var gymMembers = await _context.Users
            .Where(u => u.Role == Role.GymMember)
            .Take(4)
            .ToListAsync();

        var now = DateTime.UtcNow;

        // Calculate start of this week (Monday)
        var dayOfWeek = (int)now.DayOfWeek;
        var monday = (int)DayOfWeek.Monday;
        var daysToMonday = (7 + dayOfWeek - monday) % 7;
        var startOfThisWeek = now.Date.AddDays(-daysToMonday);
        var startOfLastWeek = startOfThisWeek.AddDays(-7);

        var visits = new List<GymVisit>();

        // Last week: 12 visits (fewer)
        // Monday - 2 visits
        visits.Add(CreateVisit(gymMembers[0].Id, startOfLastWeek.AddHours(8)));
        visits.Add(CreateVisit(gymMembers[1].Id, startOfLastWeek.AddHours(17)));
        // Tuesday - 2 visits
        visits.Add(CreateVisit(gymMembers[2].Id, startOfLastWeek.AddDays(1).AddHours(9)));
        visits.Add(CreateVisit(gymMembers[3].Id, startOfLastWeek.AddDays(1).AddHours(18)));
        // Wednesday - 3 visits
        visits.Add(CreateVisit(gymMembers[0].Id, startOfLastWeek.AddDays(2).AddHours(7)));
        visits.Add(CreateVisit(gymMembers[1].Id, startOfLastWeek.AddDays(2).AddHours(12)));
        visits.Add(CreateVisit(gymMembers[2].Id, startOfLastWeek.AddDays(2).AddHours(19)));
        // Thursday - 2 visits
        visits.Add(CreateVisit(gymMembers[0].Id, startOfLastWeek.AddDays(3).AddHours(8)));
        visits.Add(CreateVisit(gymMembers[3].Id, startOfLastWeek.AddDays(3).AddHours(16)));
        // Friday - 2 visits
        visits.Add(CreateVisit(gymMembers[1].Id, startOfLastWeek.AddDays(4).AddHours(10)));
        visits.Add(CreateVisit(gymMembers[2].Id, startOfLastWeek.AddDays(4).AddHours(17)));
        // Saturday - 1 visit
        visits.Add(CreateVisit(gymMembers[0].Id, startOfLastWeek.AddDays(5).AddHours(11)));

        // This week: 18 visits (more - showing growth!)
        // Only add visits for days that have passed
        var daysPassedThisWeek = (int)(now.Date - startOfThisWeek).TotalDays;

        // Monday - 3 visits
        if (daysPassedThisWeek >= 0)
        {
            visits.Add(CreateVisit(gymMembers[0].Id, startOfThisWeek.AddHours(7)));
            visits.Add(CreateVisit(gymMembers[1].Id, startOfThisWeek.AddHours(12)));
            visits.Add(CreateVisit(gymMembers[2].Id, startOfThisWeek.AddHours(18)));
        }
        // Tuesday - 4 visits
        if (daysPassedThisWeek >= 1)
        {
            visits.Add(CreateVisit(gymMembers[0].Id, startOfThisWeek.AddDays(1).AddHours(8)));
            visits.Add(CreateVisit(gymMembers[1].Id, startOfThisWeek.AddDays(1).AddHours(11)));
            visits.Add(CreateVisit(gymMembers[2].Id, startOfThisWeek.AddDays(1).AddHours(16)));
            visits.Add(CreateVisit(gymMembers[3].Id, startOfThisWeek.AddDays(1).AddHours(19)));
        }
        // Wednesday - 3 visits
        if (daysPassedThisWeek >= 2)
        {
            visits.Add(CreateVisit(gymMembers[0].Id, startOfThisWeek.AddDays(2).AddHours(9)));
            visits.Add(CreateVisit(gymMembers[2].Id, startOfThisWeek.AddDays(2).AddHours(14)));
            visits.Add(CreateVisit(gymMembers[3].Id, startOfThisWeek.AddDays(2).AddHours(20)));
        }
        // Thursday - 4 visits
        if (daysPassedThisWeek >= 3)
        {
            visits.Add(CreateVisit(gymMembers[0].Id, startOfThisWeek.AddDays(3).AddHours(7)));
            visits.Add(CreateVisit(gymMembers[1].Id, startOfThisWeek.AddDays(3).AddHours(10)));
            visits.Add(CreateVisit(gymMembers[2].Id, startOfThisWeek.AddDays(3).AddHours(15)));
            visits.Add(CreateVisit(gymMembers[3].Id, startOfThisWeek.AddDays(3).AddHours(18)));
        }
        // Friday - 2 visits
        if (daysPassedThisWeek >= 4)
        {
            visits.Add(CreateVisit(gymMembers[0].Id, startOfThisWeek.AddDays(4).AddHours(9)));
            visits.Add(CreateVisit(gymMembers[1].Id, startOfThisWeek.AddDays(4).AddHours(17)));
        }
        // Saturday - 2 visits
        if (daysPassedThisWeek >= 5)
        {
            visits.Add(CreateVisit(gymMembers[2].Id, startOfThisWeek.AddDays(5).AddHours(10)));
            visits.Add(CreateVisit(gymMembers[3].Id, startOfThisWeek.AddDays(5).AddHours(14)));
        }

        _context.GymVisits.AddRange(visits);
        await _context.SaveChangesAsync();
    }

    private static GymVisit CreateVisit(int userId, DateTime checkIn)
    {
        // Each visit lasts 1-2 hours
        var random = new Random();
        var duration = TimeSpan.FromMinutes(60 + random.Next(60));

        return new GymVisit
        {
            UserId = userId,
            CheckInTime = checkIn,
            CheckOutTime = checkIn.Add(duration)
        };
    }

    private async Task SeedOrdersAsync()
    {
        if (await _context.Orders.AnyAsync())
            return;

        var gymMembers = await _context.Users
            .Where(u => u.Role == Role.GymMember)
            .Take(4)
            .ToListAsync();

        var supplements = await _context.Supplements.ToListAsync();
        var wheyProtein = supplements.First(s => s.Name == "Gold Standard Whey");
        var preWorkout = supplements.First(s => s.Name == "C4 Original");
        var creatine = supplements.First(s => s.Name == "Cell-Tech Creatine");
        var nitroTech = supplements.First(s => s.Name == "Nitro-Tech Whey");

        var now = DateTime.UtcNow;

        // Create orders spread over last 30 days
        // Gold Standard Whey will be the bestseller (8 units sold)
        var orders = new List<Order>
        {
            // Order 1: 25 days ago
            new()
            {
                UserId = gymMembers[0].Id,
                PurchaseDate = now.AddDays(-25),
                IsDelivered = true,
                TotalAmount = wheyProtein.Price * 2 + preWorkout.Price,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = wheyProtein.Id, Quantity = 2, UnitPrice = wheyProtein.Price },
                    new() { SupplementId = preWorkout.Id, Quantity = 1, UnitPrice = preWorkout.Price }
                }
            },
            // Order 2: 20 days ago
            new()
            {
                UserId = gymMembers[1].Id,
                PurchaseDate = now.AddDays(-20),
                IsDelivered = true,
                TotalAmount = wheyProtein.Price + creatine.Price,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = wheyProtein.Id, Quantity = 1, UnitPrice = wheyProtein.Price },
                    new() { SupplementId = creatine.Id, Quantity = 1, UnitPrice = creatine.Price }
                }
            },
            // Order 3: 15 days ago
            new()
            {
                UserId = gymMembers[2].Id,
                PurchaseDate = now.AddDays(-15),
                IsDelivered = true,
                TotalAmount = wheyProtein.Price * 3,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = wheyProtein.Id, Quantity = 3, UnitPrice = wheyProtein.Price }
                }
            },
            // Order 4: 10 days ago
            new()
            {
                UserId = gymMembers[3].Id,
                PurchaseDate = now.AddDays(-10),
                IsDelivered = true,
                TotalAmount = preWorkout.Price * 2 + nitroTech.Price,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = preWorkout.Id, Quantity = 2, UnitPrice = preWorkout.Price },
                    new() { SupplementId = nitroTech.Id, Quantity = 1, UnitPrice = nitroTech.Price }
                }
            },
            // Order 5: 5 days ago
            new()
            {
                UserId = gymMembers[0].Id,
                PurchaseDate = now.AddDays(-5),
                IsDelivered = false,
                TotalAmount = wheyProtein.Price * 2 + creatine.Price * 2,
                OrderItems = new List<OrderItem>
                {
                    new() { SupplementId = wheyProtein.Id, Quantity = 2, UnitPrice = wheyProtein.Price },
                    new() { SupplementId = creatine.Id, Quantity = 2, UnitPrice = creatine.Price }
                }
            }
        };

        // Total: Whey=8, PreWorkout=3, Creatine=3, NitroTech=1
        // Bestseller should be "Gold Standard Whey" with 8 units

        _context.Orders.AddRange(orders);
        await _context.SaveChangesAsync();
    }
}
