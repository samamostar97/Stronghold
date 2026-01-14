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
        await SeedAdminAsync();
        await SeedGymMembersAsync();
        await SeedMembershipPackagesAsync();

        await SeedSupplementCategoriesAsync();
        await SeedSuppliersAsync();
        await SeedSupplementsAsync();
        await SeedTrainersAsync();
        await SeedNutritionistsAsync();
        await SeedSeminarsAsync();
        await SeedFAQsAsync();
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
}
