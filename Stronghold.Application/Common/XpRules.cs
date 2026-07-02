namespace Stronghold.Application.Common;

/// <summary>
/// XP pravila - jedan izvor istine, XP se uvijek racuna deterministicki iz posjeta
/// (nikad se ne pohranjuje i ne mutira cron-om).
/// </summary>
public static class XpRules
{
    public const int XpPerHour = 150;
    public const int XpPerLevel = 2500;
    public const int MaxLevel = 10;
    public const int DecayPerDay = 100;
    public const int DecayWindowDays = 30;

    public static int ComputeXp(int totalMinutes, int activeDaysInWindow)
    {
        var earned = totalMinutes * XpPerHour / 60;
        var missedDays = DecayWindowDays - Math.Min(activeDaysInWindow, DecayWindowDays);
        return Math.Max(0, earned - missedDays * DecayPerDay);
    }

    public static int ComputeLevel(int xp)
    {
        return Math.Min(MaxLevel, xp / XpPerLevel + 1);
    }

    public static int ComputeLevelProgressPercent(int xp)
    {
        return ComputeLevel(xp) == MaxLevel ? 100 : xp % XpPerLevel * 100 / XpPerLevel;
    }
}
