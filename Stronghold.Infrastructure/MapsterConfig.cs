using Mapster;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.GymVisits;
using Stronghold.Application.DTOs.Memberships;
using Stronghold.Application.DTOs.Payments;
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

        TypeAdapterConfig<Membership, MembershipResponse>.NewConfig()
            .Map(dest => dest.UserFullName, src => src.User.FirstName + " " + src.User.LastName)
            .Map(dest => dest.Username, src => src.User.Username)
            .Map(dest => dest.PackageName, src => src.Package.Name)
            .Map(dest => dest.IsActive,
                src => !src.IsRevoked && src.StartDate <= DateTime.UtcNow && src.EndDate > DateTime.UtcNow);

        TypeAdapterConfig<GymVisit, GymVisitResponse>.NewConfig()
            .Map(dest => dest.UserFullName, src => src.User.FirstName + " " + src.User.LastName)
            .Map(dest => dest.Username, src => src.User.Username)
            .Map(dest => dest.DurationMinutes,
                src => EF.Functions.DateDiffMinute(src.CheckInAt, src.CheckOutAt ?? DateTime.UtcNow));

        TypeAdapterConfig<Payment, PaymentResponse>.NewConfig()
            .Map(dest => dest.UserId, src => src.Membership.UserId)
            .Map(dest => dest.UserFullName,
                src => src.Membership.User.FirstName + " " + src.Membership.User.LastName)
            .Map(dest => dest.PackageName, src => src.Membership.Package.Name);
    }
}
