using Stronghold.Application.Common;
using Stronghold.Application.DTOs.AdminOrderDTO;
using Stronghold.Application.DTOs.AdminReviewDTO;
using Stronghold.Application.Filters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IServices
{
    public interface IAdminReviewService
    {
        Task<PagedResult<ReviewDTO>> GetReviewsPagedAsync(PaginationRequest request, ReviewQueryFilter? queryFilter);
        Task<ReviewDTO> DeleteReviewAsync(int reviewId);
    }
}
