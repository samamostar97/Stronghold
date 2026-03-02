using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.Common
{
    public class PagedResult<T>
    {
        public List<T> Items { get; set; } = new();
        public int TotalCount { get; set; }
        public int PageNumber { get; set; }

        /// <summary>Optional aggregate — total monetary amount across all pages.</summary>
        public decimal? TotalAmount { get; set; }

        /// <summary>Optional aggregate — count of "active" items across all pages.</summary>
        public int? ActiveCount { get; set; }
    }
}
