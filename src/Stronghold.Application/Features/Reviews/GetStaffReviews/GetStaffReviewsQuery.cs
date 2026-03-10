using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Reviews.GetStaffReviews;

[AuthorizeRole("Admin")]
[AuthorizeRole("User")]
public class GetStaffReviewsQuery : BaseQueryFilter, IRequest<PagedResult<ReviewResponse>>
{
    public int StaffId { get; set; }
}
