using BCrypt.Net;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;

namespace Stronghold.Infrastructure.Services
{
    public class UserManagementService : BaseService<User, UserResponse, CreateUserRequest, UpdateUserRequest, UserQueryFilter, int>, IUserManagementService
    {
        private readonly IFileStorageService _fileStorageService;

        public UserManagementService(
            IRepository<User, int> repository,
            IMapper mapper,
            IFileStorageService fileStorageService) : base(repository, mapper)
        {
            _fileStorageService = fileStorageService;
        }

        protected override async Task BeforeCreateAsync(User entity, CreateUserRequest dto)
        {
            var usernameExists = await _repository.AsQueryable().AnyAsync(x => x.Username.ToLower() == dto.Username.ToLower());
            if (usernameExists)
                throw new ConflictException("Korisničko ime je već zauzeto.");

            var emailExists = await _repository.AsQueryable().AnyAsync(x => x.Email.ToLower() == dto.Email.ToLower());
            if (emailExists)
                throw new ConflictException("Email je već zauzet.");

            var phoneNumberExists = await _repository.AsQueryable().AnyAsync(x => x.PhoneNumber == dto.PhoneNumber);
            if (phoneNumberExists)
                throw new ConflictException("Korisnik sa ovim brojem telefona već postoji.");

            entity.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password);
            entity.Role = Role.GymMember;
        }

        protected override async Task BeforeUpdateAsync(User entity, UpdateUserRequest dto)
        {
            if (!string.IsNullOrEmpty(dto.Username))
            {
                var usernameExists = await _repository.AsQueryable()
                    .AnyAsync(x => x.Username.ToLower() == dto.Username.ToLower() && x.Id != entity.Id);
                if (usernameExists)
                    throw new ConflictException("Korisničko ime je već zauzeto.");
            }

            if (!string.IsNullOrEmpty(dto.PhoneNumber))
            {
                var phoneNumberExists = await _repository.AsQueryable()
                    .AnyAsync(x => x.PhoneNumber == dto.PhoneNumber && x.Id != entity.Id);
                if (phoneNumberExists)
                    throw new ConflictException("Korisnik sa ovim brojem telefona već postoji.");
            }

            if (!string.IsNullOrEmpty(dto.Email))
            {
                var emailExists = await _repository.AsQueryable()
                    .AnyAsync(x => x.Email.ToLower() == dto.Email.ToLower() && x.Id != entity.Id);
                if (emailExists)
                    throw new ConflictException("Email je već zauzet.");
            }

            if (!string.IsNullOrEmpty(dto.Password))
            {
                entity.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password);
            }
        }

        protected override Task BeforeDeleteAsync(User entity)
        {
            if (entity.Role == Role.Admin)
                throw new InvalidOperationException("Nije moguće obrisati admin nalog.");

            return Task.CompletedTask;
        }

        protected override IQueryable<User> ApplyFilter(IQueryable<User> query, UserQueryFilter filter)
        {
            // Exclude admin users from all lists
            query = query.Where(x => x.Role != Role.Admin);

            if (!string.IsNullOrEmpty(filter.Name))
                query = query.Where(x => x.FirstName.ToLower().Contains(filter.Name.ToLower())
                                   || x.LastName.ToLower().Contains(filter.Name.ToLower()));

            if (!string.IsNullOrEmpty(filter.OrderBy))
            {
                return filter.OrderBy.ToLower() switch
                {
                    "firstname" => query.OrderBy(x => x.FirstName),
                    "lastname" => query.OrderBy(x => x.LastName),
                    "datedesc" => query.OrderByDescending(x => x.CreatedAt),
                    _ => query.OrderBy(x => x.CreatedAt)
                };
            }

            return query.OrderBy(x => x.CreatedAt);
        }

        public async Task<UserResponse> UploadImageAsync(int userId, FileUploadRequest fileRequest)
        {
            var user = await _repository.GetByIdAsync(userId);

            if (user == null)
                throw new KeyNotFoundException("Korisnik nije pronađen.");

            if (!string.IsNullOrEmpty(user.ProfileImageUrl))
            {
                await _fileStorageService.DeleteAsync(user.ProfileImageUrl);
            }

            var uploadResult = await _fileStorageService.UploadAsync(fileRequest, "users", userId.ToString());

            if (!uploadResult.Success)
                throw new InvalidOperationException(uploadResult.ErrorMessage);

            user.ProfileImageUrl = uploadResult.FileUrl;
            await _repository.UpdateAsync(user);

            return _mapper.Map<UserResponse>(user);
        }

        public async Task<bool> DeleteImageAsync(int userId)
        {
            var user = await _repository.GetByIdAsync(userId);

            if (user == null)
                throw new KeyNotFoundException("Korisnik nije pronađen.");

            if (string.IsNullOrEmpty(user.ProfileImageUrl))
                return false;

            var deleted = await _fileStorageService.DeleteAsync(user.ProfileImageUrl);

            user.ProfileImageUrl = null;
            await _repository.UpdateAsync(user);

            return deleted;
        }
    }
}
