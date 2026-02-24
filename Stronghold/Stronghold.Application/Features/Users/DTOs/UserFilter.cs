using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Users.DTOs;

public class UserFilter : PaginationRequest
{
    public string? Name { get; set; }
    public string? OrderBy { get; set; }
}
