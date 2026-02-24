using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Users.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Repositories;

public class UserRepository : IUserRepository
{
    private readonly StrongholdDbContext _context;

    public UserRepository(StrongholdDbContext context)
    {
        _context = context;
    }

    public async Task<PagedResult<User>> GetPagedAsync(UserFilter filter, CancellationToken cancellationToken = default)
    {
        filter ??= new UserFilter();

        var query = _context.Users
            .AsNoTracking()
            .Where(x => !x.IsDeleted && x.Role != Role.Admin)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Name))
        {
            var name = filter.Name.Trim().ToLower();
            query = query.Where(x =>
                x.FirstName.ToLower().Contains(name) ||
                x.LastName.ToLower().Contains(name) ||
                x.Username.ToLower().Contains(name));
        }

        if (!string.IsNullOrWhiteSpace(filter.OrderBy))
        {
            query = filter.OrderBy.Trim().ToLowerInvariant() switch
            {
                "firstname" => query.OrderBy(x => x.FirstName).ThenBy(x => x.Id),
                "lastname" => query.OrderBy(x => x.LastName).ThenBy(x => x.Id),
                "datedesc" => query.OrderByDescending(x => x.CreatedAt).ThenByDescending(x => x.Id),
                "date" => query.OrderBy(x => x.CreatedAt).ThenBy(x => x.Id),
                _ => query.OrderBy(x => x.CreatedAt).ThenBy(x => x.Id)
            };
        }
        else
        {
            query = query.OrderBy(x => x.CreatedAt).ThenBy(x => x.Id);
        }

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<User>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = filter.PageNumber
        };
    }

    public Task<User?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return _context.Users.FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted, cancellationToken);
    }

    public Task<bool> ExistsByUsernameAsync(string username, int? excludeId = null, CancellationToken cancellationToken = default)
    {
        var normalized = username.Trim().ToLower();
        return _context.Users.AnyAsync(
            x => !x.IsDeleted &&
                 x.Username.ToLower() == normalized &&
                 (!excludeId.HasValue || x.Id != excludeId.Value),
            cancellationToken);
    }

    public Task<bool> ExistsByEmailAsync(string email, int? excludeId = null, CancellationToken cancellationToken = default)
    {
        var normalized = email.Trim().ToLower();
        return _context.Users.AnyAsync(
            x => !x.IsDeleted &&
                 x.Email.ToLower() == normalized &&
                 (!excludeId.HasValue || x.Id != excludeId.Value),
            cancellationToken);
    }

    public Task<bool> ExistsByPhoneAsync(string phoneNumber, int? excludeId = null, CancellationToken cancellationToken = default)
    {
        var normalized = phoneNumber.Trim();
        return _context.Users.AnyAsync(
            x => !x.IsDeleted &&
                 x.PhoneNumber == normalized &&
                 (!excludeId.HasValue || x.Id != excludeId.Value),
            cancellationToken);
    }

    public async Task AddAsync(User entity, CancellationToken cancellationToken = default)
    {
        await _context.Users.AddAsync(entity, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(User entity, CancellationToken cancellationToken = default)
    {
        _context.Users.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(User entity, CancellationToken cancellationToken = default)
    {
        entity.IsDeleted = true;
        _context.Users.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }
}
