using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Reviews.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reviews.Queries;

public class GetReviewsQuery : IRequest<IReadOnlyList<ReviewResponse>>, IAuthorizeAdminOrGymMemberRequest
{
    public ReviewFilter Filter { get; set; } = new();
}

public class GetReviewsQueryHandler : IRequestHandler<GetReviewsQuery, IReadOnlyList<ReviewResponse>>
{
    private readonly IReviewRepository _reviewRepository;

    public GetReviewsQueryHandler(
        IReviewRepository reviewRepository)
    {
        _reviewRepository = reviewRepository;
    }

public async Task<IReadOnlyList<ReviewResponse>> Handle(GetReviewsQuery request, CancellationToken cancellationToken)
    {
        var filter = request.Filter ?? new ReviewFilter();
        filter.PageNumber = 1;
        filter.PageSize = int.MaxValue;

        var page = await _reviewRepository.GetPagedAsync(filter, cancellationToken);
        return page.Items.Select(MapToResponse).ToList();
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