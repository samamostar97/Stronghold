using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Suppliers.DeleteSupplier;

public class DeleteSupplierCommandHandler : IRequestHandler<DeleteSupplierCommand, Unit>
{
    private readonly ISupplierRepository _supplierRepository;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;

    public DeleteSupplierCommandHandler(
        ISupplierRepository supplierRepository,
        IAuditService auditService,
        ICurrentUserService currentUserService)
    {
        _supplierRepository = supplierRepository;
        _auditService = auditService;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteSupplierCommand request, CancellationToken cancellationToken)
    {
        var supplier = await _supplierRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Dobavljač", request.Id);

        await _auditService.LogDeleteAsync(_currentUserService.UserId, "Supplier", supplier.Id, supplier);

        _supplierRepository.Remove(supplier);
        await _supplierRepository.SaveChangesAsync();

        return Unit.Value;
    }
}
