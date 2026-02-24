using Stronghold.Application.Common;
using Stronghold.Application.Features.Nutritionists.DTOs;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IRepositories;

public interface INutritionistRepository
{
    Task<PagedResult<Nutritionist>> GetPagedAsync(NutritionistFilter filter, CancellationToken cancellationToken = default);
    Task<Nutritionist?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<bool> ExistsByEmailAsync(string email, int? excludeId = null, CancellationToken cancellationToken = default);
    Task<bool> ExistsByPhoneAsync(string phoneNumber, int? excludeId = null, CancellationToken cancellationToken = default);
    Task<bool> HasAppointmentsAsync(int nutritionistId, CancellationToken cancellationToken = default);
    Task<bool> UserHasAppointmentOnDateAsync(int userId, DateTime date, CancellationToken cancellationToken = default);
    Task<bool> IsBusyInSlotAsync(int nutritionistId, DateTime slotStart, DateTime slotEnd, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<DateTime>> GetAppointmentTimesForDateAsync(
        int nutritionistId,
        DateTime date,
        CancellationToken cancellationToken = default);
    Task AddAppointmentAsync(Appointment appointment, CancellationToken cancellationToken = default);
    Task AddAsync(Nutritionist entity, CancellationToken cancellationToken = default);
    Task UpdateAsync(Nutritionist entity, CancellationToken cancellationToken = default);
    Task DeleteAsync(Nutritionist entity, CancellationToken cancellationToken = default);
}
