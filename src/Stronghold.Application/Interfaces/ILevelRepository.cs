using Stronghold.Domain.Entities;

namespace Stronghold.Application.Interfaces;

public interface ILevelRepository : IRepository<Level>
{
    Task<Level?> GetByXpAsync(int xp);
    Task<List<Level>> GetAllOrderedAsync();
}
