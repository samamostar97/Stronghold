using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Appointments;

namespace Stronghold.Application.Interfaces;

public interface IAppointmentService : IService<AppointmentResponse, AppointmentSearch>
{
    /// <summary>Slobodne satnice = radno vrijeme osoblja minus zauzeti termini za taj datum.</summary>
    Task<List<int>> GetFreeSlotsAsync(int staffMemberId, DateOnly date);

    /// <summary>Booking trenutno prijavljenog clana - id iz JWT tokena.</summary>
    Task<AppointmentResponse> CreateMineAsync(AppointmentCreateRequest request);

    /// <summary>Termini trenutno prijavljenog clana.</summary>
    Task<PagedResult<AppointmentResponse>> GetMineAsync(BaseSearchObject search);

    /// <summary>Admin direktno dodaje termin za odabranog clana.</summary>
    Task<AppointmentResponse> CreateAsync(AdminAppointmentCreateRequest request);

    Task<AppointmentResponse> ConfirmAsync(int id);
    Task<AppointmentResponse> CompleteAsync(int id);
    Task<AppointmentResponse> CancelAsync(int id, AppointmentCancelRequest request);
}
