using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Trainers.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Trainers.Queries;

public class GetPagedTrainersQuery : IRequest<PagedResult<TrainerResponse>>, IAuthorizeAdminOrGymMemberRequest
{
    public TrainerFilter Filter { get; set; } = new();
}

public class GetPagedTrainersQueryHandler : IRequestHandler<GetPagedTrainersQuery, PagedResult<TrainerResponse>>
{
    private readonly ITrainerRepository _trainerRepository;

    public GetPagedTrainersQueryHandler(ITrainerRepository trainerRepository)
    {
        _trainerRepository = trainerRepository;
    }

public async Task<PagedResult<TrainerResponse>> Handle(GetPagedTrainersQuery request, CancellationToken cancellationToken)
    {
        var filter = request.Filter ?? new TrainerFilter();
        var page = await _trainerRepository.GetPagedAsync(filter, cancellationToken);

        return new PagedResult<TrainerResponse>
        {
            Items = page.Items.Select(MapToResponse).ToList(),
            TotalCount = page.TotalCount,
            PageNumber = page.PageNumber
        };
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

public class GetPagedTrainersQueryValidator : AbstractValidator<GetPagedTrainersQuery>
{
    public GetPagedTrainersQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.Filter.PageNumber)
            .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.");

        RuleFor(x => x.Filter.PageSize)
            .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.")
            .LessThanOrEqualTo(100).WithMessage("{PropertyName} mora biti manje ili jednako dozvoljenoj vrijednosti.");

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