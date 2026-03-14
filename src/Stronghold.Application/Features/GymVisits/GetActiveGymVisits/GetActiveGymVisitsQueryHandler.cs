using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;

namespace Stronghold.Application.Features.GymVisits.GetActiveGymVisits;

public class GetActiveGymVisitsQueryHandler : IRequestHandler<GetActiveGymVisitsQuery, List<GymVisitResponse>>
{
    private readonly IGymVisitRepository _gymVisitRepository;

    public GetActiveGymVisitsQueryHandler(IGymVisitRepository gymVisitRepository)
    {
        _gymVisitRepository = gymVisitRepository;
    }

    public async Task<List<GymVisitResponse>> Handle(GetActiveGymVisitsQuery request, CancellationToken cancellationToken)
    {
        var activeVisits = await _gymVisitRepository.QueryAll()
            .Include(v => v.User)
            .Where(v => v.CheckOutAt == null)
            .OrderByDescending(v => v.CheckInAt)
            .ToListAsync(cancellationToken);

        return activeVisits.Select(GymVisitMappings.ToResponse).ToList();
    }
}
