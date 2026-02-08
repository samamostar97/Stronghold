using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IServices
{
    public interface ITrainerService : IService<Trainer, TrainerResponse, CreateTrainerRequest, UpdateTrainerRequest, TrainerQueryFilter, int>
    {
        Task<AppointmentResponse> BookAppointmentAsync(int userId, int trainerId, DateTime date);
        Task<IEnumerable<int>> GetAvailableHoursAsync(int trainerId, DateTime date);
    }
}
