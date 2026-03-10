namespace Stronghold.Application.Interfaces;

public interface IUndoService
{
    Task UndoDeleteAsync(string entityType, int entityId);
}
