namespace Stronghold.Application.DTOs.Reports;

// Izvjestaj o prodavnici - sve prodaje u periodu (otkazane narudzbe se ne racunaju), opciono za jednog kupca.
public class ShopReportResponse
{
    public DateTime FromDate { get; set; }

    // Krajnji datum perioda (ukljucen).
    public DateTime ToDate { get; set; }

    // Popunjeno samo kad je izvjestaj filtriran po clanu.
    public string? UserFullName { get; set; }

    public decimal TotalRevenue { get; set; }
    public int OrderCount { get; set; }

    public List<OrderRow> Orders { get; set; } = new();
}

public class OrderRow
{
    public DateTime CreatedAt { get; set; }
    public string UserFullName { get; set; } = null!;

    // Ukupan broj artikala (suma kolicina stavki).
    public int ItemCount { get; set; }

    public decimal TotalAmount { get; set; }

    // Status preveden na bosanski (isti tekst ide u UI i exporte).
    public string Status { get; set; } = null!;
}
