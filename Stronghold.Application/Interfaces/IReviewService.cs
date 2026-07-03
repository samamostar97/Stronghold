using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Reviews;

namespace Stronghold.Application.Interfaces;

public interface IReviewService : IService<ReviewResponse, ReviewSearch>
{
    /// <summary>Recenzija je dozvoljena samo za suplement iz DOSTAVLJENE narudzbe clana.</summary>
    Task<ReviewResponse> CreateMineAsync(ReviewCreateRequest request);

    /// <summary>Recenzije trenutno prijavljenog clana - mobile oznacava vec ocijenjene proizvode.</summary>
    Task<List<ReviewResponse>> GetMineAsync();
}
