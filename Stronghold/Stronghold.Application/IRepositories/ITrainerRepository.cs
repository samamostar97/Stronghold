using Stronghold.Application.Common;
using Stronghold.Application.Features.Trainers.DTOs;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IRepositories;

public interface ITrainerRepository
{
    Task<PagedResult<Trainer>> GetPagedAsync(TrainerFilter filter, CancellationToken cancellationToken = default);
    Task<Trainer?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<bool> ExistsByEmailAsync(string email, int? excludeId = null, CancellationToken cancellationToken = default);
    Task<bool> ExistsByPhoneAsync(string phoneNumber, int? excludeId = null, CancellationToken cancellationToken = default);
    Task<bool> HasAppointmentsAsync(int trainerId, CancellationToken cancellationToken = default);
    Task<bool> UserHasAppointmentOnDateAsync(int userId, DateTime date, CancellationToken cancellationToken = default);
    Task<bool> IsBusyInSlotAsync(int trainerId, DateTime slotStart, DateTime slotEnd, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<DateTime>> GetAppointmentTimesForDateAsync(
        int trainerId,
        DateTime date,
        CancellationToken cancellationToken = default);
    Task AddAppointmentAsync(Appointment appointment, CancellationToken cancellationToken = default);
    Task AddAsync(Trainer entity, CancellationToken cancellationToken = default);
    Task UpdateAsync(Trainer entity, CancellationToken cancellationToken = default);
    Task DeleteAsync(Trainer entity, CancellationToken cancellationToken = default);
}
