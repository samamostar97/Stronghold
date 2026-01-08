using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;

namespace Stronghold.Infrastructure.Data
{
    public class DatabaseSeeder
    {
        private readonly StrongholdDbContext _context;
        private readonly PasswordHasher<User> _passwordHasher;

        public DatabaseSeeder(StrongholdDbContext context)
        {
            _context = context;
            _passwordHasher = new PasswordHasher<User>();
        }

        public async Task SeedAsync()
        {
            // Provjeri da li baza već ima podatke
            if (await _context.Users.AnyAsync())
            {
                return; // Baza je već popunjena
            }

            await SeedUsersAsync();
            await SeedMembershipPackagesAsync();
            await SeedProductCategoriesAsync();
            await SeedSuppliersAsync();
            await SeedProductsAsync();
            await SeedFAQsAsync();

            await _context.SaveChangesAsync();
        }

        private async Task SeedUsersAsync()
        {
            var users = new List<User>
            {
                // Administrator
                new User
                {
                    Username = "admin",
                    Email = "admin@stronghold.com",
                    Role = Role.Administrator,
                    CreatedAt = DateTime.UtcNow
                },
                // Treneri
                new User
                {
                    Username = "amer_trener",
                    Email = "amer@stronghold.com",
                    Role = Role.Trainer,
                    CreatedAt = DateTime.UtcNow
                },
                new User
                {
                    Username = "amina_trener",
                    Email = "amina@stronghold.com",
                    Role = Role.Trainer,
                    CreatedAt = DateTime.UtcNow
                },
                // Nutricionisti
                new User
                {
                    Username = "emir_nutri",
                    Email = "emir@stronghold.com",
                    Role = Role.Nutritionist,
                    CreatedAt = DateTime.UtcNow
                },
                new User
                {
                    Username = "selma_nutri",
                    Email = "selma@stronghold.com",
                    Role = Role.Nutritionist,
                    CreatedAt = DateTime.UtcNow
                },
                // Članovi teretane
                new User
                {
                    Username = "adnan_clan",
                    Email = "adnan@example.com",
                    Role = Role.GymMember,
                    CreatedAt = DateTime.UtcNow
                },
                new User
                {
                    Username = "lejla_clan",
                    Email = "lejla@example.com",
                    Role = Role.GymMember,
                    CreatedAt = DateTime.UtcNow
                },
                new User
                {
                    Username = "tarik_clan",
                    Email = "tarik@example.com",
                    Role = Role.GymMember,
                    CreatedAt = DateTime.UtcNow
                }
            };

            // Hashiraj lozinke za sve korisnike (default lozinka: "Password123!")
            foreach (var user in users)
            {
                user.PasswordHash = _passwordHasher.HashPassword(user, "Password123!");
            }

            await _context.Users.AddRangeAsync(users);
        }

        private async Task SeedMembershipPackagesAsync()
        {
            var packages = new List<MembershipPackage>
            {
                new MembershipPackage
                {
                    Name = "Osnovna Članarina",
                    Description = "Pristup teretani i osnovnoj opremi",
                    Price = 50m,
                    DurationDays = 30,
                    CreatedAt = DateTime.UtcNow
                },
                new MembershipPackage
                {
                    Name = "Premium Članarina",
                    Description = "Pun pristup teretani, grupni treninzi i jedan personalni trening mjesečno",
                    Price = 100m,
                    DurationDays = 30,
                    CreatedAt = DateTime.UtcNow
                },
                new MembershipPackage
                {
                    Name = "Studentska Članarina",
                    Description = "Popust za studente sa važećom legitimacijom",
                    Price = 40m,
                    DurationDays = 30,
                    CreatedAt = DateTime.UtcNow
                },
                new MembershipPackage
                {
                    Name = "Duo Partner Članarina",
                    Description = "Specijalni paket za parove - dvije članarine po sniženoj cijeni",
                    Price = 85m,
                    DurationDays = 30,
                    CreatedAt = DateTime.UtcNow
                },
                new MembershipPackage
                {
                    Name = "Godišnja Premium",
                    Description = "12 mjeseci premium pristupa sa 2 mjeseca gratis",
                    Price = 1000m,
                    DurationDays = 365,
                    CreatedAt = DateTime.UtcNow
                }
            };

            await _context.MembershipPackages.AddRangeAsync(packages);
        }

        private async Task SeedProductCategoriesAsync()
        {
            var categories = new List<ProductCategory>
            {
                new ProductCategory
                {
                    Name = "Proteini",
                    Description = "Whey, kazein i biljni protein u prahu",
                    CreatedAt = DateTime.UtcNow
                },
                new ProductCategory
                {
                    Name = "Kreatin",
                    Description = "Kreatin monohidrat i drugi kreatin suplementi",
                    CreatedAt = DateTime.UtcNow
                },
                new ProductCategory
                {
                    Name = "Pre-Workout",
                    Description = "Suplementi za energiju i performanse tokom treninga",
                    CreatedAt = DateTime.UtcNow
                },
                new ProductCategory
                {
                    Name = "Gainer",
                    Description = "Suplementi za povećanje mase i bulk fazu",
                    CreatedAt = DateTime.UtcNow
                },
                new ProductCategory
                {
                    Name = "Fat Burner",
                    Description = "Termogenici i suplementi za pojačavanje metabolizma",
                    CreatedAt = DateTime.UtcNow
                },
                new ProductCategory
                {
                    Name = "Vitamini i Minerali",
                    Description = "Esencijalni vitamini i mineralni suplementi",
                    CreatedAt = DateTime.UtcNow
                },
                new ProductCategory
                {
                    Name = "Amino Kiseline",
                    Description = "BCAA, EAA i drugi aminokiselinski suplementi",
                    CreatedAt = DateTime.UtcNow
                }
            };

            await _context.ProductCategories.AddRangeAsync(categories);
        }

        private async Task SeedSuppliersAsync()
        {
            var suppliers = new List<Supplier>
            {
                new Supplier
                {
                    Name = "Optimum Nutrition",
                    ContactEmail = "kontakt@optimumnutrition.ba",
                    PhoneNumber = "+387 33 555 100",
                    Address = "Zmaja od Bosne 12, Sarajevo 71000",
                    CreatedAt = DateTime.UtcNow
                },
                new Supplier
                {
                    Name = "MyProtein",
                    ContactEmail = "podrska@myprotein.ba",
                    PhoneNumber = "+387 33 555 200",
                    Address = "Alipašina 25, Sarajevo 71000",
                    CreatedAt = DateTime.UtcNow
                },
                new Supplier
                {
                    Name = "BSN Sports",
                    ContactEmail = "prodaja@bsnsports.ba",
                    PhoneNumber = "+387 33 555 300",
                    Address = "Džemala Bijedića 185, Sarajevo 71000",
                    CreatedAt = DateTime.UtcNow
                },
                new Supplier
                {
                    Name = "MuscleTech",
                    ContactEmail = "info@muscletech.ba",
                    PhoneNumber = "+387 33 555 400",
                    Address = "Titova 9, Sarajevo 71000",
                    CreatedAt = DateTime.UtcNow
                }
            };

            await _context.Suppliers.AddRangeAsync(suppliers);
        }

        private async Task SeedProductsAsync()
        {
            // Moramo sačuvati kontekst da dobijemo ID-eve za kategorije i dobavljače
            await _context.SaveChangesAsync();

            var proteinCategory = await _context.ProductCategories.FirstAsync(c => c.Name == "Proteini");
            var creatineCategory = await _context.ProductCategories.FirstAsync(c => c.Name == "Kreatin");
            var preWorkoutCategory = await _context.ProductCategories.FirstAsync(c => c.Name == "Pre-Workout");
            var weightGainerCategory = await _context.ProductCategories.FirstAsync(c => c.Name == "Gainer");
            var fatBurnerCategory = await _context.ProductCategories.FirstAsync(c => c.Name == "Fat Burner");

            var optimumSupplier = await _context.Suppliers.FirstAsync(s => s.Name == "Optimum Nutrition");
            var myProteinSupplier = await _context.Suppliers.FirstAsync(s => s.Name == "MyProtein");
            var bsnSupplier = await _context.Suppliers.FirstAsync(s => s.Name == "BSN Sports");
            var muscleTechSupplier = await _context.Suppliers.FirstAsync(s => s.Name == "MuscleTech");

            var products = new List<Product>
            {
                // Protein Proizvodi
                new Product
                {
                    Name = "Gold Standard Whey Protein",
                    Description = "24g proteina po porciji, dostupno u više okusa",
                    Price = 110m,
                    CategoryId = proteinCategory.Id,
                    SupplierId = optimumSupplier.Id,
                    StockQuantity = 50,
                    IsAvailable = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Product
                {
                    Name = "Impact Whey Isolate",
                    Description = "90% sadržaj proteina, nizak sadržaj masti i ugljenih hidrata",
                    Price = 95m,
                    CategoryId = proteinCategory.Id,
                    SupplierId = myProteinSupplier.Id,
                    StockQuantity = 30,
                    IsAvailable = true,
                    CreatedAt = DateTime.UtcNow
                },
                // Kreatin Proizvodi
                new Product
                {
                    Name = "Mikronizovani Kreatin Monohidrat",
                    Description = "Čisti kreatin monohidrat za snagu i moć",
                    Price = 40m,
                    CategoryId = creatineCategory.Id,
                    SupplierId = optimumSupplier.Id,
                    StockQuantity = 75,
                    IsAvailable = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Product
                {
                    Name = "Cell-Tech Kreatin",
                    Description = "Napredna kreatin formula sa ugljenim hidratima",
                    Price = 75m,
                    CategoryId = creatineCategory.Id,
                    SupplierId = muscleTechSupplier.Id,
                    StockQuantity = 40,
                    IsAvailable = true,
                    CreatedAt = DateTime.UtcNow
                },
                // Pre-Workout Proizvodi
                new Product
                {
                    Name = "C4 Original Pre-Workout",
                    Description = "Eksplozivna energija i fokus za intenzivne treninge",
                    Price = 55m,
                    CategoryId = preWorkoutCategory.Id,
                    SupplierId = optimumSupplier.Id,
                    StockQuantity = 60,
                    IsAvailable = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Product
                {
                    Name = "NO-Xplode Pre-Workout",
                    Description = "Napredni pre-workout sa kreatinom i beta-alaninom",
                    Price = 65m,
                    CategoryId = preWorkoutCategory.Id,
                    SupplierId = bsnSupplier.Id,
                    StockQuantity = 45,
                    IsAvailable = true,
                    CreatedAt = DateTime.UtcNow
                },
                // Weight Gainer Proizvodi
                new Product
                {
                    Name = "Serious Mass Gainer",
                    Description = "1250 kalorija po porciji za ozbiljno građenje mišića",
                    Price = 95m,
                    CategoryId = weightGainerCategory.Id,
                    SupplierId = optimumSupplier.Id,
                    StockQuantity = 25,
                    IsAvailable = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Product
                {
                    Name = "True-Mass Weight Gainer",
                    Description = "Visokoproteinski gainer sa kvalitetnim kalorijama",
                    Price = 105m,
                    CategoryId = weightGainerCategory.Id,
                    SupplierId = bsnSupplier.Id,
                    StockQuantity = 20,
                    IsAvailable = true,
                    CreatedAt = DateTime.UtcNow
                },
                // Fat Burner Proizvodi
                new Product
                {
                    Name = "Hydroxycut Hardcore",
                    Description = "Termogenički fat burner sa kofeinom",
                    Price = 75m,
                    CategoryId = fatBurnerCategory.Id,
                    SupplierId = muscleTechSupplier.Id,
                    StockQuantity = 35,
                    IsAvailable = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Product
                {
                    Name = "CLA Podrška za Mršavljenje",
                    Description = "Suplement za gubitak masti bez stimulanasa",
                    Price = 48m,
                    CategoryId = fatBurnerCategory.Id,
                    SupplierId = myProteinSupplier.Id,
                    StockQuantity = 50,
                    IsAvailable = true,
                    CreatedAt = DateTime.UtcNow
                }
            };

            await _context.Products.AddRangeAsync(products);
        }

        private async Task SeedFAQsAsync()
        {
            var faqs = new List<FAQ>
            {
                new FAQ
                {
                    Question = "Koje su vaše radno vrijeme teretane?",
                    Answer = "Otvoreni smo od ponedjeljka do petka od 6:00 do 23:00, a vikendom od 7:00 do 21:00.",
                    DisplayOrder = 1,
                    CreatedAt = DateTime.UtcNow
                },
                new FAQ
                {
                    Question = "Da li trebam da donesem vlastitu opremu?",
                    Answer = "Ne, mi obezbjeđujemo svu potrebnu opremu za vježbanje. Međutim, možete ponijeti vlastitu bocu za vodu, peškir i katanac za ormarić.",
                    DisplayOrder = 2,
                    CreatedAt = DateTime.UtcNow
                },
                new FAQ
                {
                    Question = "Mogu li otkazati ili pauzirati članarinu?",
                    Answer = "Da, možete pauzirati članarinu do 3 mjeseca godišnje. Za otkazivanje je potrebno 30 dana najave.",
                    DisplayOrder = 3,
                    CreatedAt = DateTime.UtcNow
                },
                new FAQ
                {
                    Question = "Da li su personalni treninzi uključeni u članarinu?",
                    Answer = "Osnovna članarina ne uključuje personalne treninge, ali Premium članovi dobijaju jedan trening mjesečno. Dodatni treninzi se mogu rezervisati posebno.",
                    DisplayOrder = 4,
                    CreatedAt = DateTime.UtcNow
                },
                new FAQ
                {
                    Question = "Kako mogu zakazati termin sa trenerom ili nutricionistom?",
                    Answer = "Termine možete zakazati putem mobilne aplikacije ili razgovorom sa osobljem na recepciji. Online zakazivanje je dostupno 24/7.",
                    DisplayOrder = 5,
                    CreatedAt = DateTime.UtcNow
                },
                new FAQ
                {
                    Question = "Koje načine plaćanja prihvatate?",
                    Answer = "Prihvatamo sve veće kreditne kartice, debitne kartice i digitalne metode plaćanja kroz naš siguran sistem.",
                    DisplayOrder = 6,
                    CreatedAt = DateTime.UtcNow
                },
                new FAQ
                {
                    Question = "Da li postoji naknada za učlanjenje?",
                    Answer = "Trenutno imamo promociju bez naknade za učlanjenje. Ova ponuda je dostupna za nove članove koji se upisuju na bilo koji paket članarine.",
                    DisplayOrder = 7,
                    CreatedAt = DateTime.UtcNow
                },
                new FAQ
                {
                    Question = "Mogu li probati teretanu prije nego se obavežem na članarinu?",
                    Answer = "Apsolutno! Nudimo besplatan jednodnevni probni trening. Kontaktirajte nas da zakažete vašu posjetu.",
                    DisplayOrder = 8,
                    CreatedAt = DateTime.UtcNow
                }
            };

            await _context.FAQs.AddRangeAsync(faqs);
        }
    }
}
