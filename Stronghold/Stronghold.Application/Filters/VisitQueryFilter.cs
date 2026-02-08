using Stronghold.Application.Common;

namespace Stronghold.Application.Filters
{
    public class VisitQueryFilter : PaginationRequest
    {
        public string? Search { get; set; }
        public string? OrderBy { get; set; }
    }
}
