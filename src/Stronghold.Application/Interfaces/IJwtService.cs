using Stronghold.Domain.Entities;

namespace Stronghold.Application.Interfaces;

public interface IJwtService
{
    string GenerateAccessToken(User user);
    string GenerateRefreshToken();
}
