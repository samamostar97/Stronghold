using Stronghold.Application.DTOs.AdminVisitsDTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IServices
{
    public interface IGymVisitsService
    {
        Task<IEnumerable<CurrentVisitorDTO>> GetCurrentVisitorsAsync();
        Task<CurrentVisitorDTO> CheckInAsync(AdminCheckInDTO dto);
        Task CheckOutAsync(int gymVisitId);

    }
}
