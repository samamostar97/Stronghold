using Stronghold.Application.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.Filters
{
    public class SupplementCategoryQueryFilter: PaginationRequest
    {
        public string? Search { get; set; }
        public string? OrderBy { get; set; }

    }
}
