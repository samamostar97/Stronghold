using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/trainer")]
    public class TrainerController : BaseController<Trainer, TrainerResponse, CreateTrainerRequest, UpdateTrainerRequest, TrainerQueryFilter, int>
    {
        private readonly ITrainerService _trainerService;

        public TrainerController(ITrainerService service) : base(service)
        {
            _trainerService = service;
        }

        // User endpoint - override with GymMember role
        [Authorize(Roles = "Admin,GymMember")]
        [HttpGet("GetAllPaged")]

        public override Task<ActionResult<PagedResult<TrainerResponse>>> GetAllPagedAsync([FromQuery] TrainerQueryFilter filter)
            => base.GetAllPagedAsync(filter);

        // User endpoint: Book appointment with trainer
        [Authorize(Roles = "GymMember")]
        [HttpPost("{id}/appointments")]
        public async Task<ActionResult<AppointmentResponse>> BookAppointment(int id, [FromBody] BookAppointmentRequest request)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var result = await _trainerService.BookAppointmentAsync(userId.Value, id, request.Date);
            return Ok(result);
        }

        // User endpoint: Get available hours for a trainer on a specific date
        [Authorize(Roles = "GymMember")]
        [HttpGet("{id}/available-hours")]
        public async Task<ActionResult<IEnumerable<int>>> GetAvailableHours(int id, [FromQuery] DateTime date)
        {
            var result = await _trainerService.GetAvailableHoursAsync(id, date);
            return Ok(result);
        }
        [Authorize(Roles = "Admin,GymMember")]
        [HttpGet("{id}")]
        public override Task<ActionResult<TrainerResponse>> GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin,GymMember")]
        [HttpGet("GetAll")]
        public override Task<ActionResult<IEnumerable<TrainerResponse>>> GetAllAsync([FromQuery] TrainerQueryFilter filter)
        {
            return base.GetAllAsync(filter);
        }

        [Authorize(Roles = "Admin")]
        [HttpPost]
        public override Task<ActionResult<TrainerResponse>> Create([FromBody] CreateTrainerRequest dto)
        {
            return base.Create(dto);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}")]
        public override Task<ActionResult<TrainerResponse>> Update(int id, [FromBody] UpdateTrainerRequest dto)
        {
            return base.Update(id, dto);
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public override Task<IActionResult> Delete(int id)
        {
            return base.Delete(id);
        }
    }
}
