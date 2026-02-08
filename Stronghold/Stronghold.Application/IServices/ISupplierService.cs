using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IServices
{
    public interface ISupplierService : IService<Supplier, SupplierResponse, CreateSupplierRequest, UpdateSupplierRequest, SupplierQueryFilter, int>
    {
    }
}
