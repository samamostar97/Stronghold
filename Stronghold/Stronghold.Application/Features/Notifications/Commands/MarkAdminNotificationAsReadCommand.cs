using FluentValidation;
using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Notifications.Commands;

public class MarkAdminNotificationAsReadCommand : IRequest<Unit>, IAuthorizeAdminRequest
{
    public int Id { get; set; }
}

public class MarkAdminNotificationAsReadCommandHandler : IRequestHandler<MarkAdminNotificationAsReadCommand, Unit>
{
    private readonly INotificationRepository _notificationRepository;

    public MarkAdminNotificationAsReadCommandHandler(
        INotificationRepository notificationRepository)
    {
        _notificationRepository = notificationRepository;
    }

public async Task<Unit> Handle(MarkAdminNotificationAsReadCommand request, CancellationToken cancellationToken)
    {
        var notification = await _notificationRepository.GetAdminByIdAsync(request.Id, cancellationToken);
        if (notification is null || notification.IsRead)
        {
            return Unit.Value;
        }

        await _notificationRepository.MarkAsReadAsync(notification, cancellationToken);
        return Unit.Value;
    }
    }

public class MarkAdminNotificationAsReadCommandValidator : AbstractValidator<MarkAdminNotificationAsReadCommand>
{
    public MarkAdminNotificationAsReadCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }