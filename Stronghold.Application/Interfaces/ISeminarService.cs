using Stronghold.Application.DTOs.Seminars;

namespace Stronghold.Application.Interfaces;

public interface ISeminarService : ICrudService<SeminarResponse, SeminarSearch,
    SeminarUpsertRequest, SeminarUpsertRequest>
{
    /// <summary>Prijava trenutno prijavljenog clana - id iz JWT tokena.</summary>
    Task<SeminarResponse> RegisterAsync(int seminarId);

    /// <summary>Pregled prijavljenih ucesnika po seminaru (desktop).</summary>
    Task<List<SeminarRegistrationResponse>> GetRegistrationsAsync(int seminarId);
}
