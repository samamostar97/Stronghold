using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Seminars.GetMySeminars;

[AuthorizeRole("User")]
public class GetMySeminarsQuery : IRequest<List<SeminarResponse>>
{
}
