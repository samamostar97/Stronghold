using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Suppliers.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Suppliers.Queries;

public class GetSuppliersQuery : IRequest<IReadOnlyList<SupplierResponse>>, IAuthorizeAdminRequest
{
    public SupplierFilter Filter { get; set; } = new();
}

public class GetSuppliersQueryHandler : IRequestHandler<GetSuppliersQuery, IReadOnlyList<SupplierResponse>>
{
    private readonly ISupplierRepository _supplierRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetSuppliersQueryHandler(ISupplierRepository supplierRepository, ICurrentUserService currentUserService)
    {
        _supplierRepository = supplierRepository;
        _currentUserService = currentUserService;
    }

public async Task<IReadOnlyList<SupplierResponse>> Handle(GetSuppliersQuery request, CancellationToken cancellationToken)
    {
        var filter = request.Filter ?? new SupplierFilter();
        filter.PageNumber = 1;
        filter.PageSize = int.MaxValue;
        var page = await _supplierRepository.GetPagedAsync(filter, cancellationToken);
        return page.Items.Select(MapToResponse).ToList();
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

public class GetSuppliersQueryValidator : AbstractValidator<GetSuppliersQuery>
{
    public GetSuppliersQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.Filter.Search)
            .MaximumLength(200).WithMessage("{PropertyName} ne smije imati vise od 200 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.Search));

        RuleFor(x => x.Filter.OrderBy)
            .MaximumLength(30).WithMessage("{PropertyName} ne smije imati vise od 30 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.OrderBy));

        RuleFor(x => x.Filter.OrderBy)
            .Must(BeValidOrderBy)
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.OrderBy))
            .WithMessage("Neispravna vrijednost za sortiranje.");
    }

private static bool BeValidOrderBy(string? orderBy)
    {
        var value = orderBy?.Trim().ToLowerInvariant();
        return value is "name" or "namedesc" or "createdat" or "createdatdesc";
    }
    }