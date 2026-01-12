using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Users;

public class UserService : IUserService
{
    private readonly IUserRepository _users;

    public UserService(IUserRepository users)
    {
        _users = users;
    }

    public Task<PagedResult<User>> SearchAsync(UserSearchRequest request)
        => _users.SearchPagedAsync(request);

    public async Task<User> GetByIdAsync(int id)
    {
        var user = await _users.GetByIdAsync(id);
        if (user == null)
            throw new KeyNotFoundException($"User with id={id} not found.");

        return user;
    }

    public async Task<int> CreateAsync(UserInsertRequest request)
    {
        request.Username = request.Username.Trim();
        request.Email = request.Email.Trim();

        var query = _users.AsQueryable().AsNoTracking();

        var usernameTaken = await query.AnyAsync(x => x.Username == request.Username);
        if (usernameTaken)
            throw new InvalidOperationException("Username is already taken.");

        var emailTaken = await query.AnyAsync(x => x.Email == request.Email);
        if (emailTaken)
            throw new InvalidOperationException("Email is already taken.");

        var user = new User
        {
            Username = request.Username,
            Email = request.Email,
            Role = request.Role,
            FirstName = request.FirstName,
            LastName = request.LastName,
            CreatedAt = DateTime.UtcNow
        };

        // ✅ BCrypt hashing
        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

        await _users.AddAsync(user);
        return user.Id;
    }

    public async Task UpdateAsync(int id, UpdateUserRequest request)
    {
        var user = await _users.GetByIdAsync(id);
        if (user == null)
            throw new KeyNotFoundException($"User with id={id} not found.");

        request.Username = request.Username.Trim();
        request.Email = request.Email.Trim();

        var query = _users.AsQueryable().AsNoTracking();

        var usernameTaken = await query.AnyAsync(x => x.Username == request.Username && x.Id != id);
        if (usernameTaken)
            throw new InvalidOperationException("Username is already taken.");

        var emailTaken = await query.AnyAsync(x => x.Email == request.Email && x.Id != id);
        if (emailTaken)
            throw new InvalidOperationException("Email is already taken.");

        user.Username = request.Username;
        user.Email = request.Email;
        user.FirstName = request.FirstName;
        user.LastName = request.LastName;
        user.UpdatedAt = DateTime.UtcNow;

        // ✅ Only update hash if admin provided a new password
        if (!string.IsNullOrWhiteSpace(request.NewPassword))
        {
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
        }

        await _users.UpdateAsync(user);
    }

    public async Task DeleteAsync(int id)
    {
        var user = await _users.GetByIdAsync(id);
        if (user == null)
            return; // or throw

        await _users.DeleteAsync(user);
    }
}
