using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IServices
{
    public interface ISupplementCategoryService : IService<SupplementCategory, SupplementCategoryResponse, CreateSupplementCategoryRequest, UpdateSupplementCategoryRequest, SupplementCategoryQueryFilter, int>
    {
    }
}
