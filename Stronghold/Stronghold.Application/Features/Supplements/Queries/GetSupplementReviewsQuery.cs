using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Supplements.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Supplements.Queries;

public class GetSupplementReviewsQuery : IRequest<IReadOnlyList<SupplementReviewResponse>>
{
    public int SupplementId { get; set; }
}

public class GetSupplementReviewsQueryHandler : IRequestHandler<GetSupplementReviewsQuery, IReadOnlyList<SupplementReviewResponse>>
{
    private readonly ISupplementRepository _supplementRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetSupplementReviewsQueryHandler(ISupplementRepository supplementRepository, ICurrentUserService currentUserService)
    {
        _supplementRepository = supplementRepository;
        _currentUserService = currentUserService;
    }

    public async Task<IReadOnlyList<SupplementReviewResponse>> Handle(
        GetSupplementReviewsQuery request,
        CancellationToken cancellationToken)
    {
        EnsureReadAccess();

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

    private void EnsureReadAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("Admin") && !_currentUserService.IsInRole("GymMember"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }
    }
}

public class GetSupplementReviewsQueryValidator : AbstractValidator<GetSupplementReviewsQuery>
{
    public GetSupplementReviewsQueryValidator()
    {
        RuleFor(x => x.SupplementId)
            .GreaterThan(0);
    }
}
