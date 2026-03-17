using Stronghold.Domain.Entities;

namespace Stronghold.Application.Interfaces;

public interface ISeminarRegistrationRepository : IRepository<SeminarRegistration>
{
    Task<bool> IsUserRegisteredAsync(int seminarId, int userId);
    Task<int> GetRegistrationCountAsync(int seminarId);
}
