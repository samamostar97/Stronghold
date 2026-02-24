using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Reviews.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Reviews.Queries;

public class GetReviewByIdQuery : IRequest<ReviewResponse>
{
    public int Id { get; set; }
}

public class GetReviewByIdQueryHandler : IRequestHandler<GetReviewByIdQuery, ReviewResponse>
{
    private readonly IReviewRepository _reviewRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetReviewByIdQueryHandler(
        IReviewRepository reviewRepository,
        ICurrentUserService currentUserService)
    {
        _reviewRepository = reviewRepository;
        _currentUserService = currentUserService;
    }

    public async Task<ReviewResponse> Handle(GetReviewByIdQuery request, CancellationToken cancellationToken)
    {
        EnsureReadAccess();

        var review = await _reviewRepository.GetByIdAsync(request.Id, cancellationToken);
        if (review is null)
        {
            throw new KeyNotFoundException($"Recenzija sa id '{request.Id}' ne postoji.");
        }

        return MapToResponse(review);
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

public class GetReviewByIdQueryValidator : AbstractValidator<GetReviewByIdQuery>
{
    public GetReviewByIdQueryValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
}

