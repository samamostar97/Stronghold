using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Reviews.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Reviews.Queries;

public class GetAvailableSupplementsForReviewQuery : IRequest<PagedResult<PurchasedSupplementResponse>>
{
    public ReviewFilter Filter { get; set; } = new();
}

public class GetAvailableSupplementsForReviewQueryHandler
    : IRequestHandler<GetAvailableSupplementsForReviewQuery, PagedResult<PurchasedSupplementResponse>>
{
    private readonly IReviewRepository _reviewRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetAvailableSupplementsForReviewQueryHandler(
        IReviewRepository reviewRepository,
        ICurrentUserService currentUserService)
    {
        _reviewRepository = reviewRepository;
        _currentUserService = currentUserService;
    }

    public async Task<PagedResult<PurchasedSupplementResponse>> Handle(
        GetAvailableSupplementsForReviewQuery request,
        CancellationToken cancellationToken)
    {
        var userId = EnsureGymMemberAccess();

        var filter = request.Filter ?? new ReviewFilter();
        return await _reviewRepository.GetPurchasedSupplementsForReviewAsync(userId, filter, cancellationToken);
    }

    private int EnsureGymMemberAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("GymMember"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }

        return _currentUserService.UserId.Value;
    }
}

public class GetAvailableSupplementsForReviewQueryValidator : AbstractValidator<GetAvailableSupplementsForReviewQuery>
{
    public GetAvailableSupplementsForReviewQueryValidator()
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
        var normalized = orderBy?.Trim().ToLowerInvariant();
        return normalized is "name" or "namedesc";
    }
}

