using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Trainers.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Trainers.Queries;

public class GetTrainersQuery : IRequest<IReadOnlyList<TrainerResponse>>
{
    public TrainerFilter Filter { get; set; } = new();
}

public class GetTrainersQueryHandler : IRequestHandler<GetTrainersQuery, IReadOnlyList<TrainerResponse>>
{
    private readonly ITrainerRepository _trainerRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetTrainersQueryHandler(ITrainerRepository trainerRepository, ICurrentUserService currentUserService)
    {
        _trainerRepository = trainerRepository;
        _currentUserService = currentUserService;
    }

    public async Task<IReadOnlyList<TrainerResponse>> Handle(GetTrainersQuery request, CancellationToken cancellationToken)
    {
        EnsureReadAccess();

        var filter = request.Filter ?? new TrainerFilter();
        filter.PageNumber = 1;
        filter.PageSize = int.MaxValue;

        var page = await _trainerRepository.GetPagedAsync(filter, cancellationToken);
        return page.Items.Select(MapToResponse).ToList();
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

public class GetTrainersQueryValidator : AbstractValidator<GetTrainersQuery>
{
    public GetTrainersQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull();

        RuleFor(x => x.Filter.Search)
            .MaximumLength(200)
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.Search));

        RuleFor(x => x.Filter.OrderBy)
            .MaximumLength(30)
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.OrderBy));

        RuleFor(x => x.Filter.OrderBy)
            .Must(BeValidOrderBy)
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.OrderBy))
            .WithMessage("Neispravna vrijednost za sortiranje.");
    }

    private static bool BeValidOrderBy(string? orderBy)
    {
        var value = orderBy?.Trim().ToLowerInvariant();
        return value is
            "firstname" or
            "firstnamedesc" or
            "lastname" or
            "lastnamedesc" or
            "createdat" or
            "createdatdesc";
    }
}
