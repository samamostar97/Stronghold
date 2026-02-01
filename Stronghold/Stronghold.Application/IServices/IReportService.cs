using Stronghold.Application.DTOs.AdminReportsDTO;

namespace Stronghold.Application.IServices
{
    public interface IReportService
    {
        Task<BusinessReportDTO> GetBusinessReportAsync();
        Task<InventoryReportDTO> GetInventoryReportAsync(int daysToAnalyze = 30);
        Task<MembershipPopularityReportDTO> GetMembershipPopularityReportAsync();
        Task<byte[]> ExportToExcelAsync();
        Task<byte[]> ExportToPdfAsync();
        Task<byte[]> ExportInventoryReportToExcelAsync(int daysToAnalyze = 30);
        Task<byte[]> ExportInventoryReportToPdfAsync(int daysToAnalyze = 30);
        Task<byte[]> ExportMembershipPopularityToExcelAsync();
        Task<byte[]> ExportMembershipPopularityToPdfAsync();
    }
}
