using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;

namespace Stronghold.Application.IServices
{
    public interface IAppointmentService
    {
        Task<PagedResult<AppointmentResponse>> GetAppointmentsByUserIdAsync(int userId, AppointmentQueryFilter filter);
        Task CancelAppointmentAsync(int userId, int appointmentId);
        Task<PagedResult<AdminAppointmentResponse>> GetAllAppointmentsAsync(AppointmentQueryFilter filter);
    }
}
