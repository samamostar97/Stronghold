using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.Users;

public static class UserMappings
{
    public static UserResponse ToResponse(User user) => new()
    {
        Id = user.Id,
        FirstName = user.FirstName,
        LastName = user.LastName,
        Username = user.Username,
        Email = user.Email,
        Phone = user.Phone,
        Address = user.Address,
        ProfileImageUrl = user.ProfileImageUrl,
        Role = user.Role.ToString(),
        Level = user.Level,
        XP = user.XP,
        TotalGymMinutes = user.TotalGymMinutes
    };
}
