using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Notifications.GetNotifications;

[AuthorizeRole("Admin")]
public class GetNotificationsQuery : BaseQueryFilter, IRequest<PagedResult<NotificationResponse>>
{
}
