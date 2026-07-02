using Stronghold.Application.DTOs.SupplementCategories;

namespace Stronghold.Application.Interfaces;

public interface ISupplementCategoryService : ICrudService<SupplementCategoryResponse, SupplementCategorySearch,
    SupplementCategoryUpsertRequest, SupplementCategoryUpsertRequest>
{
}
