using Stronghold.Application.Common;

namespace Stronghold.Application.Filters
{
    public class MembershipQueryFilter : PaginationRequest
    {
        public string? OrderBy { get; set; }
    }
}
