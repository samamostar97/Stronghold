using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Notifications.MarkAllAsRead;

[AuthorizeRole("Admin")]
public class MarkAllNotificationsAsReadCommand : IRequest<Unit>
{
}
