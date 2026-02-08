using Stronghold.Application.Common;

namespace Stronghold.Application.Filters
{
    public class AppointmentQueryFilter : PaginationRequest
    {
        public string? OrderBy { get; set; }
    }
}
