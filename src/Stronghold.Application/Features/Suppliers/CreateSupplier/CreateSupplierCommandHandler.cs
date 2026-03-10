using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Suppliers.CreateSupplier;

public class CreateSupplierCommandHandler : IRequestHandler<CreateSupplierCommand, SupplierResponse>
{
    private readonly ISupplierRepository _supplierRepository;

    public CreateSupplierCommandHandler(ISupplierRepository supplierRepository)
    {
        _supplierRepository = supplierRepository;
    }

    public async Task<SupplierResponse> Handle(CreateSupplierCommand request, CancellationToken cancellationToken)
    {
        var existingByEmail = await _supplierRepository.GetByEmailAsync(request.Email);
        if (existingByEmail != null)
            throw new ConflictException("Dobavljač sa ovim emailom već postoji.");

        var supplier = new Supplier
        {
            Name = request.Name,
            Email = request.Email,
            Phone = request.Phone,
            Website = request.Website
        };

        await _supplierRepository.AddAsync(supplier);
        await _supplierRepository.SaveChangesAsync();

        return SupplierMappings.ToResponse(supplier);
    }
}
