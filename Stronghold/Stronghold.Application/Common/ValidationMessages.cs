namespace Stronghold.Application.Common;



public static class ValidationMessages
{
    // ── General ───────────────────────────────────────────────────────────
    public const string Required = "{PropertyName} je obavezno.";
    public const string InvalidValue = "Neispravna vrijednost za {PropertyName}.";

    // ── String length ─────────────────────────────────────────────────────
    public const string MaxLength = "{PropertyName} ne smije imati vise od {MaxLength} karaktera.";
    public const string MinLength = "{PropertyName} mora imati najmanje {MinLength} karaktera.";

    // ── Numeric comparison ────────────────────────────────────────────────
    public const string GreaterThan = "{PropertyName} mora biti vece od {ComparisonValue}.";
    public const string GreaterThanOrEqual = "{PropertyName} mora biti vece ili jednako {ComparisonValue}.";
    public const string LessThanOrEqual = "{PropertyName} mora biti manje ili jednako {ComparisonValue}.";
    public const string InclusiveBetween = "{PropertyName} mora biti izmedju {From} i {To}.";

    // ── Filter / sorting ──────────────────────────────────────────────────
    public const string InvalidSortValue = "Neispravna vrijednost za sortiranje.";
    public const string InvalidStatusValue = "Neispravna vrijednost statusa.";

    // ── Domain-specific ───────────────────────────────────────────────────
    public const string InvalidUrl = "Unesite ispravnu web adresu.";
    public const string MustSelectStaff = "Morate odabrati trenera ili nutricionistu.";
    public const string OnlyOneStaff = "Termin moze biti samo kod trenera ili nutricioniste, ne oba.";
    public const string StatusMustBe = "Status mora biti active, cancelled ili finished.";
}
