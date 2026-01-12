using Stronghold.Application.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IRepositories
{
    public interface IRepository<T, TKey> where T : class
    {
        Task<T> GetByIdAsync(TKey id);
        Task<IEnumerable<T>> GetAllAsync();
        Task AddAsync(T entity);
        Task UpdateAsync(T entity);
        Task DeleteAsync(T entity);
        Task<PagedResult<T>> GetPagedAsync(IQueryable<T> query, PaginationRequest request);
        IQueryable<T> AsQueryable();
        Task<bool> ExistsAsync(TKey id);
    }
}
