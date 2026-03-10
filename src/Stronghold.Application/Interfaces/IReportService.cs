using Stronghold.Application.Features.Reports;

namespace Stronghold.Application.Interfaces;

public interface IReportService
{
    ReportResult GenerateRevenueReportPdf(RevenueReportData data);
    ReportResult GenerateRevenueReportExcel(RevenueReportData data);

    ReportResult GenerateOrderRevenueReportPdf(OrderRevenueReportData data);
    ReportResult GenerateOrderRevenueReportExcel(OrderRevenueReportData data);

    ReportResult GenerateMembershipRevenueReportPdf(MembershipRevenueReportData data);
    ReportResult GenerateMembershipRevenueReportExcel(MembershipRevenueReportData data);

    ReportResult GenerateUsersReportPdf(UsersReportData data);
    ReportResult GenerateUsersReportExcel(UsersReportData data);

    ReportResult GenerateProductsReportPdf(ProductsReportData data);
    ReportResult GenerateProductsReportExcel(ProductsReportData data);

    ReportResult GenerateAppointmentsReportPdf(AppointmentsReportData data);
    ReportResult GenerateAppointmentsReportExcel(AppointmentsReportData data);
}
