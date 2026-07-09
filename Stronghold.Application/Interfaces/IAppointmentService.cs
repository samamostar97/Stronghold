using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Appointments;

namespace Stronghold.Application.Interfaces;

public interface IAppointmentService : IService<AppointmentResponse, AppointmentSearch>
{
    // Slobodne satnice = radno vrijeme osoblja minus zauzeti termini za taj datum.
    Task<List<int>> GetFreeSlotsAsync(int staffMemberId, DateOnly date);

    // Booking trenutno prijavljenog clana - id iz JWT tokena.
    Task<AppointmentResponse> CreateMineAsync(AppointmentCreateRequest request);

    // Termini trenutno prijavljenog clana.
    Task<PagedResult<AppointmentResponse>> GetMineAsync(BaseSearchObject search);

    // Admin direktno dodaje termin za odabranog clana.
    Task<AppointmentResponse> CreateAsync(AdminAppointmentCreateRequest request);

    Task<AppointmentResponse> ConfirmAsync(int id);
    Task<AppointmentResponse> CompleteAsync(int id);

    // Nedolazak clana - moguce evidentirati tek kad termin prodje.
    Task<AppointmentResponse> MarkNoShowAsync(int id);
    Task<AppointmentResponse> CancelAsync(int id, AppointmentCancelRequest request);
}
