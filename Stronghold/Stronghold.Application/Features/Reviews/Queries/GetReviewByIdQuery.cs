using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Reviews.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reviews.Queries;

public class GetReviewByIdQuery : IRequest<ReviewResponse>, IAuthorizeAdminOrGymMemberRequest
{
    public int Id { get; set; }
}

public class GetReviewByIdQueryHandler : IRequestHandler<GetReviewByIdQuery, ReviewResponse>
{
    private readonly IReviewRepository _reviewRepository;

    public GetReviewByIdQueryHandler(
        IReviewRepository reviewRepository)
    {
        _reviewRepository = reviewRepository;
    }

public async Task<ReviewResponse> Handle(GetReviewByIdQuery request, CancellationToken cancellationToken)
    {
        var review = await _reviewRepository.GetByIdAsync(request.Id, cancellationToken);
        if (review is null)
        {
            throw new KeyNotFoundException($"Recenzija sa id '{request.Id}' ne postoji.");
        }

        return MapToResponse(review);
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

public class GetReviewByIdQueryValidator : AbstractValidator<GetReviewByIdQuery>
{
    public GetReviewByIdQueryValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }