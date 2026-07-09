using Stronghold.Application.DTOs.Cart;

namespace Stronghold.Application.Interfaces;

/// <summary>Korpa prijavljenog clana - server je izvor istine.</summary>
public interface ICartService
{
    Task<CartResponse> GetMineAsync();

    /// <summary>Dodaje suplement ili povecava kolicinu postojece stavke.</summary>
    Task<CartResponse> AddItemAsync(AddCartItemRequest request);

    Task<CartResponse> UpdateItemAsync(int supplementId, UpdateCartItemRequest request);

    Task<CartResponse> RemoveItemAsync(int supplementId);

    Task<CartResponse> ClearAsync();
}
