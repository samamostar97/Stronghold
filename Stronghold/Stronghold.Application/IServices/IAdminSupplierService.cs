using Stronghold.Application.DTOs.AdminSuppliersDTO;
using Stronghold.Application.Filters;
using Stronghold.Core.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IServices
{
    public interface IAdminSupplierService:IBaseService<Supplier,SupplierDTO,CreateSupplierDTO,UpdateSupplierDTO,SupplierQueryFilter,int>
    {
    }
}
