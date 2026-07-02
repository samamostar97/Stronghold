using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.Users;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.API.Controllers;

[Route("api/users")]
[Authorize(Roles = Roles.Admin)]
public class UsersController : BaseCrudController<UserResponse, UserSearch, UserInsertRequest, UserUpdateRequest>
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService) : base(userService)
    {
        _userService = userService;
    }

    /// <summary>Slika se servira zasebno - liste ne vracaju base64.</summary>
    [HttpGet("{id}/image")]
    public async Task<IActionResult> GetImage(int id)
    {
        var (data, contentType) = await _userService.GetImageAsync(id);
        return File(data, contentType);
    }
}
