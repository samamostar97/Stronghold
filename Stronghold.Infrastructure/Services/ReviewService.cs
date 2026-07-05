using Mapster;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.Reviews;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class ReviewService : BaseService<Review, ReviewResponse, ReviewSearch>, IReviewService
{
    private readonly ICurrentUserService _currentUser;

    public ReviewService(StrongholdDbContext db, ICurrentUserService currentUser) : base(db)
    {
        _currentUser = currentUser;
    }

    protected override IQueryable<Review> ApplyFilter(IQueryable<Review> query, ReviewSearch search)
    {
        if (!string.IsNullOrWhiteSpace(search.Text))
        {
            var text = search.Text.Trim();
            query = query.Where(r =>
                r.User.FirstName.Contains(text) ||
                r.User.LastName.Contains(text) ||
                r.User.Username.Contains(text) ||
                r.Supplement.Name.Contains(text));
        }
        if (search.SupplementId.HasValue)
        {
            query = query.Where(r => r.SupplementId == search.SupplementId);
        }
        if (search.Rating.HasValue)
        {
            query = query.Where(r => r.Rating == search.Rating);
        }
        return query.OrderByDescending(r => r.CreatedAt);
    }

    public async Task<ReviewResponse> CreateMineAsync(ReviewCreateRequest request)
    {
        var userId = _currentUser.UserId;

        if (!await Db.Supplements.AnyAsync(s => s.Id == request.SupplementId))
        {
            throw new NotFoundException("Suplement ne postoji.");
        }

        // recenzija tek kad je narudzba DOSTAVLJENA - provjera na backendu
        var hasDeliveredPurchase = await Db.OrderItems.AnyAsync(i =>
            i.SupplementId == request.SupplementId &&
            i.Order.UserId == userId &&
            i.Order.Status == OrderStatus.Delivered);
        if (!hasDeliveredPurchase)
        {
            throw new BusinessException(
                "Recenziju možete ostaviti samo za suplement koji ste kupili i koji vam je dostavljen.");
        }

        // jedna recenzija po kupljenom proizvodu
        if (await Db.Reviews.AnyAsync(r => r.UserId == userId && r.SupplementId == request.SupplementId))
        {
            throw new BusinessException("Već ste ostavili recenziju za ovaj suplement.");
        }

        var review = new Review
        {
            UserId = userId,
            SupplementId = request.SupplementId,
            Rating = request.Rating,
            Comment = string.IsNullOrWhiteSpace(request.Comment) ? null : request.Comment.Trim(),
            CreatedAt = DateTime.UtcNow
        };
        Db.Reviews.Add(review);
        await Db.SaveChangesAsync();
        return await GetByIdAsync(review.Id);
    }

    public async Task<List<ReviewResponse>> GetMineAsync()
    {
        var userId = _currentUser.UserId;
        return await Db.Reviews.AsNoTracking()
            .Where(r => r.UserId == userId)
            .OrderByDescending(r => r.CreatedAt)
            .ProjectToType<ReviewResponse>()
            .ToListAsync();
    }
}
