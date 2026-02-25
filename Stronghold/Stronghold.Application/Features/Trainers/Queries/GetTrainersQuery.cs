using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Trainers.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Trainers.Queries;

public class GetTrainersQuery : IRequest<IReadOnlyList<TrainerResponse>>, IAuthorizeAdminOrGymMemberRequest
{
    public TrainerFilter Filter { get; set; } = new();
}

public class GetTrainersQueryHandler : IRequestHandler<GetTrainersQuery, IReadOnlyList<TrainerResponse>>
{
    private readonly ITrainerRepository _trainerRepository;

    public GetTrainersQueryHandler(ITrainerRepository trainerRepository)
    {
        _trainerRepository = trainerRepository;
    }

public async Task<IReadOnlyList<TrainerResponse>> Handle(GetTrainersQuery request, CancellationToken cancellationToken)
    {
        var filter = request.Filter ?? new TrainerFilter();
        filter.PageNumber = 1;
        filter.PageSize = int.MaxValue;

        var page = await _trainerRepository.GetPagedAsync(filter, cancellationToken);
        return page.Items.Select(MapToResponse).ToList();
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
        RuleFor(x => x.Filter).NotNull().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.Filter.Search)
            .MaximumLength(200).WithMessage("{PropertyName} ne smije imati vise od 200 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.Search));

        RuleFor(x => x.Filter.OrderBy)
            .MaximumLength(30).WithMessage("{PropertyName} ne smije imati vise od 30 karaktera.")
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