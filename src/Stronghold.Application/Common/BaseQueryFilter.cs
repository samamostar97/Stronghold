namespace Stronghold.Application.Common;

public class BaseQueryFilter
{
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 10;
    public string? Search { get; set; }
    public string? OrderBy { get; set; }
    public bool OrderDescending { get; set; }
}
