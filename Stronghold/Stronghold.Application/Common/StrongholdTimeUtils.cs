namespace Stronghold.Application.Common;

public static class StrongholdTimeUtils
{
    private const string EuropeSarajevoTimeZoneId = "Europe/Sarajevo";
    private const string WindowsSarajevoTimeZoneId = "Central European Standard Time";
    private static readonly TimeZoneInfo _localTimeZone = ResolveLocalTimeZone();

    public static TimeZoneInfo LocalTimeZone => _localTimeZone;
    public static DateTime UtcNow => DateTime.UtcNow;
    public static DateTime UtcToday => DateTime.UtcNow.Date;
    public static DateTime LocalNow => TimeZoneInfo.ConvertTimeFromUtc(UtcNow, _localTimeZone);
    public static DateTime LocalToday => LocalNow.Date;

    public static DateTime ToUtc(DateTime value)
    {
        return value.Kind switch
        {
            DateTimeKind.Utc => value,
            DateTimeKind.Local => value.ToUniversalTime(),
            _ => TimeZoneInfo.ConvertTimeToUtc(
                DateTime.SpecifyKind(value, DateTimeKind.Unspecified),
                _localTimeZone)
        };
    }

    public static DateTime ToLocal(DateTime value)
    {
        return value.Kind switch
        {
            DateTimeKind.Utc => TimeZoneInfo.ConvertTimeFromUtc(value, _localTimeZone),
            DateTimeKind.Local => TimeZoneInfo.ConvertTime(value, _localTimeZone),
            _ => value
        };
    }

    public static DateTime ToUtcDate(DateTime value)
    {
        return new DateTime(value.Year, value.Month, value.Day, 0, 0, 0, DateTimeKind.Utc);
    }

    private static TimeZoneInfo ResolveLocalTimeZone()
    {
        try
        {
            return TimeZoneInfo.FindSystemTimeZoneById(EuropeSarajevoTimeZoneId);
        }
        catch (TimeZoneNotFoundException)
        {
            try
            {
                return TimeZoneInfo.FindSystemTimeZoneById(WindowsSarajevoTimeZoneId);
            }
            catch
            {
                return TimeZoneInfo.Utc;
            }
        }
        catch (InvalidTimeZoneException)
        {
            return TimeZoneInfo.Utc;
        }
    }
}
