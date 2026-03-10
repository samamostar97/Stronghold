using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Suppliers.UpdateSupplier;

[AuthorizeRole("Admin")]
public class UpdateSupplierCommand : IRequest<SupplierResponse>
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? Website { get; set; }
}
