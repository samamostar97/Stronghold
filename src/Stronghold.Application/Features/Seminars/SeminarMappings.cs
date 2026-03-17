using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.Seminars;

public static class SeminarMappings
{
    public static SeminarResponse ToResponse(this Seminar seminar, int registeredCount = 0)
    {
        return new SeminarResponse
        {
            Id = seminar.Id,
            Name = seminar.Name,
            Description = seminar.Description,
            Lecturer = seminar.Lecturer,
            StartDate = seminar.StartDate,
            DurationMinutes = seminar.DurationMinutes,
            MaxCapacity = seminar.MaxCapacity,
            RegisteredCount = registeredCount,
            CreatedAt = seminar.CreatedAt
        };
    }

    public static SeminarRegistrationResponse ToResponse(this SeminarRegistration registration)
    {
        return new SeminarRegistrationResponse
        {
            Id = registration.Id,
            UserId = registration.UserId,
            UserFullName = $"{registration.User.FirstName} {registration.User.LastName}",
            UserEmail = registration.User.Email,
            CreatedAt = registration.CreatedAt
        };
    }
}
