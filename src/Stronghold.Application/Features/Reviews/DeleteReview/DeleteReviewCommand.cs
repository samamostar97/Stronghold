using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Reviews.DeleteReview;

[AuthorizeRole("User")]
public class DeleteReviewCommand : IRequest<Unit>
{
    public int Id { get; set; }
}
