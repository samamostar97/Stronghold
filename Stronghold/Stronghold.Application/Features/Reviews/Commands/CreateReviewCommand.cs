using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.Reviews.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Reviews.Commands;

public class CreateReviewCommand : IRequest<ReviewResponse>
{
    public int SupplementId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
}

public class CreateReviewCommandHandler : IRequestHandler<CreateReviewCommand, ReviewResponse>
{
    private readonly IReviewRepository _reviewRepository;
    private readonly ICurrentUserService _currentUserService;

    public CreateReviewCommandHandler(
        IReviewRepository reviewRepository,
        ICurrentUserService currentUserService)
    {
        _reviewRepository = reviewRepository;
        _currentUserService = currentUserService;
    }

    public async Task<ReviewResponse> Handle(CreateReviewCommand request, CancellationToken cancellationToken)
    {
        var userId = EnsureGymMemberAccess();

        var supplementExists = await _reviewRepository.SupplementExistsAsync(request.SupplementId, cancellationToken);
        if (!supplementExists)
        {
            throw new KeyNotFoundException($"Suplement sa id '{request.SupplementId}' ne postoji.");
        }

        var hasPurchased = await _reviewRepository.HasPurchasedSupplementAsync(userId, request.SupplementId, cancellationToken);
        if (!hasPurchased)
        {
            throw new InvalidOperationException("Mozete recenzirati samo kupljene suplemente.");
        }

        var alreadyReviewed = await _reviewRepository.ExistsByUserAndSupplementAsync(
            userId,
            request.SupplementId,
            cancellationToken);
        if (alreadyReviewed)
        {
            throw new ConflictException("Vec ste ostavili recenziju za ovaj suplement.");
        }

        var entity = new Review
        {
            UserId = userId,
            SupplementId = request.SupplementId,
            Rating = request.Rating,
            Comment = string.IsNullOrWhiteSpace(request.Comment) ? null : request.Comment.Trim()
        };

        await _reviewRepository.AddAsync(entity, cancellationToken);

        var created = await _reviewRepository.GetByIdAsync(entity.Id, cancellationToken) ?? entity;
        return MapToResponse(created);
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

public class CreateReviewCommandValidator : AbstractValidator<CreateReviewCommand>
{
    public CreateReviewCommandValidator()
    {
        RuleFor(x => x.SupplementId)
            .GreaterThan(0);

        RuleFor(x => x.Rating)
            .InclusiveBetween(1, 5);

        RuleFor(x => x.Comment)
            .MinimumLength(2)
            .MaximumLength(1000)
            .When(x => !string.IsNullOrWhiteSpace(x.Comment));
    }
}
