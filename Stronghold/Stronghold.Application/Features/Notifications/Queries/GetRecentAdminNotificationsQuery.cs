using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Notifications.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Notifications.Queries;

public class GetRecentAdminNotificationsQuery : IRequest<IReadOnlyList<NotificationResponse>>
{
    public int Count { get; set; } = 20;
}

public class GetRecentAdminNotificationsQueryHandler : IRequestHandler<GetRecentAdminNotificationsQuery, IReadOnlyList<NotificationResponse>>
{
    private readonly INotificationRepository _notificationRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetRecentAdminNotificationsQueryHandler(
        INotificationRepository notificationRepository,
        ICurrentUserService currentUserService)
    {
        _notificationRepository = notificationRepository;
        _currentUserService = currentUserService;
    }

    public async Task<IReadOnlyList<NotificationResponse>> Handle(
        GetRecentAdminNotificationsQuery request,
        CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var notifications = await _notificationRepository.GetRecentAdminAsync(request.Count, cancellationToken);

        return notifications.Select(MapToResponse).ToList();
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

    private static NotificationResponse MapToResponse(Notification notification)
    {
        return new NotificationResponse
        {
            Id = notification.Id,
            Type = notification.Type,
            Title = notification.Title,
            Message = notification.Message,
            IsRead = notification.IsRead,
            CreatedAt = notification.CreatedAt,
            RelatedEntityId = notification.RelatedEntityId,
            RelatedEntityType = notification.RelatedEntityType
        };
    }
}

public class GetRecentAdminNotificationsQueryValidator : AbstractValidator<GetRecentAdminNotificationsQuery>
{
    public GetRecentAdminNotificationsQueryValidator()
    {
        RuleFor(x => x.Count)
            .InclusiveBetween(1, 100).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");
    }
}

