using Stronghold.Application.DTOs.Memberships;

namespace Stronghold.Application.Interfaces;

public interface IMembershipService : IService<MembershipResponse, MembershipSearch>
{
    /// <summary>Dodjela clanarine = evidencija uplate; produzava postojecu aktivnu ili krece odmah.</summary>
    Task<MembershipResponse> AssignAsync(MembershipAssignRequest request);

    Task<MembershipResponse> RevokeAsync(int id, MembershipRevokeRequest request);

    /// <summary>Aktivna clanarina korisnika (od koje bi nova uplata krenula), ako postoji.</summary>
    Task<ActiveMembershipInfo> GetActiveForUserAsync(int userId);
}
