using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Recommendations.DTOs;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Recommendations.Queries;

public class GetRecommendationsQuery : IRequest<IReadOnlyList<RecommendationResponse>>
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
        var userId = EnsureAuthenticatedAccess();
        var recommendations = await _recommendationService.GetRecommendationsAsync(userId, request.Count);
        return recommendations;
    }

    private int EnsureAuthenticatedAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        return _currentUserService.UserId.Value;
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

