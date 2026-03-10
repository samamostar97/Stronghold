using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Products.GetRecommendations;

[AuthorizeRole("User")]
public class GetRecommendationsQuery : IRequest<List<ProductResponse>>
{
}
