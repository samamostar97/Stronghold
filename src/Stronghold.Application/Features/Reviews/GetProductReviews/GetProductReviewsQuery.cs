using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Reviews.GetProductReviews;

[AuthorizeRole("Admin")]
[AuthorizeRole("User")]
public class GetProductReviewsQuery : BaseQueryFilter, IRequest<PagedResult<ReviewResponse>>
{
    public int ProductId { get; set; }
}
