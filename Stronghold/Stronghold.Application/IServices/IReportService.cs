using Stronghold.Application.DTOs.AdminReportsDTO;

namespace Stronghold.Application.IServices
{
    public interface IReportService
    {
        Task<BusinessReportDTO> GetBusinessReportAsync();
        Task<byte[]> ExportToExcelAsync();
        Task<byte[]> ExportToPdfAsync();
    }
}
