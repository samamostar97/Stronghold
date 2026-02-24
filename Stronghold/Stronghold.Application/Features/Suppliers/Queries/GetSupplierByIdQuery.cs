using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Suppliers.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Suppliers.Queries;

public class GetSupplierByIdQuery : IRequest<SupplierResponse>
{
    public int Id { get; set; }
}

public class GetSupplierByIdQueryHandler : IRequestHandler<GetSupplierByIdQuery, SupplierResponse>
{
    private readonly ISupplierRepository _supplierRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetSupplierByIdQueryHandler(ISupplierRepository supplierRepository, ICurrentUserService currentUserService)
    {
        _supplierRepository = supplierRepository;
        _currentUserService = currentUserService;
    }

    public async Task<SupplierResponse> Handle(GetSupplierByIdQuery request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var supplier = await _supplierRepository.GetByIdAsync(request.Id, cancellationToken);
        if (supplier is null)
        {
            throw new KeyNotFoundException($"Dobavljac sa id '{request.Id}' ne postoji.");
        }

        return MapToResponse(supplier);
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

    private static SupplierResponse MapToResponse(Supplier supplier)
    {
        return new SupplierResponse
        {
            Id = supplier.Id,
            Name = supplier.Name,
            Website = supplier.Website,
            CreatedAt = supplier.CreatedAt
        };
    }
}

public class GetSupplierByIdQueryValidator : AbstractValidator<GetSupplierByIdQuery>
{
    public GetSupplierByIdQueryValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
    }
}
