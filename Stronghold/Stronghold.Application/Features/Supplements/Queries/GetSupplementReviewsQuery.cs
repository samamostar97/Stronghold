using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Supplements.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Supplements.Queries;

public class GetSupplementReviewsQuery : IRequest<IReadOnlyList<SupplementReviewResponse>>, IAuthorizeAdminOrGymMemberRequest
{
    public int SupplementId { get; set; }
}

public class GetSupplementReviewsQueryHandler : IRequestHandler<GetSupplementReviewsQuery, IReadOnlyList<SupplementReviewResponse>>
{
    private readonly ISupplementRepository _supplementRepository;

    public GetSupplementReviewsQueryHandler(ISupplementRepository supplementRepository)
    {
        _supplementRepository = supplementRepository;
    }

public async Task<IReadOnlyList<SupplementReviewResponse>> Handle(
        GetSupplementReviewsQuery request,
        CancellationToken cancellationToken)
    {
        var reviews = await _supplementRepository.GetReviewsAsync(request.SupplementId, cancellationToken);

        return reviews.Select(review => new SupplementReviewResponse
        {
            Id = review.Id,
            UserName = review.User != null
                ? review.User.FirstName + " " + (!string.IsNullOrWhiteSpace(review.User.LastName)
                    ? review.User.LastName.Substring(0, 1) + "."
                    : string.Empty)
                : "Anonimno",
            Rating = review.Rating,
            Comment = review.Comment,
            CreatedAt = review.CreatedAt
        }).ToList();
    }
    }

public class GetSupplementReviewsQueryValidator : AbstractValidator<GetSupplementReviewsQuery>
{
    public GetSupplementReviewsQueryValidator()
    {
        RuleFor(x => x.SupplementId)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }