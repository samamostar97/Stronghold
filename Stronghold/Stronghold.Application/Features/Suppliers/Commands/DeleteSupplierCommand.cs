using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Suppliers.Commands;

public class DeleteSupplierCommand : IRequest<Unit>
{
    public int Id { get; set; }
}

public class DeleteSupplierCommandHandler : IRequestHandler<DeleteSupplierCommand, Unit>
{
    private readonly ISupplierRepository _supplierRepository;
    private readonly ICurrentUserService _currentUserService;

    public DeleteSupplierCommandHandler(ISupplierRepository supplierRepository, ICurrentUserService currentUserService)
    {
        _supplierRepository = supplierRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteSupplierCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var supplier = await _supplierRepository.GetByIdAsync(request.Id, cancellationToken);
        if (supplier is null)
        {
            throw new KeyNotFoundException($"Dobavljac sa id '{request.Id}' ne postoji.");
        }

        var hasSupplements = await _supplierRepository.HasSupplementsAsync(supplier.Id, cancellationToken);
        if (hasSupplements)
        {
            throw new EntityHasDependentsException("dobavljaca", "suplemente");
        }

        await _supplierRepository.DeleteAsync(supplier, cancellationToken);
        return Unit.Value;
    }

    private void EnsureAdminAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("Admin"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }
    }
}

public class DeleteSupplierCommandValidator : AbstractValidator<DeleteSupplierCommand>
{
    public DeleteSupplierCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
    }
}
