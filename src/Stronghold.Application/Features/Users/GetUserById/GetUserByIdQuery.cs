using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Users.GetUserById;

[AuthorizeRole("Admin")]
public class GetUserByIdQuery : IRequest<UserResponse>
{
    public int Id { get; set; }
}
