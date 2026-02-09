using Mapster;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class AddressService : IAddressService
{
    private readonly StrongholdDbContext _context;

    public AddressService(StrongholdDbContext context)
    {
        _context = context;
    }

    public async Task<AddressResponse?> GetByUserIdAsync(int userId)
    {
        var address = await _context.Addresses
            .FirstOrDefaultAsync(a => a.UserId == userId);

        return address?.Adapt<AddressResponse>();
    }

    public async Task<AddressResponse> UpsertAsync(int userId, UpsertAddressRequest request)
    {
        var existing = await _context.Addresses
            .FirstOrDefaultAsync(a => a.UserId == userId);

        if (existing != null)
        {
            existing.Street = request.Street;
            existing.City = request.City;
            existing.PostalCode = request.PostalCode;
            existing.Country = request.Country;
        }
        else
        {
            existing = new Address
            {
                UserId = userId,
                Street = request.Street,
                City = request.City,
                PostalCode = request.PostalCode,
                Country = request.Country
            };
            _context.Addresses.Add(existing);
        }

        await _context.SaveChangesAsync();
        return existing.Adapt<AddressResponse>();
    }
}
