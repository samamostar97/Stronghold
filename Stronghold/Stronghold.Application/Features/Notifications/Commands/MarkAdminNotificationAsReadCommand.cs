using FluentValidation;
using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Notifications.Commands;

public class MarkAdminNotificationAsReadCommand : IRequest<Unit>
{
    public int Id { get; set; }
}

public class MarkAdminNotificationAsReadCommandHandler : IRequestHandler<MarkAdminNotificationAsReadCommand, Unit>
{
    private readonly INotificationRepository _notificationRepository;
    private readonly ICurrentUserService _currentUserService;

    public MarkAdminNotificationAsReadCommandHandler(
        INotificationRepository notificationRepository,
        ICurrentUserService currentUserService)
    {
        _notificationRepository = notificationRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(MarkAdminNotificationAsReadCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var notification = await _notificationRepository.GetAdminByIdAsync(request.Id, cancellationToken);
        if (notification is null || notification.IsRead)
        {
            return Unit.Value;
        }

        await _notificationRepository.MarkAsReadAsync(notification, cancellationToken);
        return Unit.Value;
    }

    private void EnsureAdminAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("Admin"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }
    }
}

public class MarkAdminNotificationAsReadCommandValidator : AbstractValidator<MarkAdminNotificationAsReadCommand>
{
    public MarkAdminNotificationAsReadCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0);
    }
}
