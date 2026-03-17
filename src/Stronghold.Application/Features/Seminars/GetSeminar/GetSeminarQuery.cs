using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Seminars.GetSeminar;

[AuthorizeRole("Admin")]
[AuthorizeRole("User")]
public class GetSeminarQuery : IRequest<SeminarResponse>
{
    public int Id { get; set; }
}
