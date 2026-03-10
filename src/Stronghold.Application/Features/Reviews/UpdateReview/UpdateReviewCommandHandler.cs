using MediatR;
using Stronghold.Domain.Exceptions;
using Stronghold.Application.Interfaces;

namespace Stronghold.Application.Features.Reviews.UpdateReview;

public class UpdateReviewCommandHandler : IRequestHandler<UpdateReviewCommand, ReviewResponse>
{
    private readonly IReviewRepository _reviewRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateReviewCommandHandler(IReviewRepository reviewRepository, ICurrentUserService currentUserService)
    {
        _reviewRepository = reviewRepository;
        _currentUserService = currentUserService;
    }

    public async Task<ReviewResponse> Handle(UpdateReviewCommand request, CancellationToken cancellationToken)
    {
        var review = await _reviewRepository.GetByIdWithDetailsAsync(request.Id)
            ?? throw new NotFoundException("Recenzija nije pronađena.");

        if (review.UserId != _currentUserService.UserId)
            throw new InvalidOperationException("Možete uređivati samo vlastite recenzije.");

        review.Rating = request.Rating;
        review.Comment = request.Comment;

        _reviewRepository.Update(review);
        await _reviewRepository.SaveChangesAsync();

        return ReviewMappings.ToResponse(review);
    }
}
