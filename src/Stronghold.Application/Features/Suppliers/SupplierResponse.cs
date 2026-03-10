namespace Stronghold.Application.Features.Suppliers;

public class SupplierResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? Website { get; set; }
    public DateTime CreatedAt { get; set; }
}
