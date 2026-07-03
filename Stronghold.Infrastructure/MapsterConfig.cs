using Mapster;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.Appointments;
using Stronghold.Application.DTOs.GymVisits;
using Stronghold.Application.DTOs.Memberships;
using Stronghold.Application.DTOs.Orders;
using Stronghold.Application.DTOs.Payments;
using Stronghold.Application.DTOs.Seminars;
using Stronghold.Application.DTOs.StaffMembers;
using Stronghold.Application.DTOs.Supplements;
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

        TypeAdapterConfig<Order, OrderResponse>.NewConfig()
            .Map(dest => dest.UserFullName, src => src.User.FirstName + " " + src.User.LastName)
            .Map(dest => dest.DeliveryCityName, src => src.DeliveryCity.Name)
            .Map(dest => dest.Status, src => src.Status.ToString());

        TypeAdapterConfig<OrderItem, OrderItemResponse>.NewConfig()
            .Map(dest => dest.SupplementName, src => src.Supplement.Name);

        TypeAdapterConfig<Appointment, AppointmentResponse>.NewConfig()
            .Map(dest => dest.UserFullName, src => src.User.FirstName + " " + src.User.LastName)
            .Map(dest => dest.StaffFullName, src => src.StaffMember.FirstName + " " + src.StaffMember.LastName)
            .Map(dest => dest.StaffType, src => src.StaffMember.StaffType.ToString())
            .Map(dest => dest.Status, src => src.Status.ToString())
            .Map(dest => dest.CancelledBy,
                src => src.CancelledBy != null ? src.CancelledBy.ToString() : null);

        TypeAdapterConfig<StaffMember, StaffMemberResponse>.NewConfig()
            .Map(dest => dest.StaffType, src => src.StaffType.ToString())
            .Map(dest => dest.HasImage, src => src.ImageData != null);

        TypeAdapterConfig<Seminar, SeminarResponse>.NewConfig()
            .Map(dest => dest.RegisteredCount, src => src.Registrations.Count)
            .Map(dest => dest.RemainingCapacity, src => src.MaxCapacity - src.Registrations.Count);

        TypeAdapterConfig<SeminarRegistration, SeminarRegistrationResponse>.NewConfig()
            .Map(dest => dest.UserFullName, src => src.User.FirstName + " " + src.User.LastName)
            .Map(dest => dest.Username, src => src.User.Username);

        TypeAdapterConfig<Supplement, SupplementResponse>.NewConfig()
            .Map(dest => dest.CategoryName, src => src.Category.Name)
            .Map(dest => dest.SupplierName, src => src.Supplier.Name)
            .Map(dest => dest.HasImage, src => src.ImageData != null)
            .Map(dest => dest.AverageRating, src => src.Reviews.Average(r => (double?)r.Rating) ?? 0)
            .Map(dest => dest.ReviewCount, src => src.Reviews.Count);

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
