using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;

namespace Stronghold.Application.Features.GymVisits.GetGymVisits;

public class GetGymVisitsQueryHandler : IRequestHandler<GetGymVisitsQuery, PagedResult<GymVisitResponse>>
{
    private readonly IGymVisitRepository _gymVisitRepository;

    public GetGymVisitsQueryHandler(IGymVisitRepository gymVisitRepository)
    {
        _gymVisitRepository = gymVisitRepository;
    }

    public async Task<PagedResult<GymVisitResponse>> Handle(GetGymVisitsQuery request, CancellationToken cancellationToken)
    {
        IQueryable<Domain.Entities.GymVisit> query = _gymVisitRepository.Query()
            .Include(v => v.User);

        if (request.UserId.HasValue)
            query = query.Where(v => v.UserId == request.UserId.Value);

        if (request.DateFrom.HasValue)
            query = query.Where(v => v.CheckInAt >= request.DateFrom.Value);

        if (request.DateTo.HasValue)
            query = query.Where(v => v.CheckInAt <= request.DateTo.Value);

        if (!string.IsNullOrWhiteSpace(request.Search))
        {
            var search = request.Search.ToLower();
            query = query.Where(v =>
                v.User.FirstName.ToLower().Contains(search) ||
                v.User.LastName.ToLower().Contains(search) ||
                v.User.Username.ToLower().Contains(search));
        }

        query = request.OrderBy?.ToLower() switch
        {
            "duration" => request.OrderDescending ? query.OrderByDescending(v => v.DurationMinutes) : query.OrderBy(v => v.DurationMinutes),
            _ => request.OrderDescending ? query.OrderByDescending(v => v.CheckInAt) : query.OrderBy(v => v.CheckInAt)
        };

        var totalCount = await query.CountAsync(cancellationToken);

        var items = await query
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<GymVisitResponse>
        {
            Items = items.Select(GymVisitMappings.ToResponse).ToList(),
            TotalCount = totalCount,
            TotalPages = (int)Math.Ceiling(totalCount / (double)request.PageSize),
            CurrentPage = request.PageNumber,
            PageSize = request.PageSize
        };
    }
}
