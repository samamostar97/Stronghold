namespace Stronghold.Application.DTOs.Reports;

/// <summary>Izvjestaj o prodavnici - sve prodaje u periodu (otkazane narudzbe se ne racunaju), opciono za jednog kupca.</summary>
public class ShopReportResponse
{
    public DateTime FromDate { get; set; }

    /// <summary>Krajnji datum perioda (ukljucen).</summary>
    public DateTime ToDate { get; set; }

    /// <summary>Popunjeno samo kad je izvjestaj filtriran po clanu.</summary>
    public string? UserFullName { get; set; }

    public decimal TotalRevenue { get; set; }
    public int OrderCount { get; set; }

    public List<OrderRow> Orders { get; set; } = new();
}

public class OrderRow
{
    public DateTime CreatedAt { get; set; }
    public string UserFullName { get; set; } = null!;

    /// <summary>Ukupan broj artikala (suma kolicina stavki).</summary>
    public int ItemCount { get; set; }

    public decimal TotalAmount { get; set; }

    /// <summary>Status preveden na bosanski (isti tekst ide u UI i exporte).</summary>
    public string Status { get; set; } = null!;
}
