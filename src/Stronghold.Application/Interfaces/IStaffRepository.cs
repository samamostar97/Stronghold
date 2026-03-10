using Stronghold.Domain.Entities;

namespace Stronghold.Application.Interfaces;

public interface IStaffRepository : IRepository<Staff>
{
    Task<Staff?> GetByEmailAsync(string email);
}
