using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;

namespace Stronghold.API.Controllers;

public abstract class UserControllerBase : ControllerBase
{
    protected int? GetCurrentUserId()
    {
        var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return int.TryParse(claim, out var id) ? id : null;
    }
}
