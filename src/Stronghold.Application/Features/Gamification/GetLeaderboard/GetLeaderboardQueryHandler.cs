using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Gamification.GetLeaderboard;

public class GetLeaderboardQueryHandler : IRequestHandler<GetLeaderboardQuery, PagedResult<LeaderboardResponse>>
{
    private readonly IUserRepository _userRepository;
    private readonly ILevelRepository _levelRepository;

    public GetLeaderboardQueryHandler(IUserRepository userRepository, ILevelRepository levelRepository)
    {
        _userRepository = userRepository;
        _levelRepository = levelRepository;
    }

    public async Task<PagedResult<LeaderboardResponse>> Handle(GetLeaderboardQuery request, CancellationToken cancellationToken)
    {
        var levels = await _levelRepository.GetAllOrderedAsync();

        var query = _userRepository.Query()
            .Where(u => u.Role == Role.User)
            .OrderByDescending(u => u.XP);

        var totalCount = await query.CountAsync(cancellationToken);

        var users = await query
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(cancellationToken);

        var offset = (request.PageNumber - 1) * request.PageSize;
        var items = users.Select((u, index) =>
        {
            var level = levels.FirstOrDefault(l => u.XP >= l.MinXP && u.XP <= l.MaxXP);
            return new LeaderboardResponse
            {
                Rank = offset + index + 1,
                UserId = u.Id,
                FullName = $"{u.FirstName} {u.LastName}",
                Username = u.Username,
                ProfileImageUrl = u.ProfileImageUrl,
                XP = u.XP,
                Level = u.Level,
                LevelName = level?.Name ?? string.Empty,
                TotalGymMinutes = u.TotalGymMinutes
            };
        }).ToList();

        return new PagedResult<LeaderboardResponse>
        {
            Items = items,
            TotalCount = totalCount,
            TotalPages = (int)Math.Ceiling(totalCount / (double)request.PageSize),
            CurrentPage = request.PageNumber,
            PageSize = request.PageSize
        };
    }
}
