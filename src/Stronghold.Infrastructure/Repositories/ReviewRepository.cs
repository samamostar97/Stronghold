using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Enums;
using Stronghold.Infrastructure.Persistence;

namespace Stronghold.Infrastructure.Repositories;

public class ReviewRepository : Repository<Review>, IReviewRepository
{
    public ReviewRepository(StrongholdDbContext context) : base(context) { }

    public async Task<Review?> GetByIdWithDetailsAsync(int id)
    {
        return await _dbSet
            .Include(r => r.User)
            .Include(r => r.Product)
            .Include(r => r.Appointment)
            .FirstOrDefaultAsync(r => r.Id == id);
    }

    public async Task<bool> UserHasReviewedProductAsync(int userId, int productId)
    {
        return await _dbSet.AnyAsync(r =>
            r.UserId == userId
            && r.ProductId == productId
            && r.ReviewType == ReviewType.Product);
    }

    public async Task<bool> UserHasReviewedAppointmentAsync(int userId, int appointmentId)
    {
        return await _dbSet.AnyAsync(r =>
            r.UserId == userId
            && r.AppointmentId == appointmentId
            && r.ReviewType == ReviewType.Appointment);
    }
}
