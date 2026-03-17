using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;

namespace Stronghold.Application.Features.Seminars.GetMySeminars;

public class GetMySeminarsQueryHandler : IRequestHandler<GetMySeminarsQuery, List<SeminarResponse>>
{
    private readonly ISeminarRegistrationRepository _registrationRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetMySeminarsQueryHandler(
        ISeminarRegistrationRepository registrationRepository,
        ICurrentUserService currentUserService)
    {
        _registrationRepository = registrationRepository;
        _currentUserService = currentUserService;
    }

    public async Task<List<SeminarResponse>> Handle(GetMySeminarsQuery request, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId;

        var registrations = await _registrationRepository.Query()
            .Include(r => r.Seminar).ThenInclude(s => s.Registrations.Where(sr => !sr.IsDeleted))
            .Where(r => r.UserId == userId)
            .OrderByDescending(r => r.Seminar.StartDate)
            .ToListAsync(cancellationToken);

        return registrations
            .Select(r => r.Seminar.ToResponse(r.Seminar.Registrations.Count))
            .ToList();
    }
}
