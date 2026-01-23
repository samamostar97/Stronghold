using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminReportsDTO
{
    public class WeekdayVisitsDTO
    {
        public DayOfWeek Day { get; set; }
        public int Count { get; set; }
    }
}
