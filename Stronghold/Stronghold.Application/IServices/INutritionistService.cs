using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IServices
{
    public interface INutritionistService : IService<Nutritionist, NutritionistResponse, CreateNutritionistRequest, UpdateNutritionistRequest, NutritionistQueryFilter, int>
    {
        Task<AppointmentResponse> BookAppointmentAsync(int userId, int nutritionistId, DateTime date);
        Task<IEnumerable<int>> GetAvailableHoursAsync(int nutritionistId, DateTime date);
    }
}
