using MediatR;
using Stronghold.Domain.Exceptions;
using Stronghold.Application.Interfaces;

namespace Stronghold.Application.Features.Reviews.DeleteReview;

public class DeleteReviewCommandHandler : IRequestHandler<DeleteReviewCommand, Unit>
{
    private readonly IReviewRepository _reviewRepository;
    private readonly ICurrentUserService _currentUserService;

    public DeleteReviewCommandHandler(IReviewRepository reviewRepository, ICurrentUserService currentUserService)
    {
        _reviewRepository = reviewRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteReviewCommand request, CancellationToken cancellationToken)
    {
        var review = await _reviewRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Recenzija nije pronađena.");

        if (review.UserId != _currentUserService.UserId)
            throw new InvalidOperationException("Možete brisati samo vlastite recenzije.");

        review.IsDeleted = true;
        review.DeletedAt = DateTime.UtcNow;

        _reviewRepository.Update(review);
        await _reviewRepository.SaveChangesAsync();

        return Unit.Value;
    }
}
