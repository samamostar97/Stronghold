using Stronghold.Application.Common;
using Stronghold.Application.Features.Appointments.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Tests.TestDoubles;

internal sealed class FakeAppointmentRepository : IAppointmentRepository
{
    public bool UserExistsResult { get; set; } = true;
    public bool TrainerExistsResult { get; set; } = true;
    public bool NutritionistExistsResult { get; set; } = true;
    public bool UserHasAppointmentOnDateResult { get; set; }
    public bool IsTrainerBusyInSlotResult { get; set; }
    public bool IsNutritionistBusyInSlotResult { get; set; }
    public bool TryAddResult { get; set; } = true;
    public bool TryUpdateResult { get; set; } = true;
    public int CreatedAppointmentId { get; set; } = 777;

    public Appointment? AppointmentByUserAndIdResult { get; set; }
    public Appointment? AppointmentByIdResult { get; set; }
    public Appointment? AddedAppointment { get; private set; }
    public Appointment? UpdatedAppointment { get; private set; }
    public Appointment? DeletedAppointment { get; private set; }
    public bool DeleteCalled { get; private set; }

    public Task<PagedResult<Appointment>> GetUserUpcomingPagedAsync(
        int userId,
        AppointmentFilter filter,
        CancellationToken cancellationToken = default)
    {
        return Task.FromResult(new PagedResult<Appointment>
        {
            Items = new List<Appointment>(),
            TotalCount = 0,
            PageNumber = filter.PageNumber
        });
    }

    public Task<PagedResult<Appointment>> GetAdminPagedAsync(
        AppointmentFilter filter,
        CancellationToken cancellationToken = default)
    {
        return Task.FromResult(new PagedResult<Appointment>
        {
            Items = new List<Appointment>(),
            TotalCount = 0,
            PageNumber = filter.PageNumber
        });
    }

    public Task<Appointment?> GetByUserAndIdAsync(
        int userId,
        int appointmentId,
        CancellationToken cancellationToken = default)
    {
        return Task.FromResult(AppointmentByUserAndIdResult);
    }

    public Task<Appointment?> GetByIdAsync(int appointmentId, CancellationToken cancellationToken = default)
    {
        return Task.FromResult(AppointmentByIdResult);
    }

    public Task<bool> UserHasAppointmentOnDateAsync(
        int userId,
        DateTime date,
        int? excludeAppointmentId = null,
        CancellationToken cancellationToken = default)
    {
        return Task.FromResult(UserHasAppointmentOnDateResult);
    }

    public Task<bool> IsTrainerBusyInSlotAsync(
        int trainerId,
        DateTime slotStart,
        DateTime slotEnd,
        int? excludeAppointmentId = null,
        CancellationToken cancellationToken = default)
    {
        return Task.FromResult(IsTrainerBusyInSlotResult);
    }

    public Task<bool> IsNutritionistBusyInSlotAsync(
        int nutritionistId,
        DateTime slotStart,
        DateTime slotEnd,
        int? excludeAppointmentId = null,
        CancellationToken cancellationToken = default)
    {
        return Task.FromResult(IsNutritionistBusyInSlotResult);
    }

    public Task<bool> TrainerExistsAsync(int trainerId, CancellationToken cancellationToken = default)
    {
        return Task.FromResult(TrainerExistsResult);
    }

    public Task<bool> NutritionistExistsAsync(int nutritionistId, CancellationToken cancellationToken = default)
    {
        return Task.FromResult(NutritionistExistsResult);
    }

    public Task<bool> UserExistsAsync(int userId, CancellationToken cancellationToken = default)
    {
        return Task.FromResult(UserExistsResult);
    }

    public Task<bool> TryAddAsync(Appointment appointment, CancellationToken cancellationToken = default)
    {
        AddedAppointment = appointment;
        if (TryAddResult)
        {
            appointment.Id = CreatedAppointmentId;
        }

        return Task.FromResult(TryAddResult);
    }

    public Task<bool> TryUpdateAsync(Appointment appointment, CancellationToken cancellationToken = default)
    {
        UpdatedAppointment = appointment;
        return Task.FromResult(TryUpdateResult);
    }

    public Task DeleteAsync(Appointment appointment, CancellationToken cancellationToken = default)
    {
        DeleteCalled = true;
        DeletedAppointment = appointment;
        appointment.IsDeleted = true;
        return Task.CompletedTask;
    }
}
