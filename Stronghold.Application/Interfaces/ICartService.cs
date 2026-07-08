using Stronghold.Application.DTOs.Cart;

namespace Stronghold.Application.Interfaces;

// Korpa prijavljenog clana - server je izvor istine.
public interface ICartService
{
    Task<CartResponse> GetMineAsync();

    // Dodaje suplement ili povecava kolicinu postojece stavke.
    Task<CartResponse> AddItemAsync(AddCartItemRequest request);

    Task<CartResponse> UpdateItemAsync(int supplementId, UpdateCartItemRequest request);

    Task<CartResponse> RemoveItemAsync(int supplementId);

    Task<CartResponse> ClearAsync();
}
