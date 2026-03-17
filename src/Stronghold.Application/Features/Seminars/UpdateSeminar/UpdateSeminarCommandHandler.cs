using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Seminars.UpdateSeminar;

public class UpdateSeminarCommandHandler : IRequestHandler<UpdateSeminarCommand, SeminarResponse>
{
    private readonly ISeminarRepository _seminarRepository;
    private readonly ISeminarRegistrationRepository _registrationRepository;

    public UpdateSeminarCommandHandler(ISeminarRepository seminarRepository, ISeminarRegistrationRepository registrationRepository)
    {
        _seminarRepository = seminarRepository;
        _registrationRepository = registrationRepository;
    }

    public async Task<SeminarResponse> Handle(UpdateSeminarCommand request, CancellationToken cancellationToken)
    {
        var seminar = await _seminarRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Seminar", request.Id);

        seminar.Name = request.Name;
        seminar.Description = request.Description;
        seminar.Lecturer = request.Lecturer;
        seminar.StartDate = request.StartDate;
        seminar.MaxCapacity = request.MaxCapacity;

        await _seminarRepository.SaveChangesAsync();

        var count = await _registrationRepository.GetRegistrationCountAsync(seminar.Id);
        return seminar.ToResponse(count);
    }
}
