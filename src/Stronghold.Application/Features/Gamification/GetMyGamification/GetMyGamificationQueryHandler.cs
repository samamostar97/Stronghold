using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Gamification.GetMyGamification;

public class GetMyGamificationQueryHandler : IRequestHandler<GetMyGamificationQuery, GamificationResponse>
{
    private readonly IUserRepository _userRepository;
    private readonly ILevelRepository _levelRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetMyGamificationQueryHandler(
        IUserRepository userRepository,
        ILevelRepository levelRepository,
        ICurrentUserService currentUserService)
    {
        _userRepository = userRepository;
        _levelRepository = levelRepository;
        _currentUserService = currentUserService;
    }

    public async Task<GamificationResponse> Handle(GetMyGamificationQuery request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(_currentUserService.UserId)
            ?? throw new NotFoundException("Korisnik", _currentUserService.UserId);

        var levels = await _levelRepository.GetAllOrderedAsync();
        var currentLevel = levels.FirstOrDefault(l => user.XP >= l.MinXP && user.XP <= l.MaxXP);
        var nextLevel = currentLevel != null
            ? levels.FirstOrDefault(l => l.MinXP > currentLevel.MaxXP)
            : null;

        // Calculate rank (number of users with higher XP + 1)
        var rank = await _userRepository.Query()
            .Where(u => u.Role == Role.User && u.XP > user.XP)
            .CountAsync(cancellationToken) + 1;

        return new GamificationResponse
        {
            Level = user.Level,
            LevelName = currentLevel?.Name ?? string.Empty,
            XP = user.XP,
            XpToNextLevel = nextLevel != null ? nextLevel.MinXP - user.XP : 0,
            Rank = rank,
            TotalGymMinutes = user.TotalGymMinutes,
            BadgeImageUrl = currentLevel?.BadgeImageUrl
        };
    }
}
