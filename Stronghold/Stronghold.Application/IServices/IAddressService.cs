using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;

namespace Stronghold.Application.IServices
{
    public interface IAddressService
    {
        Task<AddressResponse?> GetByUserIdAsync(int userId);
        Task<AddressResponse> UpsertAsync(int userId, UpsertAddressRequest request);
    }
}
