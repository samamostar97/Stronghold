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
    [Route("api/users")]
    [Authorize(Roles = "Admin")]
    public class UsersController : BaseController<User, UserResponse, CreateUserRequest, UpdateUserRequest, UserQueryFilter, int>
    {
        private readonly IUserManagementService _userService;

        public UsersController(IUserManagementService service) : base(service)
        {
            _userService = service;
        }

        [HttpPost("{id}/image")]
        public async Task<ActionResult<UserResponse>> UploadImage(int id, IFormFile file)
        {
            if (file == null || file.Length == 0)
                return BadRequest("Nije odabrana slika");

            var fileRequest = new FileUploadRequest
            {
                FileStream = file.OpenReadStream(),
                FileName = file.FileName,
                ContentType = file.ContentType,
                FileSize = file.Length
            };

            var result = await _userService.UploadImageAsync(id, fileRequest);
            return Ok(result);
        }

        [HttpDelete("{id}/image")]
        public async Task<IActionResult> DeleteImage(int id)
        {
            await _userService.DeleteImageAsync(id);
            return NoContent();
        }
    }
}
