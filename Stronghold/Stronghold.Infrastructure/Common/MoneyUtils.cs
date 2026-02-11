namespace Stronghold.Infrastructure.Common;

public static class MoneyUtils
{
    public static long ToMinorUnits(decimal amount)
    {
        return (long)Math.Round(amount * 100m, MidpointRounding.AwayFromZero);
    }

    public static decimal ToMajorUnits(long minorUnits)
    {
        return minorUnits / 100m;
    }
}
