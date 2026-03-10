using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;

namespace Stronghold.Application.Features.Suppliers.GetSuppliers;

public class GetSuppliersQueryHandler : IRequestHandler<GetSuppliersQuery, PagedResult<SupplierResponse>>
{
    private readonly ISupplierRepository _supplierRepository;

    public GetSuppliersQueryHandler(ISupplierRepository supplierRepository)
    {
        _supplierRepository = supplierRepository;
    }

    public async Task<PagedResult<SupplierResponse>> Handle(GetSuppliersQuery request, CancellationToken cancellationToken)
    {
        IQueryable<Domain.Entities.Supplier> query = _supplierRepository.Query();

        if (!string.IsNullOrWhiteSpace(request.Search))
        {
            var search = request.Search.ToLower();
            query = query.Where(s =>
                s.Name.ToLower().Contains(search) ||
                s.Email.ToLower().Contains(search));
        }

        query = request.OrderBy?.ToLower() switch
        {
            "name" => request.OrderDescending ? query.OrderByDescending(s => s.Name) : query.OrderBy(s => s.Name),
            "email" => request.OrderDescending ? query.OrderByDescending(s => s.Email) : query.OrderBy(s => s.Email),
            _ => request.OrderDescending ? query.OrderByDescending(s => s.CreatedAt) : query.OrderBy(s => s.CreatedAt)
        };

        var totalCount = await query.CountAsync(cancellationToken);

        var suppliers = await query
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<SupplierResponse>
        {
            Items = suppliers.Select(SupplierMappings.ToResponse).ToList(),
            TotalCount = totalCount,
            TotalPages = (int)Math.Ceiling(totalCount / (double)request.PageSize),
            CurrentPage = request.PageNumber,
            PageSize = request.PageSize
        };
    }
}
