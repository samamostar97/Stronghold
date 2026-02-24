using Stronghold.Application.Common;
using Stronghold.Application.Features.Appointments.DTOs;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IRepositories;

public interface IAppointmentRepository
{
    Task<PagedResult<Appointment>> GetUserUpcomingPagedAsync(
        int userId,
        AppointmentFilter filter,
        CancellationToken cancellationToken = default);
    Task<PagedResult<Appointment>> GetAdminPagedAsync(
        AppointmentFilter filter,
        CancellationToken cancellationToken = default);
    Task<Appointment?> GetByUserAndIdAsync(
        int userId,
        int appointmentId,
        CancellationToken cancellationToken = default);
    Task<Appointment?> GetByIdAsync(int appointmentId, CancellationToken cancellationToken = default);
    Task<bool> UserHasAppointmentOnDateAsync(
        int userId,
        DateTime date,
        int? excludeAppointmentId = null,
        CancellationToken cancellationToken = default);
    Task<bool> IsTrainerBusyInSlotAsync(
        int trainerId,
        DateTime slotStart,
        DateTime slotEnd,
        int? excludeAppointmentId = null,
        CancellationToken cancellationToken = default);
    Task<bool> IsNutritionistBusyInSlotAsync(
        int nutritionistId,
        DateTime slotStart,
        DateTime slotEnd,
        int? excludeAppointmentId = null,
        CancellationToken cancellationToken = default);
    Task<bool> TrainerExistsAsync(int trainerId, CancellationToken cancellationToken = default);
    Task<bool> NutritionistExistsAsync(int nutritionistId, CancellationToken cancellationToken = default);
    Task<bool> UserExistsAsync(int userId, CancellationToken cancellationToken = default);
    Task<bool> TryAddAsync(Appointment appointment, CancellationToken cancellationToken = default);
    Task<bool> TryUpdateAsync(Appointment appointment, CancellationToken cancellationToken = default);
    Task DeleteAsync(Appointment appointment, CancellationToken cancellationToken = default);
}
