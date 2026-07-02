using Mapster;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.Profile;
using Stronghold.Application.DTOs.Users;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;
using Stronghold.Infrastructure.Security;

namespace Stronghold.Infrastructure.Services;

public class ProfileService : IProfileService
{
    private readonly StrongholdDbContext _db;
    private readonly ICurrentUserService _currentUser;

    public ProfileService(StrongholdDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<UserResponse> GetAsync()
    {
        var response = await _db.Users.AsNoTracking()
            .Where(u => u.Id == _currentUser.UserId)
            .ProjectToType<UserResponse>()
            .FirstOrDefaultAsync();

        return response ?? throw new NotFoundException("Korisnik ne postoji.");
    }

    public async Task<UserResponse> UpdateAsync(UpdateProfileRequest request)
    {
        var user = await GetUserAsync();

        if (await _db.Users.AnyAsync(u => u.Email == request.Email && u.Id != user.Id))
        {
            throw new BusinessException("Nalog sa ovom e-mail adresom već postoji.");
        }
        if (request.CityId.HasValue && !await _db.Cities.AnyAsync(c => c.Id == request.CityId))
        {
            throw new BusinessException("Odabrani grad ne postoji.");
        }

        user.FirstName = request.FirstName;
        user.LastName = request.LastName;
        user.Email = request.Email;
        user.Phone = request.Phone;
        user.StreetAddress = request.StreetAddress;
        user.CityId = request.CityId;
        if (!string.IsNullOrWhiteSpace(request.ImageBase64))
        {
            user.ImageData = ImageValidator.DecodeAndValidate(request.ImageBase64);
        }

        await _db.SaveChangesAsync();
        return await GetAsync();
    }

    public async Task ChangePasswordAsync(ChangePasswordRequest request)
    {
        var user = await GetUserAsync();

        if (!PasswordHasher.Verify(request.OldPassword, user.PasswordSalt, user.PasswordHash))
        {
            throw new BusinessException("Trenutna lozinka nije ispravna.");
        }

        user.PasswordSalt = PasswordHasher.GenerateSalt();
        user.PasswordHash = PasswordHasher.Hash(request.NewPassword, user.PasswordSalt);
        await _db.SaveChangesAsync();
    }

    public async Task<(byte[] Data, string ContentType)> GetImageAsync()
    {
        var image = await _db.Users.AsNoTracking()
            .Where(u => u.Id == _currentUser.UserId)
            .Select(u => u.ImageData)
            .FirstOrDefaultAsync();

        if (image == null)
        {
            throw new NotFoundException("Nemate postavljenu profilnu sliku.");
        }
        return (image, ImageValidator.GetContentType(image) ?? "application/octet-stream");
    }

    private async Task<User> GetUserAsync()
    {
        return await _db.Users.FindAsync(_currentUser.UserId)
            ?? throw new NotFoundException("Korisnik ne postoji.");
    }
}
