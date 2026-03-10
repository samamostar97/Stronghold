using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Reviews.GetUserReviews;

[AuthorizeRole("Admin")]
public class GetUserReviewsQuery : BaseQueryFilter, IRequest<PagedResult<ReviewResponse>>
{
    public int UserId { get; set; }
}
