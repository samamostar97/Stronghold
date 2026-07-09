using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.Cart;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

/// <summary>
/// Korpa zivi na serveru - ista na svim uredjajima clana.
/// Zalihe se ovdje provjeravaju savjetodavno; autoritativna provjera je pri placanju.
/// </summary>
public class CartService : ICartService
{
    private const int MaxQuantityPerItem = 100;

    private readonly StrongholdDbContext _db;
    private readonly ICurrentUserService _currentUser;

    public CartService(StrongholdDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<CartResponse> GetMineAsync() => await BuildResponseAsync();

    public async Task<CartResponse> AddItemAsync(AddCartItemRequest request)
    {
        var userId = _currentUser.UserId;
        var supplement = await _db.Supplements.FindAsync(request.SupplementId)
            ?? throw new NotFoundException("Suplement ne postoji.");

        var item = await _db.CartItems
            .FirstOrDefaultAsync(ci => ci.UserId == userId && ci.SupplementId == request.SupplementId);
        var newQuantity = (item?.Quantity ?? 0) + request.Quantity;
        EnsureQuantityAvailable(supplement, newQuantity);

        if (item == null)
        {
            _db.CartItems.Add(new CartItem
            {
                UserId = userId,
                SupplementId = request.SupplementId,
                Quantity = newQuantity,
                AddedAt = DateTime.UtcNow
            });
            try
            {
                await _db.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                // paralelno dodavanje s drugog uredjaja pogodilo unique index - ponovi kao izmjenu
                _db.ChangeTracker.Clear();
                var existing = await _db.CartItems.FirstAsync(ci =>
                    ci.UserId == userId && ci.SupplementId == request.SupplementId);
                var merged = existing.Quantity + request.Quantity;
                EnsureQuantityAvailable(supplement, merged);
                existing.Quantity = merged;
                await _db.SaveChangesAsync();
            }
        }
        else
        {
            item.Quantity = newQuantity;
            await _db.SaveChangesAsync();
        }

        return await BuildResponseAsync();
    }

    public async Task<CartResponse> UpdateItemAsync(int supplementId, UpdateCartItemRequest request)
    {
        var userId = _currentUser.UserId;
        var item = await _db.CartItems
            .Include(ci => ci.Supplement)
            .FirstOrDefaultAsync(ci => ci.UserId == userId && ci.SupplementId == supplementId)
            ?? throw new NotFoundException("Artikal nije u korpi.");

        EnsureQuantityAvailable(item.Supplement, request.Quantity);
        item.Quantity = request.Quantity;
        await _db.SaveChangesAsync();
        return await BuildResponseAsync();
    }

    public async Task<CartResponse> RemoveItemAsync(int supplementId)
    {
        // idempotentno - uklanjanje vec uklonjene stavke nije greska
        await _db.CartItems
            .Where(ci => ci.UserId == _currentUser.UserId && ci.SupplementId == supplementId)
            .ExecuteDeleteAsync();
        return await BuildResponseAsync();
    }

    public async Task<CartResponse> ClearAsync()
    {
        await _db.CartItems
            .Where(ci => ci.UserId == _currentUser.UserId)
            .ExecuteDeleteAsync();
        return await BuildResponseAsync();
    }

    private static void EnsureQuantityAvailable(Supplement supplement, int quantity)
    {
        if (quantity > MaxQuantityPerItem)
        {
            throw new BusinessException($"Maksimalna količina po artiklu je {MaxQuantityPerItem}.");
        }
        if (supplement.StockQuantity < quantity)
        {
            throw new BusinessException(
                $"Nema dovoljno zaliha za '{supplement.Name}' (dostupno: {supplement.StockQuantity}).");
        }
    }

    private async Task<CartResponse> BuildResponseAsync()
    {
        var userId = _currentUser.UserId;
        var items = await _db.CartItems.AsNoTracking()
            .Where(ci => ci.UserId == userId)
            .OrderBy(ci => ci.AddedAt)
            .ThenBy(ci => ci.Id)
            .Select(ci => new CartItemResponse
            {
                SupplementId = ci.SupplementId,
                Name = ci.Supplement.Name,
                Price = ci.Supplement.Price,
                StockQuantity = ci.Supplement.StockQuantity,
                HasImage = ci.Supplement.ImageData != null,
                Quantity = ci.Quantity,
                Subtotal = ci.Supplement.Price * ci.Quantity
            })
            .ToListAsync();

        return new CartResponse { Items = items, Total = items.Sum(i => i.Subtotal) };
    }
}
