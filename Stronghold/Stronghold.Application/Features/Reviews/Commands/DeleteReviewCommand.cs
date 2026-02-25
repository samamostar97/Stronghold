using FluentValidation;
using MediatR;
using Stronghold.Application.Common.Authorization;
using Stronghold.Application.Exceptions;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Reviews.Commands;

public class DeleteReviewCommand : IRequest<Unit>, IAuthorizeAdminOrGymMemberRequest
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
        var review = await _reviewRepository.GetByIdAsync(request.Id, cancellationToken);
        if (review is null)
        {
            throw new KeyNotFoundException($"Recenzija sa id '{request.Id}' ne postoji.");
        }

        if (!_currentUserService.IsInRole("Admin"))
        {
            var isOwner = await _reviewRepository.IsOwnerAsync(request.Id, _currentUserService.UserId!.Value, cancellationToken);
            if (!isOwner)
            {
                throw new ForbiddenException("Nemate dozvolu za ovu akciju.");
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
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }