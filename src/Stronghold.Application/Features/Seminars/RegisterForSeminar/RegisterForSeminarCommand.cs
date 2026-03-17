using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Seminars.RegisterForSeminar;

[AuthorizeRole("User")]
public class RegisterForSeminarCommand : IRequest<Unit>
{
    public int SeminarId { get; set; }
}
