using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Core.Entities
{
    public class Progress
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public decimal Weight { get; set; }
        public decimal? BodyFatPercentage { get; set; }
        public decimal? WaistMeasurement { get; set; }
        public decimal? ArmMeasurement { get; set; }
        public string Notes { get; set; }
        public DateTime MeasurementDate { get; set; }
        public DateTime CreatedAt { get; set; }

        public User User { get; set; }
    }
}
