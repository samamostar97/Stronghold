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
    [Route("api/nutritionist")]
    public class NutritionistController : BaseController<Nutritionist, NutritionistResponse, CreateNutritionistRequest, UpdateNutritionistRequest, NutritionistQueryFilter, int>
    {
        private readonly INutritionistService _nutritionistService;

        public NutritionistController(INutritionistService service) : base(service)
        {
            _nutritionistService = service;
        }

        // User endpoint - override with GymMember role
        [Authorize(Roles ="Admin,GymMember")] 
        [HttpGet("GetAllPaged")]
         public override Task<ActionResult<PagedResult<NutritionistResponse>>> GetAllPagedAsync([FromQuery] NutritionistQueryFilter filter)
            => base.GetAllPagedAsync(filter);

        // User endpoint: Book appointment with nutritionist
        [HttpPost("{id}/appointments")]
        [Authorize(Roles = "GymMember")]
        public async Task<ActionResult<AppointmentResponse>> BookAppointment(int id, [FromBody] BookAppointmentRequest request)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var result = await _nutritionistService.BookAppointmentAsync(userId.Value, id, request.Date);
            return Ok(result);
        }

        // User endpoint: Get available hours for a nutritionist on a specific date
        [HttpGet("{id}/available-hours")]
        [Authorize(Roles = "GymMember")]
        public async Task<ActionResult<IEnumerable<int>>> GetAvailableHours(int id, [FromQuery] DateTime date)
        {
            var result = await _nutritionistService.GetAvailableHoursAsync(id, date);
            return Ok(result);
        }
    }
}
