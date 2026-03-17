using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;

namespace Stronghold.Application.Features.Seminars.GetSeminars;

public class GetSeminarsQueryHandler : IRequestHandler<GetSeminarsQuery, PagedResult<SeminarResponse>>
{
    private readonly ISeminarRepository _seminarRepository;

    public GetSeminarsQueryHandler(ISeminarRepository seminarRepository)
    {
        _seminarRepository = seminarRepository;
    }

    public async Task<PagedResult<SeminarResponse>> Handle(GetSeminarsQuery request, CancellationToken cancellationToken)
    {
        IQueryable<Domain.Entities.Seminar> query = _seminarRepository.Query()
            .Include(s => s.Registrations.Where(r => !r.IsDeleted));

        var now = DateTime.UtcNow;
        if (string.Equals(request.Status, "upcoming", StringComparison.OrdinalIgnoreCase))
            query = query.Where(s => s.StartDate >= now);
        else if (string.Equals(request.Status, "completed", StringComparison.OrdinalIgnoreCase))
            query = query.Where(s => s.StartDate < now);

        if (!string.IsNullOrEmpty(request.Search))
        {
            var search = request.Search.ToLower();
            query = query.Where(s =>
                s.Name.ToLower().Contains(search) ||
                s.Lecturer.ToLower().Contains(search));
        }

        query = request.OrderDescending
            ? query.OrderByDescending(s => s.StartDate)
            : query.OrderBy(s => s.StartDate);

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<SeminarResponse>
        {
            Items = items.Select(s => s.ToResponse(s.Registrations.Count)).ToList(),
            TotalCount = totalCount,
            CurrentPage = request.PageNumber,
            PageSize = request.PageSize
        };
    }
}
