using Stronghold.Domain.Entities;

namespace Stronghold.Application.Interfaces;

public interface IRefreshTokenRepository
{
    Task<RefreshToken?> GetByTokenAsync(string token);
    Task RevokeAllForUserAsync(int userId);
    Task AddAsync(RefreshToken refreshToken);
    Task SaveChangesAsync();
}
