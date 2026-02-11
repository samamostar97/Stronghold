namespace Stronghold.Core.Entities;

public class ReminderDispatchLog : BaseEntity
{
    public string ReminderType { get; set; } = string.Empty;
    public string EntityType { get; set; } = string.Empty;
    public int EntityId { get; set; }
    public int DaysBeforeEvent { get; set; }
    public DateTime TargetDate { get; set; }
}
