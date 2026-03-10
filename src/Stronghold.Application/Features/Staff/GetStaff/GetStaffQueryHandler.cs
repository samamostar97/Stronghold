using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Staff.GetStaff;

public class GetStaffQueryHandler : IRequestHandler<GetStaffQuery, PagedResult<StaffResponse>>
{
    private readonly IStaffRepository _staffRepository;

    public GetStaffQueryHandler(IStaffRepository staffRepository)
    {
        _staffRepository = staffRepository;
    }

    public async Task<PagedResult<StaffResponse>> Handle(GetStaffQuery request, CancellationToken cancellationToken)
    {
        var query = _staffRepository.Query();

        if (!string.IsNullOrWhiteSpace(request.StaffType) && Enum.TryParse<StaffType>(request.StaffType, true, out var staffType))
        {
            query = query.Where(s => s.StaffType == staffType);
        }

        if (!string.IsNullOrWhiteSpace(request.Search))
        {
            var search = request.Search.ToLower();
            query = query.Where(s =>
                s.FirstName.ToLower().Contains(search) ||
                s.LastName.ToLower().Contains(search) ||
                s.Email.ToLower().Contains(search));
        }

        query = request.OrderBy?.ToLower() switch
        {
            "firstname" => request.OrderDescending ? query.OrderByDescending(s => s.FirstName) : query.OrderBy(s => s.FirstName),
            "lastname" => request.OrderDescending ? query.OrderByDescending(s => s.LastName) : query.OrderBy(s => s.LastName),
            "email" => request.OrderDescending ? query.OrderByDescending(s => s.Email) : query.OrderBy(s => s.Email),
            _ => request.OrderDescending ? query.OrderByDescending(s => s.CreatedAt) : query.OrderBy(s => s.CreatedAt)
        };

        var totalCount = await query.CountAsync(cancellationToken);

        var staff = await query
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<StaffResponse>
        {
            Items = staff.Select(StaffMappings.ToResponse).ToList(),
            TotalCount = totalCount,
            TotalPages = (int)Math.Ceiling(totalCount / (double)request.PageSize),
            CurrentPage = request.PageNumber,
            PageSize = request.PageSize
        };
    }
}
