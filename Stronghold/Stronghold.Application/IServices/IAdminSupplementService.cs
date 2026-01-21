using Stronghold.Application.DTOs.AdminSupplementsDTO;
using Stronghold.Application.Filters;
using Stronghold.Core.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IServices
{
    public interface IAdminSupplementService:IService<Supplement,SupplementDTO,CreateSupplementDTO,UpdateSupplementDTO,SupplementQueryFilter,int>
    {
    }
}
