using FluentValidation;
using MediatR;
using Stronghold.Application.Common.Authorization;
using Stronghold.Application.Features.Reviews.DTOs;

namespace Stronghold.Application.Features.Reviews.Commands;

public class UpdateReviewCommand : IRequest<ReviewResponse>, IAuthorizeAuthenticatedRequest
{
    public int Id { get; set; }
}

public class UpdateReviewCommandHandler : IRequestHandler<UpdateReviewCommand, ReviewResponse>
{
    public Task<ReviewResponse> Handle(UpdateReviewCommand request, CancellationToken cancellationToken)
    {
        throw new InvalidOperationException("Recenzije se ne mogu mijenjati.");
    }
}

public class UpdateReviewCommandValidator : AbstractValidator<UpdateReviewCommand>
{
    public UpdateReviewCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }