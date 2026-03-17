using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Seminars.GetSeminars;

[AuthorizeRole("Admin")]
[AuthorizeRole("User")]
public class GetSeminarsQuery : BaseQueryFilter, IRequest<PagedResult<SeminarResponse>>
{
    public string? Status { get; set; }
}
