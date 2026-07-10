using Stronghold.Application.DTOs.Seminars;

namespace Stronghold.Application.Interfaces;

public interface ISeminarService : ICrudService<SeminarResponse, SeminarSearch,
    SeminarUpsertRequest, SeminarUpsertRequest>
{
    // Prijava trenutno prijavljenog clana - id iz JWT tokena.
    Task<SeminarResponse> RegisterAsync(int seminarId);

    // Odjava trenutno prijavljenog clana - moguca do pocetka seminara.
    Task<SeminarResponse> UnregisterAsync(int seminarId);

    // Otkaz seminara obavjestava sve prijavljene (in-app + e-mail).
    Task<SeminarResponse> CancelAsync(int seminarId, SeminarCancelRequest request);

    // Pregled prijavljenih ucesnika po seminaru (desktop).
    Task<List<SeminarRegistrationResponse>> GetRegistrationsAsync(int seminarId);
}
