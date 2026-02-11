namespace Stronghold.Application.Common;

public static class StrongholdTimeUtils
{
    private const string EuropeSarajevoTimeZoneId = "Europe/Sarajevo";
    private const string WindowsSarajevoTimeZoneId = "Central European Standard Time";
    private static readonly TimeZoneInfo _localTimeZone = ResolveLocalTimeZone();

    public static DateTime LocalNow => TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, _localTimeZone);
    public static DateTime LocalToday => LocalNow.Date;

    public static DateTime ToLocal(DateTime value)
    {
        return value.Kind switch
        {
            DateTimeKind.Utc => TimeZoneInfo.ConvertTimeFromUtc(value, _localTimeZone),
            DateTimeKind.Local => TimeZoneInfo.ConvertTime(value, _localTimeZone),
            _ => value
        };
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
