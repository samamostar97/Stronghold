namespace Stronghold.Application.Features.GymVisits.GetEligibleForCheckIn;

public class EligibleMemberResponse
{
    public int UserId { get; set; }
    public string UserFullName { get; set; } = string.Empty;
    public string MembershipPackageName { get; set; } = string.Empty;
}
