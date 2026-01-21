using Stronghold.Application.DTOs.AdminPackageDTO;
using Stronghold.Application.Filters;
using Stronghold.Core.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IServices
{
    public interface IAdminPackageService : IService<MembershipPackage,MembershipPackageDTO,CreateMembershipPackageDTO,UpdateMembershipPackageDTO,MembershipPackageQueryFilter,int>
    {

    }
}
