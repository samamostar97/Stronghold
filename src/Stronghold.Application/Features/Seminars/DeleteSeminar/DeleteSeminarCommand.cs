using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Seminars.DeleteSeminar;

[AuthorizeRole("Admin")]
public class DeleteSeminarCommand : IRequest<Unit>
{
    public int Id { get; set; }
}
