using Stronghold.Application.DTOs.Seminars;

namespace Stronghold.Application.Interfaces;

public interface ISeminarService : ICrudService<SeminarResponse, SeminarSearch,
    SeminarUpsertRequest, SeminarUpsertRequest>
{
    // Prijava trenutno prijavljenog clana - id iz JWT tokena.
    Task<SeminarResponse> RegisterAsync(int seminarId);

    // Pregled prijavljenih ucesnika po seminaru (desktop).
    Task<List<SeminarRegistrationResponse>> GetRegistrationsAsync(int seminarId);
}
