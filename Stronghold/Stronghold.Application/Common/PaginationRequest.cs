using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.Common
{
    public class PaginationRequest
    {
        [Range(1, int.MaxValue, ErrorMessage = "PageNumber mora biti veći ili jednak 1")]
        public int PageNumber { get; set; } = 1;
        [Range(1, 100, ErrorMessage = "PageSize mora biti između 1 i 100")]
        public int PageSize { get; set; } = 10;
    }
}
