using Stronghold.Application.Common;

namespace Stronghold.Application.Filters
{
    public class ActiveMemberQueryFilter : PaginationRequest
    {
        public string? Name { get; set; }
    }
}
