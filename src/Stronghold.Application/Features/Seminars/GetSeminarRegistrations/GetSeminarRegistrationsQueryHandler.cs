using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Seminars.GetSeminarRegistrations;

public class GetSeminarRegistrationsQueryHandler : IRequestHandler<GetSeminarRegistrationsQuery, List<SeminarRegistrationResponse>>
{
    private readonly ISeminarRepository _seminarRepository;
    private readonly ISeminarRegistrationRepository _registrationRepository;

    public GetSeminarRegistrationsQueryHandler(ISeminarRepository seminarRepository, ISeminarRegistrationRepository registrationRepository)
    {
        _seminarRepository = seminarRepository;
        _registrationRepository = registrationRepository;
    }

    public async Task<List<SeminarRegistrationResponse>> Handle(GetSeminarRegistrationsQuery request, CancellationToken cancellationToken)
    {
        var seminar = await _seminarRepository.GetByIdAsync(request.SeminarId)
            ?? throw new NotFoundException("Seminar", request.SeminarId);

        var registrations = await _registrationRepository.Query()
            .Include(r => r.User)
            .Where(r => r.SeminarId == request.SeminarId)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync(cancellationToken);

        return registrations.Select(r => r.ToResponse()).ToList();
    }
}
