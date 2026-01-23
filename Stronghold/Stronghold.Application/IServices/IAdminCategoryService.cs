using Stronghold.Application.DTOs.AdminCategoryDTO;
using Stronghold.Application.Filters;
using Stronghold.Core.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IServices
{
    public interface IAdminCategoryService: IService<SupplementCategory,SupplementCategoryDTO,CreateSupplementCategoryDTO,UpdateSupplementCategoryDTO,SupplementCategoryQueryFilter,int>
    {
    }
}
