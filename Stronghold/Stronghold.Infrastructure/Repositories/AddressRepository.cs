using Microsoft.EntityFrameworkCore;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Repositories;

public class AddressRepository : IAddressRepository
{
    private readonly StrongholdDbContext _context;

    public AddressRepository(StrongholdDbContext context)
    {
        _context = context;
    }

    public Task<Address?> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        return _context.Addresses
            .FirstOrDefaultAsync(x => x.UserId == userId && !x.IsDeleted, cancellationToken);
    }

    public async Task<Address> UpsertAsync(
        int userId,
        string street,
        string city,
        string postalCode,
        string country,
        CancellationToken cancellationToken = default)
    {
        var address = await _context.Addresses
            .FirstOrDefaultAsync(x => x.UserId == userId && !x.IsDeleted, cancellationToken);

        if (address is null)
        {
            address = new Address
            {
                UserId = userId,
                Street = street,
                City = city,
                PostalCode = postalCode,
                Country = country
            };

            await _context.Addresses.AddAsync(address, cancellationToken);
        }
        else
        {
            address.Street = street;
            address.City = city;
            address.PostalCode = postalCode;
            address.Country = country;
            _context.Addresses.Update(address);
        }

        await _context.SaveChangesAsync(cancellationToken);
        return address;
    }
}
