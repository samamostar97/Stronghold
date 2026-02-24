using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Faqs.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Repositories;

public class FaqRepository : IFaqRepository
{
    private readonly StrongholdDbContext _context;

    public FaqRepository(StrongholdDbContext context)
    {
        _context = context;
    }

    public async Task<PagedResult<FAQ>> GetPagedAsync(FaqFilter filter, CancellationToken cancellationToken = default)
    {
        filter ??= new FaqFilter();

        var query = _context.FAQs
            .AsNoTracking()
            .Where(x => !x.IsDeleted)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim().ToLower();
            query = query.Where(x =>
                x.Question.ToLower().Contains(search) ||
                x.Answer.ToLower().Contains(search));
        }

        if (!string.IsNullOrWhiteSpace(filter.OrderBy))
        {
            query = filter.OrderBy.Trim().ToLowerInvariant() switch
            {
                "question" => query.OrderBy(x => x.Question).ThenBy(x => x.Id),
                "questiondesc" => query.OrderByDescending(x => x.Question).ThenByDescending(x => x.Id),
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

        return new PagedResult<FAQ>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = filter.PageNumber
        };
    }

    public Task<FAQ?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return _context.FAQs.FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted, cancellationToken);
    }

    public async Task AddAsync(FAQ entity, CancellationToken cancellationToken = default)
    {
        await _context.FAQs.AddAsync(entity, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(FAQ entity, CancellationToken cancellationToken = default)
    {
        _context.FAQs.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(FAQ entity, CancellationToken cancellationToken = default)
    {
        entity.IsDeleted = true;
        _context.FAQs.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }
}
