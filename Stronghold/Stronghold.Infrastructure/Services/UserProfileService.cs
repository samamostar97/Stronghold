using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class UserProfileService : IUserProfileService
{
    private readonly StrongholdDbContext _context;
    private readonly IFileStorageService _fileStorageService;
    private readonly IRepository<MembershipPaymentHistory, int> _paymentRepository;

    // Progress constants
    private const int XP_PER_HOUR = 150;
    private const int XP_DECAY_PER_MISSED_DAY = 100;
    private const int XP_PER_LEVEL = 2500;
    private const int MAX_LEVEL = 10;
    private const int DECAY_PERIOD_DAYS = 30;

    private static readonly string[] DayNamesBosnian = { "Ned", "Pon", "Uto", "Sri", "Cet", "Pet", "Sub" };

    public UserProfileService(
        StrongholdDbContext context,
        IFileStorageService fileStorageService,
        IRepository<MembershipPaymentHistory, int> paymentRepository)
    {
        _context = context;
        _fileStorageService = fileStorageService;
        _paymentRepository = paymentRepository;
    }

    // =====================
    // Profile methods
    // =====================

    public async Task<UserProfileResponse> GetProfileAsync(int userId)
    {
        var user = await _context.Users
            .Where(u => u.Id == userId)
            .Select(u => new UserProfileResponse
            {
                Id = u.Id,
                FirstName = u.FirstName,
                LastName = u.LastName,
                Username = u.Username,
                Email = u.Email,
                PhoneNumber = u.PhoneNumber,
                ProfileImageUrl = u.ProfileImageUrl
            })
            .FirstOrDefaultAsync();

        if (user == null)
            throw new KeyNotFoundException("Korisnik nije pronađen");

        return user;
    }

    public async Task<bool> UpdateProfilePictureAsync(int userId, string? imageUrl)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null)
            return false;

        user.ProfileImageUrl = imageUrl;
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<string> UploadProfilePictureAsync(int userId, FileUploadRequest fileRequest)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null)
            throw new KeyNotFoundException("Korisnik nije pronađen");

        if (!string.IsNullOrEmpty(user.ProfileImageUrl))
        {
            await _fileStorageService.DeleteAsync(user.ProfileImageUrl);
        }

        var uploadResult = await _fileStorageService.UploadAsync(fileRequest, "profile-pictures", userId.ToString());

        if (!uploadResult.Success)
            throw new InvalidOperationException(uploadResult.ErrorMessage);

        user.ProfileImageUrl = uploadResult.FileUrl;
        await _context.SaveChangesAsync();

        return uploadResult.FileUrl!;
    }

    public async Task DeleteProfilePictureAsync(int userId)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null)
            throw new KeyNotFoundException("Korisnik nije pronađen");

        if (string.IsNullOrEmpty(user.ProfileImageUrl))
            return;

        await _fileStorageService.DeleteAsync(user.ProfileImageUrl);

        user.ProfileImageUrl = null;
        await _context.SaveChangesAsync();
    }

    // =====================
    // Membership payment history (from UserMembershipService)
    // =====================

    public async Task<IEnumerable<MembershipPaymentResponse>> GetMembershipPaymentHistoryAsync(int userId)
    {
        var paymentHistory = _paymentRepository.AsQueryable()
            .Where(x => x.UserId == userId)
            .Include(x => x.MembershipPackage);

        var resultDTO = await paymentHistory.Select(x => new MembershipPaymentResponse()
        {
            Id = x.Id,
            PackageName = x.MembershipPackage.PackageName,
            AmountPaid = x.AmountPaid,
            PaymentDate = x.PaymentDate,
            StartDate = x.StartDate,
            EndDate = x.EndDate
        }).ToListAsync();

        return resultDTO;
    }

    // =====================
    // Progress tracking (from UserProgressService)
    // =====================

    public async Task<UserProgressResponse> GetProgressAsync(int userId)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Id == userId)
            ?? throw new KeyNotFoundException("Korisnik nije pronađen");

        // Calculate total minutes in database (not in memory)
        var totalMinutes = await _context.GymVisits
            .Where(v => v.UserId == userId && v.CheckOutTime != null)
            .SumAsync(v => (int)EF.Functions.DateDiffMinute(v.CheckInTime, v.CheckOutTime!.Value));

        var totalXPFromVisits = (int)(totalMinutes / 60.0 * XP_PER_HOUR);

        // Get only distinct visit dates for last 30 days (not full visit rows)
        var thirtyDaysAgo = DateTime.UtcNow.Date.AddDays(-DECAY_PERIOD_DAYS);
        var visitDatesLast30Days = await _context.GymVisits
            .Where(v => v.UserId == userId && v.CheckOutTime != null && v.CheckInTime.Date >= thirtyDaysAgo)
            .Select(v => v.CheckInTime.Date)
            .Distinct()
            .ToListAsync();

        var visitDatesSet = visitDatesLast30Days.ToHashSet();
        var missedDays = 0;
        for (var date = thirtyDaysAgo; date < DateTime.UtcNow.Date; date = date.AddDays(1))
        {
            if (!visitDatesSet.Contains(date))
            {
                missedDays++;
            }
        }

        var xpDecay = missedDays * XP_DECAY_PER_MISSED_DAY;
        var currentXP = Math.Max(0, totalXPFromVisits - xpDecay);

        var level = Math.Min(MAX_LEVEL, (currentXP / XP_PER_LEVEL) + 1);
        var xpProgress = currentXP % XP_PER_LEVEL;
        var progressPercentage = level >= MAX_LEVEL ? 100.0 : (xpProgress / (double)XP_PER_LEVEL) * 100;

        // Get weekly visit minutes grouped by date in database
        var sevenDaysAgo = DateTime.UtcNow.Date.AddDays(-6);
        var weeklyMinutesByDate = await _context.GymVisits
            .Where(v => v.UserId == userId && v.CheckOutTime != null && v.CheckInTime.Date >= sevenDaysAgo)
            .GroupBy(v => v.CheckInTime.Date)
            .Select(g => new { Date = g.Key, Minutes = g.Sum(v => (int)EF.Functions.DateDiffMinute(v.CheckInTime, v.CheckOutTime!.Value)) })
            .ToDictionaryAsync(x => x.Date, x => x.Minutes);

        var weeklyVisits = new List<WeeklyVisitResponse>();
        var totalMinutesThisWeek = 0;

        for (var date = sevenDaysAgo; date <= DateTime.UtcNow.Date; date = date.AddDays(1))
        {
            var dayMinutes = weeklyMinutesByDate.GetValueOrDefault(date, 0);
            totalMinutesThisWeek += dayMinutes;

            weeklyVisits.Add(new WeeklyVisitResponse
            {
                Date = date,
                Minutes = dayMinutes,
                DayName = DayNamesBosnian[(int)date.DayOfWeek]
            });
        }

        return new UserProgressResponse
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

    public async Task<List<LeaderboardEntryResponse>> GetLeaderboardAsync(int top = 5)
    {
        var entries = await GetAllUserProgressAsync();
        return entries
            .OrderByDescending(e => e.Level)
            .ThenByDescending(e => e.CurrentXP)
            .Take(top)
            .Select((e, index) => new LeaderboardEntryResponse
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

    public async Task<List<LeaderboardEntryResponse>> GetFullLeaderboardAsync()
    {
        var entries = await GetAllUserProgressAsync();
        return entries
            .OrderByDescending(e => e.Level)
            .ThenByDescending(e => e.CurrentXP)
            .Select((e, index) => new LeaderboardEntryResponse
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

        // Get total minutes per user in database (not loading all visit rows)
        var totalMinutesByUser = await _context.GymVisits
            .Where(v => v.CheckOutTime != null)
            .GroupBy(v => v.UserId)
            .Select(g => new { UserId = g.Key, TotalMinutes = g.Sum(v => (int)EF.Functions.DateDiffMinute(v.CheckInTime, v.CheckOutTime!.Value)) })
            .ToDictionaryAsync(x => x.UserId, x => x.TotalMinutes);

        // Get distinct visit dates per user for last 30 days (just userId + date pairs, not full rows)
        var thirtyDaysAgo = DateTime.UtcNow.Date.AddDays(-DECAY_PERIOD_DAYS);
        var visitDatesByUser = await _context.GymVisits
            .Where(v => v.CheckOutTime != null && v.CheckInTime.Date >= thirtyDaysAgo)
            .Select(v => new { v.UserId, Date = v.CheckInTime.Date })
            .Distinct()
            .ToListAsync();

        var visitDatesGrouped = visitDatesByUser
            .GroupBy(v => v.UserId)
            .ToDictionary(g => g.Key, g => g.Select(v => v.Date).ToHashSet());

        var entries = new List<UserProgressEntry>();

        foreach (var user in users)
        {
            var totalMinutes = totalMinutesByUser.GetValueOrDefault(user.Id, 0);
            var totalXPFromVisits = (int)(totalMinutes / 60.0 * XP_PER_HOUR);

            var visitDatesLast30Days = visitDatesGrouped.GetValueOrDefault(user.Id) ?? new HashSet<DateTime>();

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
