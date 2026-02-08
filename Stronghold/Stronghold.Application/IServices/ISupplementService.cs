using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IServices
{
    public interface ISupplementService : IService<Supplement, SupplementResponse, CreateSupplementRequest, UpdateSupplementRequest, SupplementQueryFilter, int>
    {
        // Admin methods
        Task<SupplementResponse> UploadImageAsync(int supplementId, FileUploadRequest fileRequest);
        Task<bool> DeleteImageAsync(int supplementId);

        // Related data (for supplement detail page)
        Task<IEnumerable<SupplementReviewResponse>> GetReviewsAsync(int supplementId);
    }
}
