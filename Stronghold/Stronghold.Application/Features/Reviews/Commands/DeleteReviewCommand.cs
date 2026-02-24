using FluentValidation;
using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Reviews.Commands;

public class DeleteReviewCommand : IRequest<Unit>
{
    public int Id { get; set; }
}

public class DeleteReviewCommandHandler : IRequestHandler<DeleteReviewCommand, Unit>
{
    private readonly IReviewRepository _reviewRepository;
    private readonly ICurrentUserService _currentUserService;

    public DeleteReviewCommandHandler(
        IReviewRepository reviewRepository,
        ICurrentUserService currentUserService)
    {
        _reviewRepository = reviewRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteReviewCommand request, CancellationToken cancellationToken)
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        var review = await _reviewRepository.GetByIdAsync(request.Id, cancellationToken);
        if (review is null)
        {
            throw new KeyNotFoundException($"Recenzija sa id '{request.Id}' ne postoji.");
        }

        var isAdmin = _currentUserService.IsInRole("Admin");
        if (!isAdmin)
        {
            var isGymMember = _currentUserService.IsInRole("GymMember");
            if (!isGymMember)
            {
                throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
            }

            var isOwner = await _reviewRepository.IsOwnerAsync(request.Id, _currentUserService.UserId.Value, cancellationToken);
            if (!isOwner)
            {
                throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
            }
        }

        await _reviewRepository.DeleteAsync(review, cancellationToken);
        return Unit.Value;
    }
}

public class DeleteReviewCommandValidator : AbstractValidator<DeleteReviewCommand>
{
    public DeleteReviewCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0);
    }
}
