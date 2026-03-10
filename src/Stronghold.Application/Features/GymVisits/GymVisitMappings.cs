using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.GymVisits;

public static class GymVisitMappings
{
    public static GymVisitResponse ToResponse(GymVisit visit) => new()
    {
        Id = visit.Id,
        UserId = visit.UserId,
        UserFullName = visit.User != null
            ? $"{visit.User.FirstName} {visit.User.LastName}"
            : string.Empty,
        Username = visit.User?.Username ?? string.Empty,
        CheckInAt = visit.CheckInAt,
        CheckOutAt = visit.CheckOutAt,
        DurationMinutes = visit.DurationMinutes
    };
}
