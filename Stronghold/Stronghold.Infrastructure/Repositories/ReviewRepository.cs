using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Reviews.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Repositories;

public class ReviewRepository : IReviewRepository
{
    private readonly StrongholdDbContext _context;

    public ReviewRepository(StrongholdDbContext context)
    {
        _context = context;
    }

    public async Task<PagedResult<Review>> GetPagedAsync(ReviewFilter filter, CancellationToken cancellationToken = default)
    {
        filter ??= new ReviewFilter();

        var query = _context.Reviews
            .AsNoTracking()
            .Where(x => !x.IsDeleted)
            .Include(x => x.User)
            .Include(x => x.Supplement)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim().ToLower();
            query = query.Where(x =>
                (x.User != null &&
                 ((x.User.FirstName + " " + x.User.LastName).ToLower().Contains(search) ||
                  x.User.FirstName.ToLower().Contains(search) ||
                  x.User.LastName.ToLower().Contains(search))) ||
                (x.Supplement != null && x.Supplement.Name.ToLower().Contains(search)));
        }

        if (!string.IsNullOrWhiteSpace(filter.OrderBy))
        {
            query = filter.OrderBy.Trim().ToLowerInvariant() switch
            {
                "firstname" => query.OrderBy(x => x.User.FirstName).ThenBy(x => x.Id),
                "firstnamedesc" => query.OrderByDescending(x => x.User.FirstName).ThenByDescending(x => x.Id),
                "supplement" => query.OrderBy(x => x.Supplement.Name).ThenBy(x => x.Id),
                "supplementdesc" => query.OrderByDescending(x => x.Supplement.Name).ThenByDescending(x => x.Id),
                "rating" => query.OrderBy(x => x.Rating).ThenBy(x => x.Id),
                "ratingdesc" => query.OrderByDescending(x => x.Rating).ThenByDescending(x => x.Id),
                "createdatdesc" => query.OrderByDescending(x => x.CreatedAt).ThenByDescending(x => x.Id),
                "createdat" => query.OrderBy(x => x.CreatedAt).ThenBy(x => x.Id),
                _ => query.OrderByDescending(x => x.CreatedAt).ThenByDescending(x => x.Id)
            };
        }
        else
        {
            query = query.OrderByDescending(x => x.CreatedAt).ThenByDescending(x => x.Id);
        }

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<Review>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = filter.PageNumber
        };
    }

    public Task<Review?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return _context.Reviews
            .AsNoTracking()
            .Where(x => !x.IsDeleted && x.Id == id)
            .Include(x => x.User)
            .Include(x => x.Supplement)
            .FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<PagedResult<Review>> GetPagedByUserAsync(
        int userId,
        ReviewFilter filter,
        CancellationToken cancellationToken = default)
    {
        filter ??= new ReviewFilter();

        var query = _context.Reviews
            .AsNoTracking()
            .Where(x => !x.IsDeleted && x.UserId == userId)
            .Include(x => x.Supplement)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim().ToLower();
            query = query.Where(x =>
                (x.Supplement != null && x.Supplement.Name.ToLower().Contains(search)) ||
                (x.Comment != null && x.Comment.ToLower().Contains(search)));
        }

        if (!string.IsNullOrWhiteSpace(filter.OrderBy))
        {
            query = filter.OrderBy.Trim().ToLowerInvariant() switch
            {
                "supplement" => query.OrderBy(x => x.Supplement.Name).ThenBy(x => x.Id),
                "supplementdesc" => query.OrderByDescending(x => x.Supplement.Name).ThenByDescending(x => x.Id),
                "rating" => query.OrderBy(x => x.Rating).ThenBy(x => x.Id),
                "ratingdesc" => query.OrderByDescending(x => x.Rating).ThenByDescending(x => x.Id),
                "createdat" => query.OrderBy(x => x.CreatedAt).ThenBy(x => x.Id),
                "createdatdesc" => query.OrderByDescending(x => x.CreatedAt).ThenByDescending(x => x.Id),
                _ => query.OrderByDescending(x => x.CreatedAt).ThenByDescending(x => x.Id)
            };
        }
        else
        {
            query = query.OrderByDescending(x => x.CreatedAt).ThenByDescending(x => x.Id);
        }

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<Review>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = filter.PageNumber
        };
    }

    public async Task<PagedResult<PurchasedSupplementResponse>> GetPurchasedSupplementsForReviewAsync(
        int userId,
        ReviewFilter filter,
        CancellationToken cancellationToken = default)
    {
        filter ??= new ReviewFilter();

        var query = _context.OrderItems
            .AsNoTracking()
            .Where(oi =>
                !oi.IsDeleted &&
                !oi.Order.IsDeleted &&
                oi.Order.UserId == userId &&
                oi.Order.Status == OrderStatus.Delivered &&
                !oi.Supplement.IsDeleted)
            .Where(oi => !_context.Reviews.Any(r =>
                !r.IsDeleted &&
                r.UserId == userId &&
                r.SupplementId == oi.SupplementId))
            .Select(oi => new
            {
                Id = oi.SupplementId,
                Name = oi.Supplement.Name
            })
            .Distinct()
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim().ToLower();
            query = query.Where(x => x.Name.ToLower().Contains(search));
        }

        if (!string.IsNullOrWhiteSpace(filter.OrderBy))
        {
            query = filter.OrderBy.Trim().ToLowerInvariant() switch
            {
                "name" => query.OrderBy(x => x.Name).ThenBy(x => x.Id),
                "namedesc" => query.OrderByDescending(x => x.Name).ThenByDescending(x => x.Id),
                _ => query.OrderBy(x => x.Name).ThenBy(x => x.Id)
            };
        }
        else
        {
            query = query.OrderBy(x => x.Name).ThenBy(x => x.Id);
        }

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .Select(x => new PurchasedSupplementResponse
            {
                Id = x.Id,
                Name = x.Name
            })
            .ToListAsync(cancellationToken);

        return new PagedResult<PurchasedSupplementResponse>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = filter.PageNumber
        };
    }

    public Task<bool> ExistsByUserAndSupplementAsync(
        int userId,
        int supplementId,
        CancellationToken cancellationToken = default)
    {
        return _context.Reviews.AnyAsync(
            x => !x.IsDeleted && x.UserId == userId && x.SupplementId == supplementId,
            cancellationToken);
    }

    public async Task<IReadOnlyList<Review>> GetHighlyRatedByUserAsync(
        int userId,
        int minRating,
        CancellationToken cancellationToken = default)
    {
        return await _context.Reviews
            .AsNoTracking()
            .Where(x => !x.IsDeleted &&
                        x.UserId == userId &&
                        x.Rating >= minRating &&
                        !x.Supplement.IsDeleted)
            .Include(x => x.Supplement)
                .ThenInclude(x => x.SupplementCategory)
            .Include(x => x.Supplement)
                .ThenInclude(x => x.Supplier)
            .ToListAsync(cancellationToken);
    }

    public Task<bool> HasPurchasedSupplementAsync(
        int userId,
        int supplementId,
        CancellationToken cancellationToken = default)
    {
        return _context.OrderItems.AnyAsync(
            oi => !oi.IsDeleted &&
                  oi.SupplementId == supplementId &&
                  !oi.Order.IsDeleted &&
                  oi.Order.UserId == userId &&
                  oi.Order.Status == OrderStatus.Delivered,
            cancellationToken);
    }

    public Task<bool> SupplementExistsAsync(int supplementId, CancellationToken cancellationToken = default)
    {
        return _context.Supplements.AnyAsync(
            x => x.Id == supplementId && !x.IsDeleted,
            cancellationToken);
    }

    public Task<bool> IsOwnerAsync(int reviewId, int userId, CancellationToken cancellationToken = default)
    {
        return _context.Reviews.AnyAsync(
            x => !x.IsDeleted && x.Id == reviewId && x.UserId == userId,
            cancellationToken);
    }

    public async Task AddAsync(Review entity, CancellationToken cancellationToken = default)
    {
        await _context.Reviews.AddAsync(entity, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(Review entity, CancellationToken cancellationToken = default)
    {
        entity.IsDeleted = true;
        _context.Reviews.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }
}
