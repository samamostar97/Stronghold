using Mapster;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.Supplements;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

/// <summary>
/// Content-based filtering: proizvodi se preporucuju po slicnosti sa onima koje je
/// korisnik kupio ili visoko ocijenio, preko kategorije, dobavljaca i recenzija.
/// Svaki signal koji ulazi u scoring se ZAISTA koristi; svaka preporuka nosi objasnjenje.
/// Detalji: recommender-dokumentacija.md u rootu repozitorija.
/// </summary>
public class RecommendationService : IRecommendationService
{
    private const int RecommendationCount = 6;
    private const double CategoryWeight = 3.0;
    private const double SupplierWeight = 2.0;
    private const double CommunityRatingWeight = 1.0;

    private readonly StrongholdDbContext _db;
    private readonly ICurrentUserService _currentUser;

    public RecommendationService(StrongholdDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<List<RecommendedSupplementResponse>> GetForCurrentUserAsync()
    {
        var userId = _currentUser.UserId;

        // signali korisnika: kupovine (placene narudzbe) i vlastite recenzije
        var purchased = await _db.OrderItems.AsNoTracking()
            .Where(i => i.Order.UserId == userId && i.Order.Status != OrderStatus.Cancelled)
            .Select(i => new { i.SupplementId, i.Supplement.CategoryId, i.Supplement.SupplierId, i.Supplement.Name })
            .Distinct()
            .ToListAsync();

        var myRatings = await _db.Reviews.AsNoTracking()
            .Where(r => r.UserId == userId)
            .ToDictionaryAsync(r => r.SupplementId, r => r.Rating);

        // kandidati: proizvodi koje korisnik NIJE kupio, sa prosjecnom ocjenom zajednice
        var purchasedIds = purchased.Select(p => p.SupplementId).ToHashSet();
        var candidates = await _db.Supplements.AsNoTracking()
            .Where(s => !purchasedIds.Contains(s.Id) && s.StockQuantity > 0)
            .ProjectToType<SupplementResponse>()
            .ToListAsync();

        // hladan start: bez kupovina preporucujemo najbolje ocijenjene proizvode
        if (purchased.Count == 0)
        {
            return candidates
                .OrderByDescending(c => c.AverageRating)
                .ThenByDescending(c => c.ReviewCount)
                .Take(RecommendationCount)
                .Select(c => new RecommendedSupplementResponse
                {
                    Supplement = c,
                    Reason = c.ReviewCount > 0
                        ? $"Popularno među članovima (prosječna ocjena {c.AverageRating:F1})"
                        : "Novo u ponudi"
                })
                .ToList();
        }

        // profil preferenci: tezina po kategoriji i dobavljacu iz kupovina,
        // ponderisano vlastitom ocjenom (5 -> x2, 4 -> x1.5, 3 -> x1, 1-2 -> x0.25)
        var categoryAffinity = new Dictionary<int, double>();
        var supplierAffinity = new Dictionary<int, double>();
        var bestExampleForCategory = new Dictionary<int, string>();
        var bestExampleForSupplier = new Dictionary<int, string>();

        foreach (var item in purchased)
        {
            var weight = 1.0;
            if (myRatings.TryGetValue(item.SupplementId, out var rating))
            {
                weight = rating switch
                {
                    5 => 2.0,
                    4 => 1.5,
                    3 => 1.0,
                    _ => 0.25
                };
            }
            categoryAffinity[item.CategoryId] =
                categoryAffinity.GetValueOrDefault(item.CategoryId) + weight;
            supplierAffinity[item.SupplierId] =
                supplierAffinity.GetValueOrDefault(item.SupplierId) + weight;
            if (!bestExampleForCategory.ContainsKey(item.CategoryId))
            {
                bestExampleForCategory[item.CategoryId] = item.Name;
            }
            if (!bestExampleForSupplier.ContainsKey(item.SupplierId))
            {
                bestExampleForSupplier[item.SupplierId] = item.Name;
            }
        }

        // scoring kandidata: afinitet kategorije + afinitet dobavljaca + ocjena zajednice
        var scored = candidates
            .Select(candidate =>
            {
                var categoryScore = categoryAffinity.GetValueOrDefault(candidate.CategoryId);
                var supplierScore = supplierAffinity.GetValueOrDefault(candidate.SupplierId);
                var ratingScore = candidate.AverageRating / 5.0;
                var total = CategoryWeight * categoryScore +
                            SupplierWeight * supplierScore +
                            CommunityRatingWeight * ratingScore;
                return (Candidate: candidate, Total: total, CategoryScore: categoryScore,
                        SupplierScore: supplierScore);
            })
            .Where(s => s.Total > 0)
            .OrderByDescending(s => s.Total)
            .ThenByDescending(s => s.Candidate.AverageRating)
            .Take(RecommendationCount)
            .ToList();

        return scored.Select(s => new RecommendedSupplementResponse
        {
            Supplement = s.Candidate,
            Reason = BuildReason(s.Candidate, s.CategoryScore, s.SupplierScore,
                bestExampleForCategory, bestExampleForSupplier)
        }).ToList();
    }

    /// <summary>Objasnjenje prati dominantan signal u scoringu te preporuke.</summary>
    private static string BuildReason(
        SupplementResponse candidate,
        double categoryScore,
        double supplierScore,
        Dictionary<int, string> bestExampleForCategory,
        Dictionary<int, string> bestExampleForSupplier)
    {
        var parts = new List<string>();
        if (categoryScore > 0 && CategoryWeight * categoryScore >= SupplierWeight * supplierScore)
        {
            parts.Add($"Zato što ste kupili {bestExampleForCategory[candidate.CategoryId]} " +
                      $"iz kategorije {candidate.CategoryName}");
        }
        else if (supplierScore > 0)
        {
            parts.Add($"Zato što ste kupili {bestExampleForSupplier[candidate.SupplierId]} " +
                      $"od proizvođača {candidate.SupplierName}");
        }
        if (candidate.AverageRating >= 4)
        {
            parts.Add($"visoko ocijenjen ({candidate.AverageRating:F1})");
        }
        return string.Join(" - ", parts);
    }
}
