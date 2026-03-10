using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Suppliers.CreateSupplier;

[AuthorizeRole("Admin")]
public class CreateSupplierCommand : IRequest<SupplierResponse>
{
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? Website { get; set; }
}
