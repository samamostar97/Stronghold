using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.Reviews.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reviews.Commands;

public class CreateReviewCommand : IRequest<ReviewResponse>, IAuthorizeGymMemberRequest
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
        var userId = _currentUserService.UserId!.Value;
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
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");

        RuleFor(x => x.Rating)
            .InclusiveBetween(1, 5).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");

        RuleFor(x => x.Comment)
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(1000).WithMessage("{PropertyName} ne smije imati vise od 1000 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Comment));
    }
    }