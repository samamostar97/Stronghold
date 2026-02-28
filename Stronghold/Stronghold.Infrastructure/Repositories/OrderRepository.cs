using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Orders.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Repositories;

public class OrderRepository : IOrderRepository
{
    private readonly StrongholdDbContext _context;

    public OrderRepository(StrongholdDbContext context)
    {
        _context = context;
    }

    public async Task<IReadOnlyList<Order>> GetAllAsync(OrderFilter? filter, CancellationToken cancellationToken = default)
    {
        var query = BuildDetailedQuery().AsNoTracking();
        query = ApplyFilter(query, filter);
        return await query.ToListAsync(cancellationToken);
    }

    public async Task<PagedResult<Order>> GetPagedAsync(OrderFilter filter, CancellationToken cancellationToken = default)
    {
        filter ??= new OrderFilter();

        var query = BuildDetailedQuery().AsNoTracking();
        query = ApplyFilter(query, filter);

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<Order>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = filter.PageNumber
        };
    }

    public Task<Order?> GetByIdWithDetailsAsync(int orderId, CancellationToken cancellationToken = default)
    {
        return BuildDetailedQuery()
            .FirstOrDefaultAsync(x => x.Id == orderId, cancellationToken);
    }

    public async Task<PagedResult<Order>> GetUserOrdersPagedAsync(
        int userId,
        OrderFilter filter,
        CancellationToken cancellationToken = default)
    {
        filter ??= new OrderFilter();

        var query = _context.Orders
            .AsNoTracking()
            .Where(x => !x.IsDeleted && x.UserId == userId)
            .Include(x => x.OrderItems)
                .ThenInclude(x => x.Supplement)
            .AsQueryable();

        query = ApplyUserFilter(query, filter);

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<Order>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = filter.PageNumber
        };
    }

    public async Task<IReadOnlyList<Supplement>> GetSupplementsByIdsAsync(
        IReadOnlyCollection<int> supplementIds,
        CancellationToken cancellationToken = default)
    {
        if (supplementIds.Count == 0)
        {
            return Array.Empty<Supplement>();
        }

        return await _context.Supplements
            .AsNoTracking()
            .Where(x => !x.IsDeleted && supplementIds.Contains(x.Id))
            .ToListAsync(cancellationToken);
    }

    public Task<Order?> GetByStripePaymentIdAsync(string paymentIntentId, CancellationToken cancellationToken = default)
    {
        return _context.Orders
            .AsNoTracking()
            .FirstOrDefaultAsync(x => !x.IsDeleted && x.StripePaymentId == paymentIntentId, cancellationToken);
    }

    public async Task<IReadOnlyList<Order>> GetDeliveredForRecommendationAsync(
        int userId,
        CancellationToken cancellationToken = default)
    {
        return await _context.Orders
            .AsNoTracking()
            .Where(x => !x.IsDeleted && x.UserId == userId && x.Status == Stronghold.Core.Enums.OrderStatus.Delivered)
            .Include(x => x.OrderItems)
                .ThenInclude(x => x.Supplement)
                    .ThenInclude(x => x.SupplementCategory)
            .Include(x => x.OrderItems)
                .ThenInclude(x => x.Supplement)
                    .ThenInclude(x => x.Supplier)
            .ToListAsync(cancellationToken);
    }

    public async Task<bool> TryAddAsync(Order order, CancellationToken cancellationToken = default)
    {
        try
        {
            await _context.Orders.AddAsync(order, cancellationToken);
            await _context.SaveChangesAsync(cancellationToken);
            return true;
        }
        catch (DbUpdateException)
        {
            if (!string.IsNullOrWhiteSpace(order.StripePaymentId))
            {
                var exists = await _context.Orders
                    .AnyAsync(x => x.StripePaymentId == order.StripePaymentId, cancellationToken);
                if (exists)
                {
                    return false;
                }
            }

            throw;
        }
    }

    public async Task UpdateAsync(Order order, CancellationToken cancellationToken = default)
    {
        _context.Orders.Update(order);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public Task<User?> GetUserByIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        return _context.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(x => !x.IsDeleted && x.Id == userId, cancellationToken);
    }

    private IQueryable<Order> BuildDetailedQuery()
    {
        return _context.Orders
            .Where(x => !x.IsDeleted)
            .Include(x => x.User)
            .Include(x => x.OrderItems)
                .ThenInclude(x => x.Supplement)
            .AsQueryable();
    }

    private static IQueryable<Order> ApplyFilter(IQueryable<Order> query, OrderFilter? filter)
    {
        if (filter is null)
        {
            return query
                .OrderBy(x => x.Status)
                .ThenByDescending(x => x.PurchaseDate)
                .ThenByDescending(x => x.Id);
        }

        if (filter.UserId.HasValue)
        {
            query = query.Where(x => x.UserId == filter.UserId.Value);
        }

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim().ToLower();
            query = query.Where(x =>
                x.User.FirstName.ToLower().Contains(search) ||
                x.User.LastName.ToLower().Contains(search) ||
                x.User.Email.ToLower().Contains(search) ||
                x.Id.ToString().Contains(search));
        }

        if (filter.Status.HasValue)
        {
            query = query.Where(x => x.Status == filter.Status.Value);
        }

        if (!string.IsNullOrWhiteSpace(filter.OrderBy))
        {
            query = filter.OrderBy.Trim().ToLowerInvariant() switch
            {
                "date" => filter.Descending
                    ? query.OrderByDescending(x => x.PurchaseDate).ThenByDescending(x => x.Id)
                    : query.OrderBy(x => x.PurchaseDate).ThenBy(x => x.Id),
                "amount" => filter.Descending
                    ? query.OrderByDescending(x => x.TotalAmount).ThenByDescending(x => x.Id)
                    : query.OrderBy(x => x.TotalAmount).ThenBy(x => x.Id),
                "status" => filter.Descending
                    ? query.OrderByDescending(x => x.Status).ThenByDescending(x => x.Id)
                    : query.OrderBy(x => x.Status).ThenBy(x => x.Id),
                "user" => filter.Descending
                    ? query.OrderByDescending(x => x.User.LastName).ThenByDescending(x => x.Id)
                    : query.OrderBy(x => x.User.LastName).ThenBy(x => x.Id),
                _ => filter.Descending
                    ? query.OrderByDescending(x => x.PurchaseDate).ThenByDescending(x => x.Id)
                    : query.OrderBy(x => x.PurchaseDate).ThenBy(x => x.Id)
            };
        }
        else
        {
            query = query
                .OrderBy(x => x.Status)
                .ThenByDescending(x => x.PurchaseDate)
                .ThenByDescending(x => x.Id);
        }

        return query;
    }

    private static IQueryable<Order> ApplyUserFilter(IQueryable<Order> query, OrderFilter? filter)
    {
        if (filter is null)
        {
            return query
                .OrderByDescending(x => x.PurchaseDate)
                .ThenByDescending(x => x.Id);
        }

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim().ToLower();
            query = query.Where(x =>
                x.Id.ToString().Contains(search) ||
                x.OrderItems.Any(i => i.Supplement.Name.ToLower().Contains(search)));
        }

        if (filter.Status.HasValue)
        {
            query = query.Where(x => x.Status == filter.Status.Value);
        }

        if (!string.IsNullOrWhiteSpace(filter.OrderBy))
        {
            query = filter.OrderBy.Trim().ToLowerInvariant() switch
            {
                "date" => filter.Descending
                    ? query.OrderByDescending(x => x.PurchaseDate).ThenByDescending(x => x.Id)
                    : query.OrderBy(x => x.PurchaseDate).ThenBy(x => x.Id),
                "amount" => filter.Descending
                    ? query.OrderByDescending(x => x.TotalAmount).ThenByDescending(x => x.Id)
                    : query.OrderBy(x => x.TotalAmount).ThenBy(x => x.Id),
                "status" => filter.Descending
                    ? query.OrderByDescending(x => x.Status).ThenByDescending(x => x.Id)
                    : query.OrderBy(x => x.Status).ThenBy(x => x.Id),
                _ => filter.Descending
                    ? query.OrderByDescending(x => x.PurchaseDate).ThenByDescending(x => x.Id)
                    : query.OrderBy(x => x.PurchaseDate).ThenBy(x => x.Id)
            };
        }
        else
        {
            query = query
                .OrderByDescending(x => x.PurchaseDate)
                .ThenByDescending(x => x.Id);
        }

        return query;
    }
}
