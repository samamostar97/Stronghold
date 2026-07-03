using Stronghold.Application.Common;

namespace Stronghold.Application.DTOs.Seminars;

public class SeminarSearch : BaseSearchObject
{
    // Pretraga po temi ili predavacu.
    public string? Text { get; set; }

    // Mobile prikazuje samo nadolazece seminare.
    public bool? OnlyUpcoming { get; set; }
}
