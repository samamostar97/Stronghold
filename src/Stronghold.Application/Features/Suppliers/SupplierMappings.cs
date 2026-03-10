using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.Suppliers;

public static class SupplierMappings
{
    public static SupplierResponse ToResponse(Supplier supplier) => new()
    {
        Id = supplier.Id,
        Name = supplier.Name,
        Email = supplier.Email,
        Phone = supplier.Phone,
        Website = supplier.Website,
        CreatedAt = supplier.CreatedAt
    };
}
