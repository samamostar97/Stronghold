namespace Stronghold.Application.DTOs.Suppliers;

public class SupplierResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = null!;
    public string ContactEmail { get; set; } = null!;
    public string ContactPhone { get; set; } = null!;
}
