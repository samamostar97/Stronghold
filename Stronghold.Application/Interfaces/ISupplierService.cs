using Stronghold.Application.DTOs.Suppliers;

namespace Stronghold.Application.Interfaces;

public interface ISupplierService : ICrudService<SupplierResponse, SupplierSearch,
    SupplierUpsertRequest, SupplierUpsertRequest>
{
}
