using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Notifications.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Notifications.Queries;

public class GetMyNotificationsQuery : IRequest<IReadOnlyList<NotificationResponse>>
{
    public int Count { get; set; } = 20;
}

public class GetMyNotificationsQueryHandler : IRequestHandler<GetMyNotificationsQuery, IReadOnlyList<NotificationResponse>>
{
    private readonly INotificationRepository _notificationRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetMyNotificationsQueryHandler(
        INotificationRepository notificationRepository,
        ICurrentUserService currentUserService)
    {
        _notificationRepository = notificationRepository;
        _currentUserService = currentUserService;
    }

    public async Task<IReadOnlyList<NotificationResponse>> Handle(GetMyNotificationsQuery request, CancellationToken cancellationToken)
    {
        var userId = EnsureAuthenticatedAccess();

        var notifications = await _notificationRepository.GetRecentForUserAsync(userId, request.Count, cancellationToken);

        return notifications.Select(MapToResponse).ToList();
    }

    private int EnsureAuthenticatedAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        return _currentUserService.UserId.Value;
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

public class GetMyNotificationsQueryValidator : AbstractValidator<GetMyNotificationsQuery>
{
    public GetMyNotificationsQueryValidator()
    {
        RuleFor(x => x.Count)
            .InclusiveBetween(1, 100).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");
    }
}

