using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Reviews.GetStaffReviews;

public class GetStaffReviewsQueryHandler : IRequestHandler<GetStaffReviewsQuery, PagedResult<ReviewResponse>>
{
    private readonly IReviewRepository _reviewRepository;

    public GetStaffReviewsQueryHandler(IReviewRepository reviewRepository)
    {
        _reviewRepository = reviewRepository;
    }

    public async Task<PagedResult<ReviewResponse>> Handle(GetStaffReviewsQuery request, CancellationToken cancellationToken)
    {
        IQueryable<Domain.Entities.Review> query = _reviewRepository.Query()
            .Include(r => r.User)
            .Include(r => r.Appointment)
            .Where(r => r.ReviewType == ReviewType.Appointment && r.Appointment!.StaffId == request.StaffId);

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
