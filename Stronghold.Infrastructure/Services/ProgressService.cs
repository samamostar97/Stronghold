using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Progress;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class ProgressService : IProgressService
{
    private readonly StrongholdDbContext _db;
    private readonly ICurrentUserService _currentUser;

    public ProgressService(StrongholdDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<PagedResult<LeaderboardEntryResponse>> GetLeaderboardAsync(BaseSearchObject search)
    {
        var now = DateTime.UtcNow;
        var windowStart = now.AddDays(-XpRules.DecayWindowDays);

        // agregacija na nivou baze (jedan upit), XP formula i rang u memoriji nad malim skupom agregata
        var aggregates = await _db.Users.AsNoTracking()
            .Where(u => u.Role == UserRole.GymMember)
            .Select(u => new
            {
                u.Id,
                FullName = u.FirstName + " " + u.LastName,
                u.Username,
                TotalMinutes = u.GymVisits
                    .Where(v => v.CheckOutAt != null)
                    .Sum(v => (int?)EF.Functions.DateDiffMinute(v.CheckInAt, v.CheckOutAt!.Value)) ?? 0,
                ActiveDays = u.GymVisits
                    .Where(v => v.CheckInAt >= windowStart)
                    .Select(v => v.CheckInAt.Date)
                    .Distinct()
                    .Count(),
                VisitCount = u.GymVisits.Count(v => v.CheckOutAt != null)
            })
            .ToListAsync();

        var ranked = aggregates
            .Select(a => new LeaderboardEntryResponse
            {
                UserId = a.Id,
                FullName = a.FullName,
                Username = a.Username,
                Xp = XpRules.ComputeXp(a.TotalMinutes, a.ActiveDays),
                Level = XpRules.ComputeLevel(XpRules.ComputeXp(a.TotalMinutes, a.ActiveDays)),
                VisitCount = a.VisitCount,
                TotalHours = a.TotalMinutes / 60
            })
            .OrderByDescending(e => e.Xp)
            .ThenByDescending(e => e.VisitCount)
            .ToList();

        for (var i = 0; i < ranked.Count; i++)
        {
            ranked[i].Rank = i + 1;
        }

        return new PagedResult<LeaderboardEntryResponse>
        {
            Items = ranked.Skip((search.Page - 1) * search.PageSize).Take(search.PageSize).ToList(),
            TotalCount = ranked.Count
        };
    }

    public async Task<ProgressResponse> GetMyProgressAsync()
    {
        var now = DateTime.UtcNow;
        var windowStart = now.AddDays(-XpRules.DecayWindowDays);
        var eightWeeksAgo = now.Date.AddDays(-7 * 8);
        var userId = _currentUser.UserId;

        // ukljucuje i posjetu u toku: XP nosi samo zavrseno vrijeme,
        // ali dan posjete se racuna kao aktivan (isto kao na leaderboardu)
        var visits = await _db.GymVisits.AsNoTracking()
            .Where(v => v.UserId == userId)
            .Select(v => new
            {
                v.CheckInAt,
                Minutes = v.CheckOutAt != null
                    ? EF.Functions.DateDiffMinute(v.CheckInAt, v.CheckOutAt.Value)
                    : 0
            })
            .ToListAsync();

        var totalMinutes = visits.Sum(v => v.Minutes);
        var activeDays = visits
            .Where(v => v.CheckInAt >= windowStart)
            .Select(v => v.CheckInAt.Date)
            .Distinct()
            .Count();
        var xp = XpRules.ComputeXp(totalMinutes, activeDays);

        var visitsByWeekday = new int[7];
        foreach (var visit in visits)
        {
            // DayOfWeek: Sunday=0 -> pretvaramo u indeks gdje je ponedjeljak 0
            var index = ((int)visit.CheckInAt.DayOfWeek + 6) % 7;
            visitsByWeekday[index]++;
        }

        var weekly = new List<WeeklyVisits>();
        for (var week = 0; week < 8; week++)
        {
            var start = eightWeeksAgo.AddDays(week * 7);
            var end = start.AddDays(7);
            weekly.Add(new WeeklyVisits
            {
                WeekStart = start,
                Count = visits.Count(v => v.CheckInAt >= start && v.CheckInAt < end)
            });
        }

        return new ProgressResponse
        {
            Xp = xp,
            Level = XpRules.ComputeLevel(xp),
            LevelProgressPercent = XpRules.ComputeLevelProgressPercent(xp),
            TotalVisits = visits.Count,
            MonthlyMinutes = visits.Where(v => v.CheckInAt >= windowStart).Sum(v => v.Minutes),
            VisitsByWeekday = visitsByWeekday,
            WeeklyVisits = weekly
        };
    }
}
