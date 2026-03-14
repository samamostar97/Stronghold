using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Suppliers.DeleteSupplier;

public class DeleteSupplierCommandHandler : IRequestHandler<DeleteSupplierCommand, Unit>
{
    private readonly ISupplierRepository _supplierRepository;
    private readonly IProductRepository _productRepository;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;

    public DeleteSupplierCommandHandler(
        ISupplierRepository supplierRepository,
        IProductRepository productRepository,
        IAuditService auditService,
        ICurrentUserService currentUserService)
    {
        _supplierRepository = supplierRepository;
        _productRepository = productRepository;
        _auditService = auditService;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteSupplierCommand request, CancellationToken cancellationToken)
    {
        var supplier = await _supplierRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Dobavljač", request.Id);

        var hasProducts = await _productRepository.Query()
            .AnyAsync(p => p.SupplierId == request.Id, cancellationToken);
        if (hasProducts)
            throw new ConflictException("Nije moguće obrisati dobavljača koji ima proizvode.");

        await _auditService.LogDeleteAsync(_currentUserService.UserId, "Supplier", supplier.Id, supplier);

        _supplierRepository.Remove(supplier);
        await _supplierRepository.SaveChangesAsync();

        return Unit.Value;
    }
}
