using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Reviews.GetProductReviews;

public class GetProductReviewsQueryHandler : IRequestHandler<GetProductReviewsQuery, PagedResult<ReviewResponse>>
{
    private readonly IReviewRepository _reviewRepository;

    public GetProductReviewsQueryHandler(IReviewRepository reviewRepository)
    {
        _reviewRepository = reviewRepository;
    }

    public async Task<PagedResult<ReviewResponse>> Handle(GetProductReviewsQuery request, CancellationToken cancellationToken)
    {
        IQueryable<Domain.Entities.Review> query = _reviewRepository.Query()
            .Include(r => r.User)
            .Where(r => r.ReviewType == ReviewType.Product && r.ProductId == request.ProductId);

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
