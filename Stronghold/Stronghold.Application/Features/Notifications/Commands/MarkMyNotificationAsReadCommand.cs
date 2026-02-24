using FluentValidation;
using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Notifications.Commands;

public class MarkMyNotificationAsReadCommand : IRequest<Unit>
{
    public int Id { get; set; }
}

public class MarkMyNotificationAsReadCommandHandler : IRequestHandler<MarkMyNotificationAsReadCommand, Unit>
{
    private readonly INotificationRepository _notificationRepository;
    private readonly ICurrentUserService _currentUserService;

    public MarkMyNotificationAsReadCommandHandler(
        INotificationRepository notificationRepository,
        ICurrentUserService currentUserService)
    {
        _notificationRepository = notificationRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(MarkMyNotificationAsReadCommand request, CancellationToken cancellationToken)
    {
        var userId = EnsureAuthenticatedAccess();

        var notification = await _notificationRepository.GetUserByIdAsync(userId, request.Id, cancellationToken);
        if (notification is null || notification.IsRead)
        {
            return Unit.Value;
        }

        await _notificationRepository.MarkAsReadAsync(notification, cancellationToken);
        return Unit.Value;
    }

    private int EnsureAuthenticatedAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        return _currentUserService.UserId.Value;
    }
}

public class MarkMyNotificationAsReadCommandValidator : AbstractValidator<MarkMyNotificationAsReadCommand>
{
    public MarkMyNotificationAsReadCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0);
    }
}
