using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Reports.DTOs
{
    public class SlowMovingProductQueryFilter : PaginationRequest
    {
        public int DaysToAnalyze { get; set; } = 30;
        public string? Search { get; set; }
        public string? OrderBy { get; set; }
    }
}
