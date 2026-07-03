using Stronghold.Application.Common;

namespace Stronghold.Application.DTOs.Seminars;

public class SeminarSearch : BaseSearchObject
{
    /// <summary>Pretraga po temi ili predavacu.</summary>
    public string? Text { get; set; }

    /// <summary>Mobile prikazuje samo nadolazece seminare.</summary>
    public bool? OnlyUpcoming { get; set; }
}
