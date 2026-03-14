using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;

namespace Stronghold.Application.Features.Reviews.GetUserReviews;

public class GetUserReviewsQueryHandler : IRequestHandler<GetUserReviewsQuery, PagedResult<ReviewResponse>>
{
    private readonly IReviewRepository _reviewRepository;

    public GetUserReviewsQueryHandler(IReviewRepository reviewRepository)
    {
        _reviewRepository = reviewRepository;
    }

    public async Task<PagedResult<ReviewResponse>> Handle(GetUserReviewsQuery request, CancellationToken cancellationToken)
    {
        IQueryable<Domain.Entities.Review> query = _reviewRepository.QueryAll()
            .Include(r => r.User)
            .Where(r => r.UserId == request.UserId);

        var totalCount = await query.CountAsync(cancellationToken);

        var reviews = await query
            .OrderByDescending(r => r.CreatedAt)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<ReviewResponse>
        {
            Items = reviews.Select(ReviewMappings.ToResponse).ToList(),
            TotalCount = totalCount,
            CurrentPage = request.PageNumber,
            PageSize = request.PageSize,
            TotalPages = (int)Math.Ceiling(totalCount / (double)request.PageSize)
        };
    }
}
