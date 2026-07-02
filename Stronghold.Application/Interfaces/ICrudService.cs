using Stronghold.Application.Common;

namespace Stronghold.Application.Interfaces;

public interface ICrudService<TResponse, in TSearch, in TInsert, in TUpdate> : IService<TResponse, TSearch>
    where TSearch : BaseSearchObject
{
    Task<TResponse> InsertAsync(TInsert request);
    Task<TResponse> UpdateAsync(int id, TUpdate request);
    Task DeleteAsync(int id);
}
