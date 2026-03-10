using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;

namespace Stronghold.Application.Features.MembershipPackages.GetMembershipPackages;

public class GetMembershipPackagesQueryHandler : IRequestHandler<GetMembershipPackagesQuery, PagedResult<MembershipPackageResponse>>
{
    private readonly IMembershipPackageRepository _repository;

    public GetMembershipPackagesQueryHandler(IMembershipPackageRepository repository)
    {
        _repository = repository;
    }

    public async Task<PagedResult<MembershipPackageResponse>> Handle(GetMembershipPackagesQuery request, CancellationToken cancellationToken)
    {
        var query = _repository.Query();

        if (!string.IsNullOrWhiteSpace(request.Search))
        {
            var search = request.Search.ToLower();
            query = query.Where(p =>
                p.Name.ToLower().Contains(search) ||
                (p.Description != null && p.Description.ToLower().Contains(search)));
        }

        query = request.OrderBy?.ToLower() switch
        {
            "name" => request.OrderDescending ? query.OrderByDescending(p => p.Name) : query.OrderBy(p => p.Name),
            "price" => request.OrderDescending ? query.OrderByDescending(p => p.Price) : query.OrderBy(p => p.Price),
            _ => request.OrderDescending ? query.OrderByDescending(p => p.CreatedAt) : query.OrderBy(p => p.CreatedAt)
        };

        var totalCount = await query.CountAsync(cancellationToken);

        var items = await query
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<MembershipPackageResponse>
        {
            Items = items.Select(MembershipPackageMappings.ToResponse).ToList(),
            TotalCount = totalCount,
            TotalPages = (int)Math.Ceiling(totalCount / (double)request.PageSize),
            CurrentPage = request.PageNumber,
            PageSize = request.PageSize
        };
    }
}
