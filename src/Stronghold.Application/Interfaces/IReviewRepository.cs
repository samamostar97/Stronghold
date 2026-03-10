using Stronghold.Domain.Entities;

namespace Stronghold.Application.Interfaces;

public interface IReviewRepository : IRepository<Review>
{
    Task<Review?> GetByIdWithDetailsAsync(int id);
    Task<bool> UserHasReviewedProductAsync(int userId, int productId);
    Task<bool> UserHasReviewedAppointmentAsync(int userId, int appointmentId);
}
