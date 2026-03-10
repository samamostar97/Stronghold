using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Users.DeleteUser;

[AuthorizeRole("Admin")]
public class DeleteUserCommand : IRequest<Unit>
{
    public int Id { get; set; }
}
