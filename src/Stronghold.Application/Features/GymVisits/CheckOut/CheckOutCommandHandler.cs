using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;
using Stronghold.Application.Common;
using Stronghold.Messaging;

namespace Stronghold.Application.Features.GymVisits.CheckOut;

public class CheckOutCommandHandler : IRequestHandler<CheckOutCommand, GymVisitResponse>
{
    private readonly IGymVisitRepository _gymVisitRepository;
    private readonly IUserRepository _userRepository;
    private readonly ILevelRepository _levelRepository;
    private readonly IMessagePublisher _messagePublisher;

    public CheckOutCommandHandler(
        IGymVisitRepository gymVisitRepository,
        IUserRepository userRepository,
        ILevelRepository levelRepository,
        IMessagePublisher messagePublisher)
    {
        _gymVisitRepository = gymVisitRepository;
        _userRepository = userRepository;
        _levelRepository = levelRepository;
        _messagePublisher = messagePublisher;
    }

    public async Task<GymVisitResponse> Handle(CheckOutCommand request, CancellationToken cancellationToken)
    {
        var visit = await _gymVisitRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Posjeta teretani", request.Id);

        if (visit.CheckOutAt != null)
            throw new InvalidOperationException("Korisnik je već odjavljen iz teretane.");

        var now = DateTime.UtcNow;
        visit.CheckOutAt = now;
        visit.DurationMinutes = (int)(now - visit.CheckInAt).TotalMinutes;

        var user = await _userRepository.GetByIdAsync(visit.UserId)
            ?? throw new NotFoundException("Korisnik", visit.UserId);

        // XP formula: 1 XP per minute
        var xpEarned = visit.DurationMinutes.Value;
        user.XP += xpEarned;
        user.TotalGymMinutes += visit.DurationMinutes.Value;

        // Level-up check
        var oldLevel = user.Level;
        var newLevel = await _levelRepository.GetByXpAsync(user.XP);
        if (newLevel != null && user.Level != newLevel.Id)
        {
            user.Level = newLevel.Id;
        }

        _userRepository.Update(user);
        _gymVisitRepository.Update(visit);
        await _gymVisitRepository.SaveChangesAsync();

        if (newLevel != null && user.Level != oldLevel)
        {
            await _messagePublisher.PublishAsync(QueueNames.EmailNotifications, EmailTemplates.LevelUp(user.Email, user.FirstName, newLevel.Name));
        }

        visit.User = user;

        return GymVisitMappings.ToResponse(visit);
    }
}
