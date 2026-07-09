using Stronghold.Application.DTOs.Seminars;

namespace Stronghold.Application.Interfaces;

public interface ISeminarService : ICrudService<SeminarResponse, SeminarSearch,
    SeminarUpsertRequest, SeminarUpsertRequest>
{
    /// <summary>Prijava trenutno prijavljenog clana - id iz JWT tokena.</summary>
    Task<SeminarResponse> RegisterAsync(int seminarId);

    /// <summary>Odjava trenutno prijavljenog clana - moguca do pocetka seminara.</summary>
    Task<SeminarResponse> UnregisterAsync(int seminarId);

    /// <summary>Otkaz seminara obavjestava sve prijavljene (in-app + e-mail).</summary>
    Task<SeminarResponse> CancelAsync(int seminarId, SeminarCancelRequest request);

    /// <summary>Pregled prijavljenih ucesnika po seminaru (desktop).</summary>
    Task<List<SeminarRegistrationResponse>> GetRegistrationsAsync(int seminarId);
}
