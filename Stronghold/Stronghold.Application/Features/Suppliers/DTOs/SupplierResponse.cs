namespace Stronghold.Application.Features.Suppliers.DTOs;

public class SupplierResponse
{
    public int Id { get; set; }

public string Name { get; set; } = string.Empty;
    public string? Website { get; set; }

public DateTime CreatedAt { get; set; }
}
