using Stronghold.Application.Common;

namespace Stronghold.Application.Interfaces;

public interface IService<TResponse, in TSearch> where TSearch : BaseSearchObject
{
    Task<PagedResult<TResponse>> GetPagedAsync(TSearch search);
    Task<TResponse> GetByIdAsync(int id);
}
