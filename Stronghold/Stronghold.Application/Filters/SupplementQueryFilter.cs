using Stronghold.Application.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.Filters
{
    public class SupplementQueryFilter : PaginationRequest
    {
        public string? Search {  get; set; }
        public string? OrderBy { get; set; }
        public int? SupplementCategoryId { get; set; }
    }
}
