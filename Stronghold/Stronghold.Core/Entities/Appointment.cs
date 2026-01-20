namespace Stronghold.Core.Entities;

    public class Appointment : BaseEntity
    {
        public int UserId { get; set; }
        public int? TrainerId { get; set; }
        public int? NutritionistId { get; set; }
        public DateTime AppointmentDate { get; set; }

        // Navigation properties
        public User User { get; set; } = null!;
        public Trainer? Trainer { get; set; }
        public Nutritionist? Nutritionist { get; set; }
    }

