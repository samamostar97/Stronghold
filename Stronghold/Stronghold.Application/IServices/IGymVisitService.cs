using Stronghold.Application.Common;
using Stronghold.Application.DTOs;
using Stronghold.Core.Entities;

namespace Stronghold.Application.GymVisits;

public interface IGymVisitService
{
    Task CheckInAsync(int userId);
    Task<List<CurrentGymUserDto>> GetCurrentlyInGymAsync();

}
