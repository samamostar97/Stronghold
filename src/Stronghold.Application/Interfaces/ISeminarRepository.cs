using Stronghold.Domain.Entities;

namespace Stronghold.Application.Interfaces;

public interface ISeminarRepository : IRepository<Seminar>
{
    Task<Seminar?> GetByIdWithRegistrationsAsync(int id);
}
