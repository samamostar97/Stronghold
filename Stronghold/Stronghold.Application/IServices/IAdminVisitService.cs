using Stronghold.Application.Common;
using Stronghold.Application.DTOs.AdminVisitsDTO;
using Stronghold.Application.Filters;

namespace Stronghold.Application.IServices
{
    public interface IAdminVisitService
    {
        Task<IEnumerable<VisitDTO>> GetCurrentVisitorsAsync();
        Task<VisitDTO> CheckInAsync(CheckInRequestDTO request);
        Task<VisitDTO> CheckOutAsync(int visitId);
    }
}
