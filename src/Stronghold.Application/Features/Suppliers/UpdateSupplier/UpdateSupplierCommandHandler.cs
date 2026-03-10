using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Suppliers.UpdateSupplier;

public class UpdateSupplierCommandHandler : IRequestHandler<UpdateSupplierCommand, SupplierResponse>
{
    private readonly ISupplierRepository _supplierRepository;

    public UpdateSupplierCommandHandler(ISupplierRepository supplierRepository)
    {
        _supplierRepository = supplierRepository;
    }

    public async Task<SupplierResponse> Handle(UpdateSupplierCommand request, CancellationToken cancellationToken)
    {
        var supplier = await _supplierRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Dobavljač", request.Id);

        var existingByEmail = await _supplierRepository.GetByEmailAsync(request.Email);
        if (existingByEmail != null && existingByEmail.Id != request.Id)
            throw new ConflictException("Dobavljač sa ovim emailom već postoji.");

        supplier.Name = request.Name;
        supplier.Email = request.Email;
        supplier.Phone = request.Phone;
        supplier.Website = request.Website;

        _supplierRepository.Update(supplier);
        await _supplierRepository.SaveChangesAsync();

        return SupplierMappings.ToResponse(supplier);
    }
}
