using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Notifications.MarkAsRead;

[AuthorizeRole("Admin")]
public class MarkNotificationAsReadCommand : IRequest<Unit>
{
    public int Id { get; set; }
}
