namespace Stronghold.Application.Exceptions
{
    public class EntityHasDependentsException : InvalidOperationException
    {
        public string EntityType { get; }
        public string DependentType { get; }

        public EntityHasDependentsException(string message) : base(message)
        {
            EntityType = string.Empty;
            DependentType = string.Empty;
        }

        public EntityHasDependentsException(string entityType, string dependentType)
            : base($"Nije moguće obrisati {entityType} jer ima povezane {dependentType}.")
        {
            EntityType = entityType;
            DependentType = dependentType;
        }

        public EntityHasDependentsException(string entityType, string dependentType, string customMessage)
            : base(customMessage)
        {
            EntityType = entityType;
            DependentType = dependentType;
        }
    }
}
