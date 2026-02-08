using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IServices
{
    public interface IMembershipPackageService : IService<MembershipPackage, MembershipPackageResponse, CreateMembershipPackageRequest, UpdateMembershipPackageRequest, MembershipPackageQueryFilter, int>
    {
    }
}
