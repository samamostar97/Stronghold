using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Recommendations.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Recommendations.Queries;

public class GetRecommendationsQuery : IRequest<IReadOnlyList<RecommendationResponse>>, IAuthorizeAuthenticatedRequest
{
    public int Count { get; set; } = 6;
}

public class GetRecommendationsQueryHandler : IRequestHandler<GetRecommendationsQuery, IReadOnlyList<RecommendationResponse>>
{
    private readonly IRecommendationService _recommendationService;
    private readonly ICurrentUserService _currentUserService;

    public GetRecommendationsQueryHandler(
        IRecommendationService recommendationService,
        ICurrentUserService currentUserService)
    {
        _recommendationService = recommendationService;
        _currentUserService = currentUserService;
    }

public async Task<IReadOnlyList<RecommendationResponse>> Handle(
        GetRecommendationsQuery request,
        CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId!.Value;
        var recommendations = await _recommendationService.GetRecommendationsAsync(userId, request.Count);
        return recommendations;
    }
    }

public class GetRecommendationsQueryValidator : AbstractValidator<GetRecommendationsQuery>
{
    public GetRecommendationsQueryValidator()
    {
        RuleFor(x => x.Count)
            .InclusiveBetween(1, 50).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");
    }
    }