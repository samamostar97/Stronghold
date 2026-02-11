namespace Stronghold.Infrastructure.Common;

public static class DateTimeUtils
{
    public static DateTime UtcNow => DateTime.UtcNow;
    public static DateTime UtcToday => DateTime.UtcNow.Date;
    public static DateTime LocalToday => DateTime.Today;

    public static DateTime ToUtc(DateTime value)
    {
        return value.Kind switch
        {
            DateTimeKind.Utc => value,
            DateTimeKind.Local => value.ToUniversalTime(),
            _ => DateTime.SpecifyKind(value, DateTimeKind.Local).ToUniversalTime()
        };
    }

    public static DateTime ToUtcDate(DateTime value)
    {
        return new DateTime(value.Year, value.Month, value.Day, 0, 0, 0, DateTimeKind.Utc);
    }
}
