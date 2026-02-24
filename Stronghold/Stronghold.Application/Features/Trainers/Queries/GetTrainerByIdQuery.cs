using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Trainers.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Trainers.Queries;

public class GetTrainerByIdQuery : IRequest<TrainerResponse>
{
    public int Id { get; set; }
}

public class GetTrainerByIdQueryHandler : IRequestHandler<GetTrainerByIdQuery, TrainerResponse>
{
    private readonly ITrainerRepository _trainerRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetTrainerByIdQueryHandler(ITrainerRepository trainerRepository, ICurrentUserService currentUserService)
    {
        _trainerRepository = trainerRepository;
        _currentUserService = currentUserService;
    }

    public async Task<TrainerResponse> Handle(GetTrainerByIdQuery request, CancellationToken cancellationToken)
    {
        EnsureReadAccess();

        var trainer = await _trainerRepository.GetByIdAsync(request.Id, cancellationToken);
        if (trainer is null)
        {
            throw new KeyNotFoundException($"Trener sa id '{request.Id}' ne postoji.");
        }

        return MapToResponse(trainer);
    }

    private void EnsureReadAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("Admin") && !_currentUserService.IsInRole("GymMember"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }
    }

    private static TrainerResponse MapToResponse(Trainer trainer)
    {
        return new TrainerResponse
        {
            Id = trainer.Id,
            FirstName = trainer.FirstName,
            LastName = trainer.LastName,
            Email = trainer.Email,
            PhoneNumber = trainer.PhoneNumber,
            CreatedAt = trainer.CreatedAt
        };
    }
}

public class GetTrainerByIdQueryValidator : AbstractValidator<GetTrainerByIdQuery>
{
    public GetTrainerByIdQueryValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0);
    }
}
