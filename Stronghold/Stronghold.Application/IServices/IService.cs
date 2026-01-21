using Stronghold.Application.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IServices
{
    public interface IService<T,TDto,TCreateDto,TUpdateDto,TQueryFilter,TKey>
    {
        Task<IEnumerable<TDto>> GetAllAsync(TQueryFilter? filter);
        Task<PagedResult<TDto>> GetPagedAsync(PaginationRequest pagination, TQueryFilter? filter);
        Task<TDto> GetByIdAsync(TKey id);
        Task<TDto> CreateAsync(TCreateDto dto);
        Task<TDto> UpdateAsync(TKey id,TUpdateDto dto);
        Task DeleteAsync(TKey id);
    }

}
