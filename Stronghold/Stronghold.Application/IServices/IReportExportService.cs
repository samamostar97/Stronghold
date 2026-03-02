namespace Stronghold.Application.IServices;

public interface IReportExportService
{
    Task<byte[]> ExportToExcelAsync();
    Task<byte[]> ExportToPdfAsync();
    Task<byte[]> ExportMembershipPopularityToExcelAsync();
    Task<byte[]> ExportMembershipPopularityToPdfAsync();
    Task<byte[]> ExportVisitsToExcelAsync();
    Task<byte[]> ExportVisitsToPdfAsync();
    Task<byte[]> ExportStaffToExcelAsync();
    Task<byte[]> ExportStaffToPdfAsync();
    Task<byte[]> ExportMembershipPaymentsToExcelAsync();
    Task<byte[]> ExportMembershipPaymentsToPdfAsync();
}
