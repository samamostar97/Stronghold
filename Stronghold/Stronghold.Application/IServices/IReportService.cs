using Stronghold.Application.DTOs.AdminReportsDTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IServices
{
    public interface IReportService
    {
        Task<BusinessReportDTO> GetBusinessReportAsync();
    }
}
