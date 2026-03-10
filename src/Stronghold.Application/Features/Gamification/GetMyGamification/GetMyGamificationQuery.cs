using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Gamification.GetMyGamification;

[AuthorizeRole("User")]
public class GetMyGamificationQuery : IRequest<GamificationResponse>
{
}
