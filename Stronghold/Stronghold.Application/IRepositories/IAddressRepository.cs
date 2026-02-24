using Stronghold.Core.Entities;

namespace Stronghold.Application.IRepositories;

public interface IAddressRepository
{
    Task<Address?> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default);
    Task<Address> UpsertAsync(
        int userId,
        string street,
        string city,
        string postalCode,
        string country,
        CancellationToken cancellationToken = default);
}
