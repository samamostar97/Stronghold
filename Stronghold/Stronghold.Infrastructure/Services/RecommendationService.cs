using Stronghold.Application.DTOs.Response;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Services;

public class RecommendationService : IRecommendationService
{
    private readonly IOrderRepository _orderRepository;
    private readonly IReviewRepository _reviewRepository;
    private readonly ISupplementRepository _supplementRepository;

    public RecommendationService(
        IOrderRepository orderRepository,
        IReviewRepository reviewRepository,
        ISupplementRepository supplementRepository)
    {
        _orderRepository = orderRepository;
        _reviewRepository = reviewRepository;
        _supplementRepository = supplementRepository;
    }

    public async Task<List<RecommendationResponse>> GetRecommendationsAsync(int userId, int count = 6)
    {
        // 1. Get supplements from delivered orders
        var deliveredOrders = await _orderRepository.GetDeliveredForRecommendationAsync(userId);

        var purchasedSupplementIds = new HashSet<int>();
        var purchasedCategoryIds = new HashSet<int>();
        var purchasedSupplierIds = new HashSet<int>();

        foreach (var order in deliveredOrders)
        {
            foreach (var item in order.OrderItems)
            {
                if (item.IsDeleted || item.Supplement == null || item.Supplement.IsDeleted) continue;
                purchasedSupplementIds.Add(item.SupplementId);
                purchasedCategoryIds.Add(item.Supplement.SupplementCategoryId);
                purchasedSupplierIds.Add(item.Supplement.SupplierId);
            }
        }

        // 2. Get highly-rated supplements (rating >= 4)
        var highlyRatedReviews = await _reviewRepository.GetHighlyRatedByUserAsync(userId, minRating: 4);

        var highlyRatedSupplementIds = new HashSet<int>();
        var highlyRatedCategoryIds = new HashSet<int>();
        var highlyRatedSupplierIds = new HashSet<int>();

        foreach (var review in highlyRatedReviews)
        {
            if (review.Supplement == null) continue;
            highlyRatedSupplementIds.Add(review.SupplementId);
            highlyRatedCategoryIds.Add(review.Supplement.SupplementCategoryId);
            highlyRatedSupplierIds.Add(review.Supplement.SupplierId);
        }

        // 3. Get all supplements (excluding already purchased)
        var allSupplements = await _supplementRepository.GetRecommendationCandidatesAsync(
            purchasedSupplementIds.ToList());

        // 4. Score each candidate supplement
        var scoredSupplements = new List<(Supplement Supplement, int Score, string Reason)>();

        foreach (var supplement in allSupplements)
        {
            int score = 0;
            var reasons = new List<string>();

            var categoryName = supplement.SupplementCategory?.Name ?? "Nepoznato";
            var supplierName = supplement.Supplier?.Name ?? "Nepoznato";

            // +3 points if same category as a purchased item
            if (purchasedCategoryIds.Contains(supplement.SupplementCategoryId))
            {
                score += 3;
                reasons.Add($"Kupovali ste {categoryName}");
            }

            // +2 points if same supplier as a purchased item
            if (purchasedSupplierIds.Contains(supplement.SupplierId))
            {
                score += 2;
                reasons.Add($"Od dobavljaca {supplierName}");
            }

            // +2 points if same category as a highly-rated item
            if (highlyRatedCategoryIds.Contains(supplement.SupplementCategoryId))
            {
                score += 2;
                if (!reasons.Any(r => r.Contains(categoryName)))
                {
                    reasons.Add($"Visoko ocijenili {categoryName}");
                }
            }

            // +1 point if same supplier as a highly-rated item
            if (highlyRatedSupplierIds.Contains(supplement.SupplierId))
            {
                score += 1;
                if (!reasons.Any(r => r.Contains(supplierName)))
                {
                    reasons.Add($"Volite dobavljaca {supplierName}");
                }
            }

            // +1 point per star of average rating (bonus for popular items)
            var avgRating = supplement.Reviews.Any()
                ? supplement.Reviews.Average(r => r.Rating)
                : 0;
            score += (int)Math.Round(avgRating);

            // Build recommendation reason
            string reason;
            if (reasons.Any())
            {
                reason = reasons.First();
            }
            else if (avgRating >= 4)
            {
                reason = "Popularno među korisnicima";
            }
            else
            {
                reason = "Mozda vas zanima";
            }

            scoredSupplements.Add((supplement, score, reason));
        }

        // 5. Sort by score and return top N
        var topRecommendations = scoredSupplements
            .OrderByDescending(x => x.Score)
            .ThenByDescending(x => x.Supplement.Reviews.Any()
                ? x.Supplement.Reviews.Average(r => r.Rating)
                : 0)
            .Take(count)
            .Select(x => new RecommendationResponse
            {
                Id = x.Supplement.Id,
                Name = x.Supplement.Name,
                Price = x.Supplement.Price,
                Description = x.Supplement.Description,
                ImageUrl = x.Supplement.SupplementImageUrl,
                CategoryName = x.Supplement.SupplementCategory?.Name ?? string.Empty,
                SupplierName = x.Supplement.Supplier?.Name ?? string.Empty,
                AverageRating = x.Supplement.Reviews.Any()
                    ? Math.Round(x.Supplement.Reviews.Average(r => r.Rating), 1)
                    : 0,
                ReviewCount = x.Supplement.Reviews.Count,
                RecommendationReason = x.Reason
            })
            .ToList();

        return topRecommendations;
    }
}
