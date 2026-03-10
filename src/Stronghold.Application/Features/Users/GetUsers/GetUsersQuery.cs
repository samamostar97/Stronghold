using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Users.GetUsers;

[AuthorizeRole("Admin")]
public class GetUsersQuery : BaseQueryFilter, IRequest<PagedResult<UserResponse>>
{
}
