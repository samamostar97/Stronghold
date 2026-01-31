using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.UserProgressDTO;
using Stronghold.Application.IServices;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class UserProgressService : IUserProgressService
{
    private readonly StrongholdDbContext _context;

    private const int XP_PER_HOUR = 150;
    private const int XP_DECAY_PER_MISSED_DAY = 100;
    private const int XP_PER_LEVEL = 2500;
    private const int MAX_LEVEL = 10;
    private const int DECAY_PERIOD_DAYS = 30;

    private static readonly string[] DayNamesBosnian = { "Ned", "Pon", "Uto", "Sri", "Cet", "Pet", "Sub" };

    public UserProgressService(StrongholdDbContext context)
    {
        _context = context;
    }

    public async Task<UserProgressDTO> GetUserProgressAsync(int userId)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Id == userId)
            ?? throw new KeyNotFoundException("Korisnik nije pronađen");

        var allVisits = await _context.GymVisits
            .Where(v => v.UserId == userId && v.CheckOutTime != null)
            .ToListAsync();

        var totalMinutes = allVisits
            .Where(v => v.Duration.HasValue)
            .Sum(v => (int)v.Duration!.Value.TotalMinutes);

        var totalXPFromVisits = (int)(totalMinutes / 60.0 * XP_PER_HOUR);

        var thirtyDaysAgo = DateTime.UtcNow.Date.AddDays(-DECAY_PERIOD_DAYS);
        var visitDatesLast30Days = allVisits
            .Where(v => v.CheckInTime.Date >= thirtyDaysAgo)
            .Select(v => v.CheckInTime.Date)
            .Distinct()
            .ToHashSet();

        var missedDays = 0;
        for (var date = thirtyDaysAgo; date < DateTime.UtcNow.Date; date = date.AddDays(1))
        {
            if (!visitDatesLast30Days.Contains(date))
            {
                missedDays++;
            }
        }

        var xpDecay = missedDays * XP_DECAY_PER_MISSED_DAY;
        var currentXP = Math.Max(0, totalXPFromVisits - xpDecay);

        var level = Math.Min(MAX_LEVEL, (currentXP / XP_PER_LEVEL) + 1);
        var xpProgress = currentXP % XP_PER_LEVEL;
        var progressPercentage = level >= MAX_LEVEL ? 100.0 : (xpProgress / (double)XP_PER_LEVEL) * 100;

        var sevenDaysAgo = DateTime.UtcNow.Date.AddDays(-6);
        var weeklyVisits = new List<WeeklyVisitDTO>();
        var totalMinutesThisWeek = 0;

        for (var date = sevenDaysAgo; date <= DateTime.UtcNow.Date; date = date.AddDays(1))
        {
            var dayVisits = allVisits
                .Where(v => v.CheckInTime.Date == date && v.Duration.HasValue)
                .Sum(v => (int)v.Duration!.Value.TotalMinutes);

            totalMinutesThisWeek += dayVisits;

            weeklyVisits.Add(new WeeklyVisitDTO
            {
                Date = date,
                Minutes = dayVisits,
                DayName = DayNamesBosnian[(int)date.DayOfWeek]
            });
        }

        return new UserProgressDTO
        {
            UserId = userId,
            FullName = $"{user.FirstName} {user.LastName}",
            Level = level,
            CurrentXP = currentXP,
            XPForNextLevel = XP_PER_LEVEL,
            XPProgress = xpProgress,
            ProgressPercentage = Math.Round(progressPercentage, 1),
            TotalGymMinutesThisWeek = totalMinutesThisWeek,
            WeeklyVisits = weeklyVisits
        };
    }

    public async Task<List<LeaderboardEntryDTO>> GetLeaderboardAsync(int top = 5)
    {
        var entries = await GetAllUserProgressAsync();
        return entries
            .OrderByDescending(e => e.Level)
            .ThenByDescending(e => e.CurrentXP)
            .Take(top)
            .Select((e, index) => new LeaderboardEntryDTO
            {
                Rank = index + 1,
                UserId = e.UserId,
                FullName = e.FullName,
                ProfileImageUrl = e.ProfileImageUrl,
                Level = e.Level,
                CurrentXP = e.CurrentXP
            })
            .ToList();
    }

    public async Task<List<LeaderboardEntryDTO>> GetFullLeaderboardAsync()
    {
        var entries = await GetAllUserProgressAsync();
        return entries
            .OrderByDescending(e => e.Level)
            .ThenByDescending(e => e.CurrentXP)
            .Select((e, index) => new LeaderboardEntryDTO
            {
                Rank = index + 1,
                UserId = e.UserId,
                FullName = e.FullName,
                ProfileImageUrl = e.ProfileImageUrl,
                Level = e.Level,
                CurrentXP = e.CurrentXP
            })
            .ToList();
    }

    private async Task<List<UserProgressEntry>> GetAllUserProgressAsync()
    {
        var users = await _context.Users
            .Where(u => u.Role == Role.GymMember)
            .Select(u => new { u.Id, u.FirstName, u.LastName, u.ProfileImageUrl })
            .ToListAsync();

        var allVisits = await _context.GymVisits
            .Where(v => v.CheckOutTime != null)
            .Select(v => new { v.UserId, v.CheckInTime, Duration = v.CheckOutTime!.Value - v.CheckInTime })
            .ToListAsync();

        var thirtyDaysAgo = DateTime.UtcNow.Date.AddDays(-DECAY_PERIOD_DAYS);

        var entries = new List<UserProgressEntry>();

        foreach (var user in users)
        {
            var userVisits = allVisits.Where(v => v.UserId == user.Id).ToList();

            var totalMinutes = userVisits.Sum(v => (int)v.Duration.TotalMinutes);
            var totalXPFromVisits = (int)(totalMinutes / 60.0 * XP_PER_HOUR);

            var visitDatesLast30Days = userVisits
                .Where(v => v.CheckInTime.Date >= thirtyDaysAgo)
                .Select(v => v.CheckInTime.Date)
                .Distinct()
                .ToHashSet();

            var missedDays = 0;
            for (var date = thirtyDaysAgo; date < DateTime.UtcNow.Date; date = date.AddDays(1))
            {
                if (!visitDatesLast30Days.Contains(date))
                {
                    missedDays++;
                }
            }

            var xpDecay = missedDays * XP_DECAY_PER_MISSED_DAY;
            var currentXP = Math.Max(0, totalXPFromVisits - xpDecay);
            var level = Math.Min(MAX_LEVEL, (currentXP / XP_PER_LEVEL) + 1);

            entries.Add(new UserProgressEntry
            {
                UserId = user.Id,
                FullName = $"{user.FirstName} {user.LastName}",
                ProfileImageUrl = user.ProfileImageUrl,
                Level = level,
                CurrentXP = currentXP
            });
        }

        return entries;
    }

    private class UserProgressEntry
    {
        public int UserId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string? ProfileImageUrl { get; set; }
        public int Level { get; set; }
        public int CurrentXP { get; set; }
    }
}
