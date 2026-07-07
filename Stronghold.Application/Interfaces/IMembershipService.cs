using Stronghold.Application.DTOs.Memberships;

namespace Stronghold.Application.Interfaces;

public interface IMembershipService : IService<MembershipResponse, MembershipSearch>
{
    // Dodjela clanarine = evidencija uplate; produzava postojecu aktivnu ili krece odmah.
    Task<MembershipResponse> AssignAsync(MembershipAssignRequest request);

    Task<MembershipResponse> RevokeAsync(int id, MembershipRevokeRequest request);

    // Aktivna clanarina korisnika (od koje bi nova uplata krenula), ako postoji.
    Task<ActiveMembershipInfo> GetActiveForUserAsync(int userId);
}
