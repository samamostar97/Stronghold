using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Seminars.GetSeminarRegistrations;

[AuthorizeRole("Admin")]
public class GetSeminarRegistrationsQuery : IRequest<List<SeminarRegistrationResponse>>
{
    public int SeminarId { get; set; }
}
