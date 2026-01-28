using Stronghold.Application.DTOs.AdminNutritionistDTO;
using Stronghold.Application.DTOs.AdminTrainerDTO;
using Stronghold.Application.DTOs.UserDTOs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IServices
{
    public interface IUserAppointmentService
    {
        Task<IEnumerable<UserAppointmentDTO>> GetAppointmentList(int userId);
        Task<UserAppointmentDTO> MakeTrainingAppointmentAsync(int userId, int trainerId, DateTime date);
        Task CancelAppointmentAsync(int userId, int appointmentId);

        Task<UserAppointmentDTO> MakeNutritionistAppointmentAsync(int userId, int nutritionistId, DateTime date);
        Task<IEnumerable<TrainerDTO>> GetTrainerListAsync();
        Task<IEnumerable<NutritionistDTO>> GetNutritionistListAsync();
    }
}
