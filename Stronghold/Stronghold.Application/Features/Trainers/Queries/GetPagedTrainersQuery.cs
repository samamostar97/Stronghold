using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Trainers.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Trainers.Queries;

public class GetPagedTrainersQuery : IRequest<PagedResult<TrainerResponse>>
{
    public TrainerFilter Filter { get; set; } = new();
}

public class GetPagedTrainersQueryHandler : IRequestHandler<GetPagedTrainersQuery, PagedResult<TrainerResponse>>
{
    private readonly ITrainerRepository _trainerRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetPagedTrainersQueryHandler(ITrainerRepository trainerRepository, ICurrentUserService currentUserService)
    {
        _trainerRepository = trainerRepository;
        _currentUserService = currentUserService;
    }

    public async Task<PagedResult<TrainerResponse>> Handle(GetPagedTrainersQuery request, CancellationToken cancellationToken)
    {
        EnsureReadAccess();

        var filter = request.Filter ?? new TrainerFilter();
        var page = await _trainerRepository.GetPagedAsync(filter, cancellationToken);

        return new PagedResult<TrainerResponse>
        {
            Items = page.Items.Select(MapToResponse).ToList(),
            TotalCount = page.TotalCount,
            PageNumber = page.PageNumber
        };
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

public class GetPagedTrainersQueryValidator : AbstractValidator<GetPagedTrainersQuery>
{
    public GetPagedTrainersQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull();

        RuleFor(x => x.Filter.PageNumber)
            .GreaterThanOrEqualTo(1);

        RuleFor(x => x.Filter.PageSize)
            .GreaterThanOrEqualTo(1)
            .LessThanOrEqualTo(100);

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
