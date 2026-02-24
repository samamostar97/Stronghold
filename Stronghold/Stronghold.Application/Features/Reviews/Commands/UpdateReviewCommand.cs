using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Reviews.DTOs;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Reviews.Commands;

public class UpdateReviewCommand : IRequest<ReviewResponse>
{
    public int Id { get; set; }
}

public class UpdateReviewCommandHandler : IRequestHandler<UpdateReviewCommand, ReviewResponse>
{
    private readonly ICurrentUserService _currentUserService;

    public UpdateReviewCommandHandler(ICurrentUserService currentUserService)
    {
        _currentUserService = currentUserService;
    }

    public Task<ReviewResponse> Handle(UpdateReviewCommand request, CancellationToken cancellationToken)
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        throw new InvalidOperationException("Recenzije se ne mogu mijenjati.");
    }
}

public class UpdateReviewCommandValidator : AbstractValidator<UpdateReviewCommand>
{
    public UpdateReviewCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0);
    }
}
