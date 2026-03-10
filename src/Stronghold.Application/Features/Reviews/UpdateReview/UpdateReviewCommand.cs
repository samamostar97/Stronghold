using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Reviews.UpdateReview;

[AuthorizeRole("User")]
public class UpdateReviewCommand : IRequest<ReviewResponse>
{
    public int Id { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
}
