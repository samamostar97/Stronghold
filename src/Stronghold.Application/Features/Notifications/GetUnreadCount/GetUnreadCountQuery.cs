using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Notifications.GetUnreadCount;

[AuthorizeRole("Admin")]
public class GetUnreadCountQuery : IRequest<int>
{
}
