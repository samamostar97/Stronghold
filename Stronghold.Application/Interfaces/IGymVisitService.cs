using Stronghold.Application.Common;
using Stronghold.Application.DTOs.GymVisits;
using Stronghold.Application.DTOs.Users;

namespace Stronghold.Application.Interfaces;

public interface IGymVisitService : IService<GymVisitResponse, GymVisitSearch>
{
    Task<GymVisitResponse> CheckInAsync(CheckInRequest request);
    Task<GymVisitResponse> CheckOutAsync(int visitId);

    // Clanovi sa aktivnom clanarinom koji trenutno nisu u teretani - za modal brzog check-ina.
    Task<PagedResult<UserResponse>> GetEligibleUsersAsync(UserSearch search);
}
