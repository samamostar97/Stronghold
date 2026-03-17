using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Seminars.GetSeminar;

public class GetSeminarQueryHandler : IRequestHandler<GetSeminarQuery, SeminarResponse>
{
    private readonly ISeminarRepository _seminarRepository;
    private readonly ISeminarRegistrationRepository _registrationRepository;

    public GetSeminarQueryHandler(ISeminarRepository seminarRepository, ISeminarRegistrationRepository registrationRepository)
    {
        _seminarRepository = seminarRepository;
        _registrationRepository = registrationRepository;
    }

    public async Task<SeminarResponse> Handle(GetSeminarQuery request, CancellationToken cancellationToken)
    {
        var seminar = await _seminarRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Seminar", request.Id);

        var count = await _registrationRepository.GetRegistrationCountAsync(seminar.Id);
        return seminar.ToResponse(count);
    }
}
