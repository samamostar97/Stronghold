namespace Stronghold.Core.Entities;

    public class GymVisit : BaseEntity
    {
        public int UserId { get; set; }
        public DateTime CheckInTime { get; set; }
        public DateTime? CheckOutTime { get; set; }

        // Computed in application logic: CheckOutTime - CheckInTime
        public TimeSpan? Duration => CheckOutTime.HasValue ? CheckOutTime.Value - CheckInTime : null;

        // Navigation property
        public User User { get; set; } = null!;
    }

