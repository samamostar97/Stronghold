using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Reviews.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Reviews.Queries;

public class GetMyReviewsQuery : IRequest<PagedResult<UserReviewResponse>>
{
    public ReviewFilter Filter { get; set; } = new();
}

public class GetMyReviewsQueryHandler : IRequestHandler<GetMyReviewsQuery, PagedResult<UserReviewResponse>>
{
    private readonly IReviewRepository _reviewRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetMyReviewsQueryHandler(
        IReviewRepository reviewRepository,
        ICurrentUserService currentUserService)
    {
        _reviewRepository = reviewRepository;
        _currentUserService = currentUserService;
    }

    public async Task<PagedResult<UserReviewResponse>> Handle(GetMyReviewsQuery request, CancellationToken cancellationToken)
    {
        var userId = EnsureGymMemberAccess();

        var filter = request.Filter ?? new ReviewFilter();
        var page = await _reviewRepository.GetPagedByUserAsync(userId, filter, cancellationToken);

        return new PagedResult<UserReviewResponse>
        {
            Items = page.Items.Select(MapToUserResponse).ToList(),
            TotalCount = page.TotalCount,
            PageNumber = page.PageNumber
        };
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

    private static UserReviewResponse MapToUserResponse(Review review)
    {
        return new UserReviewResponse
        {
            Id = review.Id,
            SupplementName = review.Supplement?.Name ?? string.Empty,
            Rating = review.Rating,
            Comment = review.Comment,
            CreatedAt = review.CreatedAt
        };
    }
}

public class GetMyReviewsQueryValidator : AbstractValidator<GetMyReviewsQuery>
{
    public GetMyReviewsQueryValidator()
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
        var normalized = orderBy?.Trim().ToLowerInvariant();
        return normalized is
            "supplement" or
            "supplementdesc" or
            "rating" or
            "ratingdesc" or
            "createdat" or
            "createdatdesc";
    }
}
