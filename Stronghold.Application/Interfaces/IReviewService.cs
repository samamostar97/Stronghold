using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Reviews;

namespace Stronghold.Application.Interfaces;

public interface IReviewService : IService<ReviewResponse, ReviewSearch>
{
    // Recenzija je dozvoljena samo za suplement iz DOSTAVLJENE narudzbe clana.
    Task<ReviewResponse> CreateMineAsync(ReviewCreateRequest request);

    // Recenzije trenutno prijavljenog clana - mobile oznacava vec ocijenjene proizvode.
    Task<List<ReviewResponse>> GetMineAsync();
}
