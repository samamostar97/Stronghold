using ClosedXML.Excel;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using Stronghold.Application.Features.Reports;
using Stronghold.Application.Interfaces;

namespace Stronghold.Infrastructure.Services;

public class ReportService : IReportService
{
    private const string DateFormat = "dd.MM.yyyy";

    // ==================== REVENUE (TOTAL) ====================

    public ReportResult GenerateRevenueReportPdf(RevenueReportData data)
    {
        var bytes = GeneratePdf("Izvještaj o prihodima", data.From, data.To, container =>
        {
            container.Item().Text($"Ukupni prihod: {data.TotalRevenue:N2} KM").SemiBold().FontSize(14);
            container.Item().PaddingTop(5).Text($"Prihod od narudžbi: {data.OrderRevenue:N2} KM ({data.OrderCount} narudžbi)");
            container.Item().Text($"Prihod od članarina: {data.MembershipRevenue:N2} KM ({data.MembershipCount} članarina)");

            // Orders table
            if (data.OrderItems.Count > 0)
            {
                container.Item().PaddingTop(20).Text("Narudžbe").SemiBold().FontSize(12);
                container.Item().PaddingTop(5).Table(table =>
                {
                    table.ColumnsDefinition(columns =>
                    {
                        columns.ConstantColumn(50);
                        columns.RelativeColumn(2);
                        columns.RelativeColumn();
                        columns.RelativeColumn();
                        columns.RelativeColumn();
                    });

                    table.Header(header =>
                    {
                        header.Cell().Element(HeaderCellStyle).Text("#");
                        header.Cell().Element(HeaderCellStyle).Text("Korisnik");
                        header.Cell().Element(HeaderCellStyle).Text("Iznos (KM)");
                        header.Cell().Element(HeaderCellStyle).Text("Status");
                        header.Cell().Element(HeaderCellStyle).Text("Datum");
                    });

                    foreach (var item in data.OrderItems)
                    {
                        table.Cell().Element(CellStyle).Text(item.OrderId.ToString());
                        table.Cell().Element(CellStyle).Text(item.UserName);
                        table.Cell().Element(CellStyle).Text($"{item.TotalAmount:N2}");
                        table.Cell().Element(CellStyle).Text(item.Status);
                        table.Cell().Element(CellStyle).Text(item.CreatedAt.ToString(DateFormat));
                    }
                });
            }

            // Memberships table
            if (data.MembershipItems.Count > 0)
            {
                container.Item().PaddingTop(20).Text("Članarine").SemiBold().FontSize(12);
                container.Item().PaddingTop(5).Table(table =>
                {
                    table.ColumnsDefinition(columns =>
                    {
                        columns.ConstantColumn(50);
                        columns.RelativeColumn(2);
                        columns.RelativeColumn(2);
                        columns.RelativeColumn();
                        columns.RelativeColumn();
                        columns.RelativeColumn();
                    });

                    table.Header(header =>
                    {
                        header.Cell().Element(HeaderCellStyle).Text("#");
                        header.Cell().Element(HeaderCellStyle).Text("Korisnik");
                        header.Cell().Element(HeaderCellStyle).Text("Paket");
                        header.Cell().Element(HeaderCellStyle).Text("Cijena (KM)");
                        header.Cell().Element(HeaderCellStyle).Text("Početak");
                        header.Cell().Element(HeaderCellStyle).Text("Kraj");
                    });

                    foreach (var item in data.MembershipItems)
                    {
                        table.Cell().Element(CellStyle).Text(item.MembershipId.ToString());
                        table.Cell().Element(CellStyle).Text(item.UserName);
                        table.Cell().Element(CellStyle).Text(item.PackageName);
                        table.Cell().Element(CellStyle).Text($"{item.Price:N2}");
                        table.Cell().Element(CellStyle).Text(item.StartDate.ToString(DateFormat));
                        table.Cell().Element(CellStyle).Text(item.EndDate.ToString(DateFormat));
                    }
                });
            }
        });

        return new ReportResult
        {
            FileContent = bytes,
            ContentType = "application/pdf",
            FileName = $"prihodi_{data.From:yyyyMMdd}_{data.To:yyyyMMdd}.pdf"
        };
    }

    public ReportResult GenerateRevenueReportExcel(RevenueReportData data)
    {
        using var workbook = new XLWorkbook();
        var ws = workbook.Worksheets.Add("Prihodi");

        ws.Cell(1, 1).Value = "Izvještaj o prihodima";
        ws.Cell(1, 1).Style.Font.Bold = true;
        ws.Cell(1, 1).Style.Font.FontSize = 14;
        ws.Cell(2, 1).Value = $"Period: {data.From.ToString(DateFormat)} - {data.To.ToString(DateFormat)}";

        ws.Cell(4, 1).Value = "Kategorija";
        ws.Cell(4, 2).Value = "Iznos (KM)";
        ws.Cell(4, 3).Value = "Broj";
        StyleHeaderRow(ws, 4, 3);

        ws.Cell(5, 1).Value = "Narudžbe";
        ws.Cell(5, 2).Value = data.OrderRevenue;
        ws.Cell(5, 3).Value = data.OrderCount;

        ws.Cell(6, 1).Value = "Članarine";
        ws.Cell(6, 2).Value = data.MembershipRevenue;
        ws.Cell(6, 3).Value = data.MembershipCount;

        ws.Cell(7, 1).Value = "UKUPNO";
        ws.Cell(7, 1).Style.Font.Bold = true;
        ws.Cell(7, 2).Value = data.TotalRevenue;
        ws.Cell(7, 2).Style.Font.Bold = true;

        // Orders sheet
        if (data.OrderItems.Count > 0)
        {
            var wsOrders = workbook.Worksheets.Add("Narudžbe");
            wsOrders.Cell(1, 1).Value = "Narudžbe";
            wsOrders.Cell(1, 1).Style.Font.Bold = true;
            wsOrders.Cell(1, 1).Style.Font.FontSize = 14;

            var orderHeaders = new[] { "#", "Korisnik", "Iznos (KM)", "Status", "Datum" };
            WriteExcelHeaders(wsOrders, 3, orderHeaders);

            for (int i = 0; i < data.OrderItems.Count; i++)
            {
                var row = 4 + i;
                var item = data.OrderItems[i];
                wsOrders.Cell(row, 1).Value = item.OrderId;
                wsOrders.Cell(row, 2).Value = item.UserName;
                wsOrders.Cell(row, 3).Value = item.TotalAmount;
                wsOrders.Cell(row, 4).Value = item.Status;
                wsOrders.Cell(row, 5).Value = item.CreatedAt.ToString(DateFormat);
            }
            wsOrders.Columns().AdjustToContents();
        }

        // Memberships sheet
        if (data.MembershipItems.Count > 0)
        {
            var wsMemberships = workbook.Worksheets.Add("Članarine");
            wsMemberships.Cell(1, 1).Value = "Članarine";
            wsMemberships.Cell(1, 1).Style.Font.Bold = true;
            wsMemberships.Cell(1, 1).Style.Font.FontSize = 14;

            var membershipHeaders = new[] { "#", "Korisnik", "Paket", "Cijena (KM)", "Početak", "Kraj" };
            WriteExcelHeaders(wsMemberships, 3, membershipHeaders);

            for (int i = 0; i < data.MembershipItems.Count; i++)
            {
                var row = 4 + i;
                var item = data.MembershipItems[i];
                wsMemberships.Cell(row, 1).Value = item.MembershipId;
                wsMemberships.Cell(row, 2).Value = item.UserName;
                wsMemberships.Cell(row, 3).Value = item.PackageName;
                wsMemberships.Cell(row, 4).Value = item.Price;
                wsMemberships.Cell(row, 5).Value = item.StartDate.ToString(DateFormat);
                wsMemberships.Cell(row, 6).Value = item.EndDate.ToString(DateFormat);
            }
            wsMemberships.Columns().AdjustToContents();
        }

        ws.Columns().AdjustToContents();

        return ToExcelResult(workbook, $"prihodi_{data.From:yyyyMMdd}_{data.To:yyyyMMdd}");
    }

    // ==================== ORDER REVENUE ====================

    public ReportResult GenerateOrderRevenueReportPdf(OrderRevenueReportData data)
    {
        var bytes = GeneratePdf("Izvještaj o prihodima od narudžbi", data.From, data.To, container =>
        {
            container.Item().Text($"Ukupni prihod: {data.TotalRevenue:N2} KM | Broj narudžbi: {data.TotalOrders}").SemiBold().FontSize(12);
            container.Item().PaddingTop(10).Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.ConstantColumn(50);
                    columns.RelativeColumn(2);
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                });

                table.Header(header =>
                {
                    header.Cell().Element(HeaderCellStyle).Text("#");
                    header.Cell().Element(HeaderCellStyle).Text("Korisnik");
                    header.Cell().Element(HeaderCellStyle).Text("Iznos (KM)");
                    header.Cell().Element(HeaderCellStyle).Text("Status");
                    header.Cell().Element(HeaderCellStyle).Text("Datum");
                });

                foreach (var item in data.Items)
                {
                    table.Cell().Element(CellStyle).Text(item.OrderId.ToString());
                    table.Cell().Element(CellStyle).Text(item.UserName);
                    table.Cell().Element(CellStyle).Text($"{item.TotalAmount:N2}");
                    table.Cell().Element(CellStyle).Text(item.Status);
                    table.Cell().Element(CellStyle).Text(item.CreatedAt.ToString(DateFormat));
                }
            });
        });

        return new ReportResult
        {
            FileContent = bytes,
            ContentType = "application/pdf",
            FileName = $"prihodi_narudzbe_{data.From:yyyyMMdd}_{data.To:yyyyMMdd}.pdf"
        };
    }

    public ReportResult GenerateOrderRevenueReportExcel(OrderRevenueReportData data)
    {
        using var workbook = new XLWorkbook();
        var ws = workbook.Worksheets.Add("Narudžbe");

        ws.Cell(1, 1).Value = "Izvještaj o prihodima od narudžbi";
        ws.Cell(1, 1).Style.Font.Bold = true;
        ws.Cell(1, 1).Style.Font.FontSize = 14;
        ws.Cell(2, 1).Value = $"Period: {data.From.ToString(DateFormat)} - {data.To.ToString(DateFormat)}";
        ws.Cell(3, 1).Value = $"Ukupni prihod: {data.TotalRevenue:N2} KM | Broj narudžbi: {data.TotalOrders}";

        var headers = new[] { "#", "Korisnik", "Iznos (KM)", "Status", "Datum" };
        WriteExcelHeaders(ws, 5, headers);

        for (int i = 0; i < data.Items.Count; i++)
        {
            var row = 6 + i;
            var item = data.Items[i];
            ws.Cell(row, 1).Value = item.OrderId;
            ws.Cell(row, 2).Value = item.UserName;
            ws.Cell(row, 3).Value = item.TotalAmount;
            ws.Cell(row, 4).Value = item.Status;
            ws.Cell(row, 5).Value = item.CreatedAt.ToString(DateFormat);
        }

        ws.Columns().AdjustToContents();

        return ToExcelResult(workbook, $"prihodi_narudzbe_{data.From:yyyyMMdd}_{data.To:yyyyMMdd}");
    }

    // ==================== MEMBERSHIP REVENUE ====================

    public ReportResult GenerateMembershipRevenueReportPdf(MembershipRevenueReportData data)
    {
        var bytes = GeneratePdf("Izvještaj o prihodima od članarina", data.From, data.To, container =>
        {
            container.Item().Text($"Ukupni prihod: {data.TotalRevenue:N2} KM | Broj članarina: {data.TotalMemberships}").SemiBold().FontSize(12);
            container.Item().PaddingTop(10).Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.ConstantColumn(50);
                    columns.RelativeColumn(2);
                    columns.RelativeColumn(2);
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                });

                table.Header(header =>
                {
                    header.Cell().Element(HeaderCellStyle).Text("#");
                    header.Cell().Element(HeaderCellStyle).Text("Korisnik");
                    header.Cell().Element(HeaderCellStyle).Text("Paket");
                    header.Cell().Element(HeaderCellStyle).Text("Cijena (KM)");
                    header.Cell().Element(HeaderCellStyle).Text("Početak");
                    header.Cell().Element(HeaderCellStyle).Text("Kraj");
                });

                foreach (var item in data.Items)
                {
                    table.Cell().Element(CellStyle).Text(item.MembershipId.ToString());
                    table.Cell().Element(CellStyle).Text(item.UserName);
                    table.Cell().Element(CellStyle).Text(item.PackageName);
                    table.Cell().Element(CellStyle).Text($"{item.Price:N2}");
                    table.Cell().Element(CellStyle).Text(item.StartDate.ToString(DateFormat));
                    table.Cell().Element(CellStyle).Text(item.EndDate.ToString(DateFormat));
                }
            });
        });

        return new ReportResult
        {
            FileContent = bytes,
            ContentType = "application/pdf",
            FileName = $"prihodi_clanarine_{data.From:yyyyMMdd}_{data.To:yyyyMMdd}.pdf"
        };
    }

    public ReportResult GenerateMembershipRevenueReportExcel(MembershipRevenueReportData data)
    {
        using var workbook = new XLWorkbook();
        var ws = workbook.Worksheets.Add("Članarine");

        ws.Cell(1, 1).Value = "Izvještaj o prihodima od članarina";
        ws.Cell(1, 1).Style.Font.Bold = true;
        ws.Cell(1, 1).Style.Font.FontSize = 14;
        ws.Cell(2, 1).Value = $"Period: {data.From.ToString(DateFormat)} - {data.To.ToString(DateFormat)}";
        ws.Cell(3, 1).Value = $"Ukupni prihod: {data.TotalRevenue:N2} KM | Broj članarina: {data.TotalMemberships}";

        var headers = new[] { "#", "Korisnik", "Paket", "Cijena (KM)", "Početak", "Kraj" };
        WriteExcelHeaders(ws, 5, headers);

        for (int i = 0; i < data.Items.Count; i++)
        {
            var row = 6 + i;
            var item = data.Items[i];
            ws.Cell(row, 1).Value = item.MembershipId;
            ws.Cell(row, 2).Value = item.UserName;
            ws.Cell(row, 3).Value = item.PackageName;
            ws.Cell(row, 4).Value = item.Price;
            ws.Cell(row, 5).Value = item.StartDate.ToString(DateFormat);
            ws.Cell(row, 6).Value = item.EndDate.ToString(DateFormat);
        }

        ws.Columns().AdjustToContents();

        return ToExcelResult(workbook, $"prihodi_clanarine_{data.From:yyyyMMdd}_{data.To:yyyyMMdd}");
    }

    // ==================== USERS ====================

    public ReportResult GenerateUsersReportPdf(UsersReportData data)
    {
        var bytes = GeneratePdf("Izvještaj o korisnicima", data.From, data.To, container =>
        {
            container.Item().Text($"Ukupno novih korisnika: {data.TotalNewUsers}").SemiBold().FontSize(12);
            container.Item().PaddingTop(10).Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.ConstantColumn(50);
                    columns.RelativeColumn(2);
                    columns.RelativeColumn(2);
                    columns.RelativeColumn();
                });

                table.Header(header =>
                {
                    header.Cell().Element(HeaderCellStyle).Text("ID");
                    header.Cell().Element(HeaderCellStyle).Text("Ime i prezime");
                    header.Cell().Element(HeaderCellStyle).Text("Email");
                    header.Cell().Element(HeaderCellStyle).Text("Registracija");
                });

                foreach (var user in data.Users)
                {
                    table.Cell().Element(CellStyle).Text(user.Id.ToString());
                    table.Cell().Element(CellStyle).Text(user.FullName);
                    table.Cell().Element(CellStyle).Text(user.Email);
                    table.Cell().Element(CellStyle).Text(user.CreatedAt.ToString(DateFormat));
                }
            });
        });

        return new ReportResult
        {
            FileContent = bytes,
            ContentType = "application/pdf",
            FileName = $"korisnici_{data.From:yyyyMMdd}_{data.To:yyyyMMdd}.pdf"
        };
    }

    public ReportResult GenerateUsersReportExcel(UsersReportData data)
    {
        using var workbook = new XLWorkbook();
        var ws = workbook.Worksheets.Add("Korisnici");

        ws.Cell(1, 1).Value = "Izvještaj o korisnicima";
        ws.Cell(1, 1).Style.Font.Bold = true;
        ws.Cell(1, 1).Style.Font.FontSize = 14;
        ws.Cell(2, 1).Value = $"Period: {data.From.ToString(DateFormat)} - {data.To.ToString(DateFormat)}";
        ws.Cell(3, 1).Value = $"Ukupno novih korisnika: {data.TotalNewUsers}";

        var headers = new[] { "ID", "Ime i prezime", "Email", "Datum registracije" };
        WriteExcelHeaders(ws, 5, headers);

        for (int i = 0; i < data.Users.Count; i++)
        {
            var row = 6 + i;
            var user = data.Users[i];
            ws.Cell(row, 1).Value = user.Id;
            ws.Cell(row, 2).Value = user.FullName;
            ws.Cell(row, 3).Value = user.Email;
            ws.Cell(row, 4).Value = user.CreatedAt.ToString(DateFormat);
        }

        ws.Columns().AdjustToContents();

        return ToExcelResult(workbook, $"korisnici_{data.From:yyyyMMdd}_{data.To:yyyyMMdd}");
    }

    // ==================== PRODUCTS ====================

    public ReportResult GenerateProductsReportPdf(ProductsReportData data)
    {
        var bytes = GeneratePdf("Izvještaj o proizvodima", data.From, data.To, container =>
        {
            container.Item().Text("Najprodavaniji proizvodi").SemiBold().FontSize(12);
            container.Item().PaddingTop(5).Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn(2);
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                });

                table.Header(header =>
                {
                    header.Cell().Element(HeaderCellStyle).Text("Proizvod");
                    header.Cell().Element(HeaderCellStyle).Text("Kategorija");
                    header.Cell().Element(HeaderCellStyle).Text("Prodano");
                    header.Cell().Element(HeaderCellStyle).Text("Prihod (KM)");
                });

                foreach (var item in data.TopSelling)
                {
                    table.Cell().Element(CellStyle).Text(item.ProductName);
                    table.Cell().Element(CellStyle).Text(item.CategoryName);
                    table.Cell().Element(CellStyle).Text(item.TotalQuantitySold.ToString());
                    table.Cell().Element(CellStyle).Text($"{item.TotalRevenue:N2}");
                }
            });

            container.Item().PaddingTop(20).Text("Stanje zaliha").SemiBold().FontSize(12);
            container.Item().PaddingTop(5).Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn(2);
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                });

                table.Header(header =>
                {
                    header.Cell().Element(HeaderCellStyle).Text("Proizvod");
                    header.Cell().Element(HeaderCellStyle).Text("Kategorija");
                    header.Cell().Element(HeaderCellStyle).Text("Na stanju");
                    header.Cell().Element(HeaderCellStyle).Text("Cijena (KM)");
                });

                foreach (var item in data.StockLevels)
                {
                    table.Cell().Element(CellStyle).Text(item.ProductName);
                    table.Cell().Element(CellStyle).Text(item.CategoryName);
                    table.Cell().Element(CellStyle).Text(item.StockQuantity.ToString());
                    table.Cell().Element(CellStyle).Text($"{item.Price:N2}");
                }
            });
        });

        return new ReportResult
        {
            FileContent = bytes,
            ContentType = "application/pdf",
            FileName = $"proizvodi_{data.From:yyyyMMdd}_{data.To:yyyyMMdd}.pdf"
        };
    }

    public ReportResult GenerateProductsReportExcel(ProductsReportData data)
    {
        using var workbook = new XLWorkbook();

        var ws1 = workbook.Worksheets.Add("Najprodavaniji");
        ws1.Cell(1, 1).Value = "Najprodavaniji proizvodi";
        ws1.Cell(1, 1).Style.Font.Bold = true;
        ws1.Cell(1, 1).Style.Font.FontSize = 14;
        ws1.Cell(2, 1).Value = $"Period: {data.From.ToString(DateFormat)} - {data.To.ToString(DateFormat)}";

        var headers1 = new[] { "Proizvod", "Kategorija", "Prodano", "Prihod (KM)" };
        WriteExcelHeaders(ws1, 4, headers1);

        for (int i = 0; i < data.TopSelling.Count; i++)
        {
            var row = 5 + i;
            var item = data.TopSelling[i];
            ws1.Cell(row, 1).Value = item.ProductName;
            ws1.Cell(row, 2).Value = item.CategoryName;
            ws1.Cell(row, 3).Value = item.TotalQuantitySold;
            ws1.Cell(row, 4).Value = item.TotalRevenue;
        }
        ws1.Columns().AdjustToContents();

        var ws2 = workbook.Worksheets.Add("Stanje zaliha");
        ws2.Cell(1, 1).Value = "Stanje zaliha";
        ws2.Cell(1, 1).Style.Font.Bold = true;
        ws2.Cell(1, 1).Style.Font.FontSize = 14;

        var headers2 = new[] { "Proizvod", "Kategorija", "Na stanju", "Cijena (KM)" };
        WriteExcelHeaders(ws2, 3, headers2);

        for (int i = 0; i < data.StockLevels.Count; i++)
        {
            var row = 4 + i;
            var item = data.StockLevels[i];
            ws2.Cell(row, 1).Value = item.ProductName;
            ws2.Cell(row, 2).Value = item.CategoryName;
            ws2.Cell(row, 3).Value = item.StockQuantity;
            ws2.Cell(row, 4).Value = item.Price;
        }
        ws2.Columns().AdjustToContents();

        return ToExcelResult(workbook, $"proizvodi_{data.From:yyyyMMdd}_{data.To:yyyyMMdd}");
    }

    // ==================== APPOINTMENTS ====================

    public ReportResult GenerateAppointmentsReportPdf(AppointmentsReportData data)
    {
        var bytes = GeneratePdf("Izvještaj o terminima", data.From, data.To, container =>
        {
            container.Item().Text($"Ukupno termina: {data.TotalAppointments}").SemiBold().FontSize(12);
            container.Item().PaddingTop(10).Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn(2);
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                });

                table.Header(header =>
                {
                    header.Cell().Element(HeaderCellStyle).Text("Osoblje");
                    header.Cell().Element(HeaderCellStyle).Text("Tip");
                    header.Cell().Element(HeaderCellStyle).Text("Ukupno");
                    header.Cell().Element(HeaderCellStyle).Text("Završeni");
                    header.Cell().Element(HeaderCellStyle).Text("Odobreni");
                    header.Cell().Element(HeaderCellStyle).Text("Odbijeni");
                    header.Cell().Element(HeaderCellStyle).Text("Na čekanju");
                });

                foreach (var item in data.StaffStats)
                {
                    table.Cell().Element(CellStyle).Text(item.StaffName);
                    table.Cell().Element(CellStyle).Text(item.StaffType);
                    table.Cell().Element(CellStyle).Text(item.TotalAppointments.ToString());
                    table.Cell().Element(CellStyle).Text(item.Completed.ToString());
                    table.Cell().Element(CellStyle).Text(item.Approved.ToString());
                    table.Cell().Element(CellStyle).Text(item.Rejected.ToString());
                    table.Cell().Element(CellStyle).Text(item.Pending.ToString());
                }
            });
        });

        return new ReportResult
        {
            FileContent = bytes,
            ContentType = "application/pdf",
            FileName = $"termini_{data.From:yyyyMMdd}_{data.To:yyyyMMdd}.pdf"
        };
    }

    public ReportResult GenerateAppointmentsReportExcel(AppointmentsReportData data)
    {
        using var workbook = new XLWorkbook();
        var ws = workbook.Worksheets.Add("Termini");

        ws.Cell(1, 1).Value = "Izvještaj o terminima";
        ws.Cell(1, 1).Style.Font.Bold = true;
        ws.Cell(1, 1).Style.Font.FontSize = 14;
        ws.Cell(2, 1).Value = $"Period: {data.From.ToString(DateFormat)} - {data.To.ToString(DateFormat)}";
        ws.Cell(3, 1).Value = $"Ukupno termina: {data.TotalAppointments}";

        var headers = new[] { "Osoblje", "Tip", "Ukupno", "Završeni", "Odobreni", "Odbijeni", "Na čekanju" };
        WriteExcelHeaders(ws, 5, headers);

        for (int i = 0; i < data.StaffStats.Count; i++)
        {
            var row = 6 + i;
            var item = data.StaffStats[i];
            ws.Cell(row, 1).Value = item.StaffName;
            ws.Cell(row, 2).Value = item.StaffType;
            ws.Cell(row, 3).Value = item.TotalAppointments;
            ws.Cell(row, 4).Value = item.Completed;
            ws.Cell(row, 5).Value = item.Approved;
            ws.Cell(row, 6).Value = item.Rejected;
            ws.Cell(row, 7).Value = item.Pending;
        }

        ws.Columns().AdjustToContents();

        return ToExcelResult(workbook, $"termini_{data.From:yyyyMMdd}_{data.To:yyyyMMdd}");
    }

    // ==================== HELPERS ====================

    private static byte[] GeneratePdf(string title, DateTime from, DateTime to, Action<ColumnDescriptor> contentBuilder)
    {
        using var stream = new MemoryStream();

        Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(2, Unit.Centimetre);
                page.PageColor(Colors.White);
                page.DefaultTextStyle(x => x.FontSize(10));

                page.Header().Column(col =>
                {
                    col.Item().Text(title).SemiBold().FontSize(18);
                    col.Item().PaddingTop(5).Text($"Period: {from.ToString(DateFormat)} - {to.ToString(DateFormat)}").FontSize(10).FontColor(Colors.Grey.Medium);
                    col.Item().PaddingTop(5).LineHorizontal(1).LineColor(Colors.Grey.Lighten2);
                });

                page.Content().PaddingVertical(10).Column(contentBuilder);

                page.Footer().AlignCenter().Text(x =>
                {
                    x.Span("Stronghold | Stranica ");
                    x.CurrentPageNumber();
                    x.Span(" / ");
                    x.TotalPages();
                });
            });
        }).GeneratePdf(stream);

        return stream.ToArray();
    }

    private static IContainer HeaderCellStyle(IContainer container)
    {
        return container.DefaultTextStyle(x => x.SemiBold())
            .PaddingVertical(5).PaddingHorizontal(3)
            .BorderBottom(1).BorderColor(Colors.Black);
    }

    private static IContainer CellStyle(IContainer container)
    {
        return container
            .PaddingVertical(4).PaddingHorizontal(3)
            .BorderBottom(1).BorderColor(Colors.Grey.Lighten2);
    }

    private static void StyleHeaderRow(IXLWorksheet ws, int row, int colCount)
    {
        for (int i = 1; i <= colCount; i++)
        {
            ws.Cell(row, i).Style.Font.Bold = true;
            ws.Cell(row, i).Style.Fill.BackgroundColor = XLColor.LightGray;
        }
    }

    private static void WriteExcelHeaders(IXLWorksheet ws, int row, string[] headers)
    {
        for (int i = 0; i < headers.Length; i++)
        {
            ws.Cell(row, i + 1).Value = headers[i];
            ws.Cell(row, i + 1).Style.Font.Bold = true;
            ws.Cell(row, i + 1).Style.Fill.BackgroundColor = XLColor.LightGray;
        }
    }

    private static ReportResult ToExcelResult(XLWorkbook workbook, string fileNameBase)
    {
        using var stream = new MemoryStream();
        workbook.SaveAs(stream);

        return new ReportResult
        {
            FileContent = stream.ToArray(),
            ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            FileName = $"{fileNameBase}.xlsx"
        };
    }
}
