using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Reviews.CreateReview;

[AuthorizeRole("User")]
public class CreateReviewCommand : IRequest<ReviewResponse>
{
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public string ReviewType { get; set; } = string.Empty;
    public int? ProductId { get; set; }
    public int? AppointmentId { get; set; }
}
