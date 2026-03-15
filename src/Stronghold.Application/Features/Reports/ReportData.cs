namespace Stronghold.Application.Features.Reports;

public class RevenueReportData
{
    public DateTime From { get; set; }
    public DateTime To { get; set; }
    public decimal OrderRevenue { get; set; }
    public decimal MembershipRevenue { get; set; }
    public decimal TotalRevenue { get; set; }
    public int OrderCount { get; set; }
    public int MembershipCount { get; set; }
    public List<OrderRevenueItem> OrderItems { get; set; } = new();
    public List<MembershipRevenueItem> MembershipItems { get; set; } = new();
}

public class OrderRevenueReportData
{
    public DateTime From { get; set; }
    public DateTime To { get; set; }
    public decimal TotalRevenue { get; set; }
    public int TotalOrders { get; set; }
    public List<OrderRevenueItem> Items { get; set; } = new();
}

public class OrderRevenueItem
{
    public int OrderId { get; set; }
    public string UserName { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

public class MembershipRevenueReportData
{
    public DateTime From { get; set; }
    public DateTime To { get; set; }
    public decimal TotalRevenue { get; set; }
    public int TotalMemberships { get; set; }
    public List<MembershipRevenueItem> Items { get; set; } = new();
}

public class MembershipRevenueItem
{
    public int MembershipId { get; set; }
    public string UserName { get; set; } = string.Empty;
    public string PackageName { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
}

public class UsersReportData
{
    public DateTime From { get; set; }
    public DateTime To { get; set; }
    public int TotalNewUsers { get; set; }
    public List<UserReportItem> Users { get; set; } = new();
}

public class UserReportItem
{
    public int Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

public class ProductsReportData
{
    public DateTime From { get; set; }
    public DateTime To { get; set; }
    public List<TopSellingProductItem> TopSelling { get; set; } = new();
    public List<StockLevelItem> StockLevels { get; set; } = new();
}

public class TopSellingProductItem
{
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string CategoryName { get; set; } = string.Empty;
    public int TotalQuantitySold { get; set; }
    public decimal TotalRevenue { get; set; }
}

public class StockLevelItem
{
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string CategoryName { get; set; } = string.Empty;
    public int StockQuantity { get; set; }
    public decimal Price { get; set; }
}

public class AppointmentsReportData
{
    public DateTime From { get; set; }
    public DateTime To { get; set; }
    public int TotalAppointments { get; set; }
    public List<StaffAppointmentItem> StaffStats { get; set; } = new();
}

public class StaffAppointmentItem
{
    public int StaffId { get; set; }
    public string StaffName { get; set; } = string.Empty;
    public string StaffType { get; set; } = string.Empty;
    public int TotalAppointments { get; set; }
    public int Completed { get; set; }
    public int Approved { get; set; }
    public int Rejected { get; set; }
    public int Pending { get; set; }
}
