using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Nutritionists.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Nutritionists.Queries;

public class GetPagedNutritionistsQuery : IRequest<PagedResult<NutritionistResponse>>
{
    public NutritionistFilter Filter { get; set; } = new();
}

public class GetPagedNutritionistsQueryHandler : IRequestHandler<GetPagedNutritionistsQuery, PagedResult<NutritionistResponse>>
{
    private readonly INutritionistRepository _nutritionistRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetPagedNutritionistsQueryHandler(
        INutritionistRepository nutritionistRepository,
        ICurrentUserService currentUserService)
    {
        _nutritionistRepository = nutritionistRepository;
        _currentUserService = currentUserService;
    }

    public async Task<PagedResult<NutritionistResponse>> Handle(
        GetPagedNutritionistsQuery request,
        CancellationToken cancellationToken)
    {
        EnsureReadAccess();

        var filter = request.Filter ?? new NutritionistFilter();
        var page = await _nutritionistRepository.GetPagedAsync(filter, cancellationToken);

        return new PagedResult<NutritionistResponse>
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

    private static NutritionistResponse MapToResponse(Nutritionist nutritionist)
    {
        return new NutritionistResponse
        {
            Id = nutritionist.Id,
            FirstName = nutritionist.FirstName,
            LastName = nutritionist.LastName,
            Email = nutritionist.Email,
            PhoneNumber = nutritionist.PhoneNumber,
            CreatedAt = nutritionist.CreatedAt
        };
    }
}

public class GetPagedNutritionistsQueryValidator : AbstractValidator<GetPagedNutritionistsQuery>
{
    public GetPagedNutritionistsQueryValidator()
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
