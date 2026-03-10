using Stronghold.Domain.Entities;

namespace Stronghold.Application.Interfaces;

public interface IAppointmentRepository : IRepository<Appointment>
{
    Task<Appointment?> GetByIdWithDetailsAsync(int id);
    Task<bool> HasConflictAsync(int staffId, DateTime scheduledAt, int? excludeId = null);
}
