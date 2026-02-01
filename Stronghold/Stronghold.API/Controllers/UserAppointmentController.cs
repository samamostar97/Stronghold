using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.AdminNutritionistDTO;
using Stronghold.Application.DTOs.AdminTrainerDTO;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/user/appointment")]
    [Authorize]
    public class UserAppointmentController:UserControllerBase
    {
        private readonly IUserAppointmentService _userAppointmentService;
        public UserAppointmentController(IUserAppointmentService userAppointmentService)
        {
            _userAppointmentService=userAppointmentService;
        }
        [HttpGet]
        public async Task<ActionResult<IEnumerable<UserAppointmentDTO>>> GetAppointmentsAsync()
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();
            var result = await _userAppointmentService.GetAppointmentList(userId.Value);
            return Ok(result);
        }
        [HttpGet("get-trainer-list")]
        public async Task<ActionResult<IEnumerable<TrainerDTO>>> GetTrainerListAsync()
        {
            var result = await _userAppointmentService.GetTrainerListAsync();
            return Ok(result);
        }

        [HttpGet("get-nutritionist-list")]
        public async Task<ActionResult<IEnumerable<NutritionistDTO>>> GetNutritionistListAsync()
        {
            var result = await _userAppointmentService.GetNutritionistListAsync();
            return Ok(result);
        }
        [HttpPost("make-training-appointment")]
        public async Task<ActionResult<UserAppointmentDTO>> MakeTrainingAppointmentAsync([FromBody] MakeAppointmentRequestDTO request)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();
            var result = await _userAppointmentService.MakeTrainingAppointmentAsync(userId.Value, request.StaffId, request.AppointmentDate);
            return Ok(result);
        }

        [HttpPost("make-nutritionist-appointment")]
        public async Task<ActionResult<UserAppointmentDTO>> MakeNutritionistAppointmentAsync([FromBody] MakeAppointmentRequestDTO request)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();
            var result = await _userAppointmentService.MakeNutritionistAppointmentAsync(userId.Value, request.StaffId, request.AppointmentDate);
            return Ok(result);
        }
        [HttpDelete("{id}")]
        public async Task<ActionResult> CancelAppointmentAsync(int id)
        {
            var userId = GetCurrentUserId();
            if(userId == null)
                return Unauthorized();
            await _userAppointmentService.CancelAppointmentAsync(userId.Value, id);
            return NoContent();
        }

        [HttpGet("available-hours")]
        public async Task<ActionResult<IEnumerable<int>>> GetAvailableHoursAsync([FromQuery] int staffId, [FromQuery] DateTime date, [FromQuery] bool isTrainer)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();
            var result = await _userAppointmentService.GetAvailableHoursAsync(staffId, date, isTrainer);
            return Ok(result);
        }
    }
}
