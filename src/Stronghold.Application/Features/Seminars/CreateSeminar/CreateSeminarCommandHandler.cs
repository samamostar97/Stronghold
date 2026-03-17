using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.Seminars.CreateSeminar;

public class CreateSeminarCommandHandler : IRequestHandler<CreateSeminarCommand, SeminarResponse>
{
    private readonly ISeminarRepository _seminarRepository;

    public CreateSeminarCommandHandler(ISeminarRepository seminarRepository)
    {
        _seminarRepository = seminarRepository;
    }

    public async Task<SeminarResponse> Handle(CreateSeminarCommand request, CancellationToken cancellationToken)
    {
        var seminar = new Seminar
        {
            Name = request.Name,
            Description = request.Description,
            Lecturer = request.Lecturer,
            StartDate = request.StartDate,
            MaxCapacity = request.MaxCapacity
        };

        await _seminarRepository.AddAsync(seminar);
        await _seminarRepository.SaveChangesAsync();

        return seminar.ToResponse();
    }
}
