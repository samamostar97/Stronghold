using Mapster;
using Stronghold.Application.DTOs.Users;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure;

/// <summary>
/// Globalna Mapster konfiguracija - poziva se jednom pri startu API-ja.
/// </summary>
public static class MapsterConfig
{
    public static void Register()
    {
        TypeAdapterConfig<User, UserResponse>.NewConfig()
            .Map(dest => dest.Role, src => src.Role.ToString())
            .Map(dest => dest.CityName, src => src.City != null ? src.City.Name : null)
            .Map(dest => dest.HasImage, src => src.ImageData != null);
    }
}
