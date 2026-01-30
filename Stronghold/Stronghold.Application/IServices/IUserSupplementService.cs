using Stronghold.Application.Common;
using Stronghold.Application.DTOs.UserDTOs;

namespace Stronghold.Application.IServices
{
    public interface IUserSupplementService
    {
        Task<PagedResult<UserSupplementDTO>> GetSupplementsPaged(PaginationRequest pagination, string? search, int? categoryId);
        Task<UserSupplementDTO> GetById(int id);
        Task<IEnumerable<UserSupplementCategoryDTO>> GetCategories();
        Task<IEnumerable<SupplementReviewDTO>> GetReviewsBySupplementId(int supplementId);
    }
}
