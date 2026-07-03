using Stronghold.Application.DTOs.StaffMembers;

namespace Stronghold.Application.Interfaces;

public interface IStaffMemberService : ICrudService<StaffMemberResponse, StaffMemberSearch,
    StaffMemberUpsertRequest, StaffMemberUpsertRequest>
{
    Task<(byte[] Data, string ContentType)> GetImageAsync(int id);
}
