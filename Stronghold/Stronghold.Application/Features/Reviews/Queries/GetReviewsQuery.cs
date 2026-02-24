using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Reviews.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Reviews.Queries;

public class GetReviewsQuery : IRequest<IReadOnlyList<ReviewResponse>>
{
    public ReviewFilter Filter { get; set; } = new();
}

public class GetReviewsQueryHandler : IRequestHandler<GetReviewsQuery, IReadOnlyList<ReviewResponse>>
{
    private readonly IReviewRepository _reviewRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetReviewsQueryHandler(
        IReviewRepository reviewRepository,
        ICurrentUserService currentUserService)
    {
        _reviewRepository = reviewRepository;
        _currentUserService = currentUserService;
    }

    public async Task<IReadOnlyList<ReviewResponse>> Handle(GetReviewsQuery request, CancellationToken cancellationToken)
    {
        EnsureReadAccess();

        var filter = request.Filter ?? new ReviewFilter();
        filter.PageNumber = 1;
        filter.PageSize = int.MaxValue;

        var page = await _reviewRepository.GetPagedAsync(filter, cancellationToken);
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

    private static ReviewResponse MapToResponse(Review review)
    {
        var userLastName = review.User?.LastName ?? string.Empty;
        return new ReviewResponse
        {
            Id = review.Id,
            UserId = review.UserId,
            UserName = review.User == null
                ? string.Empty
                : (review.User.FirstName + " " + userLastName).Trim(),
            SupplementId = review.SupplementId,
            SupplementName = review.Supplement?.Name ?? string.Empty,
            Rating = review.Rating,
            Comment = review.Comment,
            CreatedAt = review.CreatedAt
        };
    }
}

public class GetReviewsQueryValidator : AbstractValidator<GetReviewsQuery>
{
    public GetReviewsQueryValidator()
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
        var normalized = orderBy?.Trim().ToLowerInvariant();
        return normalized is
            "firstname" or
            "firstnamedesc" or
            "supplement" or
            "supplementdesc" or
            "rating" or
            "ratingdesc" or
            "createdat" or
            "createdatdesc";
    }
}
