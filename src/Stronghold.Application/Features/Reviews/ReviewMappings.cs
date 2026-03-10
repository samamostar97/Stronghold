using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.Reviews;

public static class ReviewMappings
{
    public static ReviewResponse ToResponse(Review review)
    {
        return new ReviewResponse
        {
            Id = review.Id,
            UserId = review.UserId,
            UserName = review.User != null
                ? $"{review.User.FirstName} {review.User.LastName}"
                : string.Empty,
            Rating = review.Rating,
            Comment = review.Comment,
            ReviewType = review.ReviewType.ToString(),
            ProductId = review.ProductId,
            AppointmentId = review.AppointmentId,
            CreatedAt = review.CreatedAt
        };
    }
}
