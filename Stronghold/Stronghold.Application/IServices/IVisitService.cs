using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;

namespace Stronghold.Application.IServices
{
    public interface IVisitService
    {
        Task<PagedResult<VisitResponse>> GetCurrentVisitorsAsync(VisitQueryFilter filter);
        Task<VisitResponse> CheckInAsync(CheckInRequest request);
        Task<VisitResponse> CheckOutAsync(int visitId);
    }
}
