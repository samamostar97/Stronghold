using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.AdminUsersDTO;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Services
{
    public class AdminUserService : IAdminUserService
    {
        private readonly IUserRepository _users;

        public AdminUserService(IUserRepository users)
        {
            _users = users;
        }

        public async Task<PagedResult<AdminUserTableRowDTO>> GetUsersAsync(string? search, PaginationRequest pagination)
        {
            if (pagination.PageNumber < 1) pagination.PageNumber = 1;
            if (pagination.PageSize < 1) pagination.PageSize = 10;
            if (pagination.PageSize > 200) pagination.PageSize = 200;

            var query = _users.AsQueryable()
                .AsNoTracking()
                .Where(u => !u.IsDeleted);

            if (!string.IsNullOrWhiteSpace(search))
            {
                var s = search.Trim();
                query = query.Where(u =>
                    u.FirstName.Contains(s) ||
                    u.LastName.Contains(s) ||
                    u.Username.Contains(s));
            }

            var dtoQuery = query
                .OrderBy(u => u.Id)
                .Select(u => new AdminUserTableRowDTO
                {
                    Id = u.Id,
                    Username = u.Username,
                    FirstName = u.FirstName,
                    LastName = u.LastName,
                    Email = u.Email,
                    PhoneNumber = u.PhoneNumber
                });

            var totalCount = await dtoQuery.CountAsync();

            var items = await dtoQuery
                .Skip((pagination.PageNumber - 1) * pagination.PageSize)
                .Take(pagination.PageSize)
                .ToListAsync();

            return new PagedResult<AdminUserTableRowDTO>
            {
                Items = items,
                TotalCount = totalCount,
                PageNumber = pagination.PageNumber
            };
        }

        public Task<AdminUserDetailsDTO?> GetByIdAsync(int id)
        {
            return _users.AsQueryable().AsNoTracking()
                .Where(u => u.Id == id)
                .Select(u => new AdminUserDetailsDTO
                {
                    Id = u.Id,
                    Username = u.Username,
                    FirstName = u.FirstName,
                    LastName = u.LastName,
                    Email = u.Email,
                    PhoneNumber = u.PhoneNumber,
                    Gender = u.Gender,
                    Role = u.Role,
                    ProfileImageUrl = u.ProfileImageUrl,
                    CreatedAt = u.CreatedAt,
                    UpdatedAt = u.UpdatedAt,
                    IsDeleted = u.IsDeleted
                })
                .FirstOrDefaultAsync();
        }

        public async Task<int> CreateAsync(AdminCreateUserDTO dto)
        {
            dto.Username = dto.Username.Trim();
            dto.Email = dto.Email.Trim();

            if (string.IsNullOrWhiteSpace(dto.Username)) throw new ArgumentException("Username is required.");
            if (string.IsNullOrWhiteSpace(dto.Email)) throw new ArgumentException("Email is required.");
            if (string.IsNullOrWhiteSpace(dto.Password) || dto.Password.Length < 6)
                throw new ArgumentException("Password must be at least 6 characters.");

            if (await _users.UsernameExistsAsync(dto.Username))
                throw new InvalidOperationException("Username already exists.");

            if (await _users.EmailExistsAsync(dto.Email))
                throw new InvalidOperationException("Email already exists.");

            var user = new User
            {
                FirstName = dto.FirstName.Trim(),
                LastName = dto.LastName.Trim(),
                Username = dto.Username,
                Email = dto.Email,
                PhoneNumber = dto.PhoneNumber.Trim(),
                Gender = dto.Gender,
                Role = dto.Role,
                ProfileImageUrl = dto.ProfileImageUrl,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                IsDeleted = false
            };

            await _users.AddAsync(user);
            return user.Id;
        }

        public async Task<bool> UpdateAsync(int id, AdminUpdateUserDTO dto)
        {
            var user = await _users.GetByIdAsync(id);
            if (user == null) return false;

            dto.Username = dto.Username.Trim();
            dto.Email = dto.Email.Trim();

            if (string.IsNullOrWhiteSpace(dto.Username)) throw new ArgumentException("Username is required.");
            if (string.IsNullOrWhiteSpace(dto.Email)) throw new ArgumentException("Email is required.");

            if (await _users.UsernameExistsAsync(dto.Username, excludeUserId: id))
                throw new InvalidOperationException("Username already exists.");

            if (await _users.EmailExistsAsync(dto.Email, excludeUserId: id))
                throw new InvalidOperationException("Email already exists.");

            user.FirstName = dto.FirstName.Trim();
            user.LastName = dto.LastName.Trim();
            user.Username = dto.Username;
            user.Email = dto.Email;
            user.PhoneNumber = dto.PhoneNumber.Trim();
            user.Gender = dto.Gender;
            user.Role = dto.Role;
            user.ProfileImageUrl = dto.ProfileImageUrl;

            if (!string.IsNullOrWhiteSpace(dto.NewPassword))
            {
                if (dto.NewPassword.Length < 6)
                    throw new ArgumentException("New password must be at least 6 characters.");

                user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.NewPassword);
            }

            await _users.UpdateAsync(user);
            return true;
        }

        public async Task<bool> SoftDeleteAsync(int id, int currentAdminId)
        {
            if (id == currentAdminId)
                throw new InvalidOperationException("Admin cannot delete own account.");

            var user = await _users.GetByIdAsync(id);
            if (user == null) return false;

            if (user.IsDeleted) return true;

            user.IsDeleted = true;
            await _users.UpdateAsync(user);
            return true;
        }

        public async Task<bool> RestoreAsync(int id)
        {
            var user = await _users.GetByIdAsync(id);
            if (user == null) return false;

            if (!user.IsDeleted) return true;

            user.IsDeleted = false;
            await _users.UpdateAsync(user);
            return true;
        }
    }
}