namespace Stronghold.Application.Features.Staff;

public static class StaffMappings
{
    public static StaffResponse ToResponse(Domain.Entities.Staff staff) => new()
    {
        Id = staff.Id,
        FirstName = staff.FirstName,
        LastName = staff.LastName,
        Email = staff.Email,
        Phone = staff.Phone,
        Bio = staff.Bio,
        ProfileImageUrl = staff.ProfileImageUrl,
        StaffType = staff.StaffType.ToString(),
        IsActive = staff.IsActive
    };
}
