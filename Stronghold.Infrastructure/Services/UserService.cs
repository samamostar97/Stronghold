using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.Users;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;
using Stronghold.Infrastructure.Security;

namespace Stronghold.Infrastructure.Services;

public class UserService : BaseCrudService<User, UserResponse, UserSearch, UserInsertRequest, UserUpdateRequest>,
    IUserService
{
    private readonly ICurrentUserService _currentUser;

    public UserService(StrongholdDbContext db, ICurrentUserService currentUser) : base(db)
    {
        _currentUser = currentUser;
    }

    protected override IQueryable<User> ApplyFilter(IQueryable<User> query, UserSearch search)
    {
        if (!string.IsNullOrWhiteSpace(search.Text))
        {
            var text = search.Text.Trim();
            query = query.Where(u =>
                u.FirstName.Contains(text) ||
                u.LastName.Contains(text) ||
                u.Username.Contains(text));
        }
        return query.OrderByDescending(u => u.Id);
    }

    protected override async Task BeforeInsertAsync(User entity, UserInsertRequest request)
    {
        if (await Db.Users.AnyAsync(u => u.Username == request.Username))
        {
            throw new BusinessException("Korisničko ime je već zauzeto. Odaberite drugo.");
        }
        if (await Db.Users.AnyAsync(u => u.Email == request.Email))
        {
            throw new BusinessException("Nalog sa ovom e-mail adresom već postoji.");
        }
        await ValidateCityAsync(request.CityId);

        entity.PasswordSalt = PasswordHasher.GenerateSalt();
        entity.PasswordHash = PasswordHasher.Hash(request.Password, entity.PasswordSalt);
        entity.CreatedAt = DateTime.UtcNow;
        if (!string.IsNullOrWhiteSpace(request.ImageBase64))
        {
            entity.ImageData = ImageValidator.DecodeAndValidate(request.ImageBase64);
        }
    }

    protected override async Task BeforeUpdateAsync(User entity, UserUpdateRequest request)
    {
        if (await Db.Users.AnyAsync(u => u.Email == request.Email && u.Id != entity.Id))
        {
            throw new BusinessException("Nalog sa ovom e-mail adresom već postoji.");
        }
        await ValidateCityAsync(request.CityId);

        // admin koji uredjuje korisnika ne unosi staru lozinku; nova se postavlja samo ako je popunjena
        if (!string.IsNullOrWhiteSpace(request.NewPassword))
        {
            entity.PasswordSalt = PasswordHasher.GenerateSalt();
            entity.PasswordHash = PasswordHasher.Hash(request.NewPassword, entity.PasswordSalt);
        }
        if (!string.IsNullOrWhiteSpace(request.ImageBase64))
        {
            entity.ImageData = ImageValidator.DecodeAndValidate(request.ImageBase64);
        }
    }

    protected override async Task BeforeDeleteAsync(User entity)
    {
        if (entity.Id == _currentUser.UserId)
        {
            throw new BusinessException("Ne možete obrisati vlastiti nalog.");
        }

        var reasons = new List<string>();
        if (await Db.Memberships.AnyAsync(m => m.UserId == entity.Id))
        {
            reasons.Add("članarine");
        }
        if (await Db.Orders.AnyAsync(o => o.UserId == entity.Id))
        {
            reasons.Add("narudžbe");
        }
        if (await Db.Appointments.AnyAsync(a => a.UserId == entity.Id))
        {
            reasons.Add("termine");
        }
        if (await Db.SeminarRegistrations.AnyAsync(r => r.UserId == entity.Id))
        {
            reasons.Add("prijave na seminare");
        }
        if (await Db.Reviews.AnyAsync(r => r.UserId == entity.Id))
        {
            reasons.Add("recenzije");
        }

        if (reasons.Count > 0)
        {
            throw new BusinessException(
                $"Korisnik se ne može obrisati jer ima evidentirane: {string.Join(", ", reasons)}.");
        }
    }

    private async Task ValidateCityAsync(int? cityId)
    {
        if (cityId.HasValue && !await Db.Cities.AnyAsync(c => c.Id == cityId))
        {
            throw new BusinessException("Odabrani grad ne postoji.");
        }
    }

    public async Task<(byte[] Data, string ContentType)> GetImageAsync(int id)
    {
        var image = await Db.Users.AsNoTracking()
            .Where(u => u.Id == id)
            .Select(u => u.ImageData)
            .FirstOrDefaultAsync();

        if (image == null)
        {
            throw new NotFoundException("Korisnik nema profilnu sliku.");
        }
        return (image, ImageValidator.GetContentType(image) ?? "application/octet-stream");
    }
}
