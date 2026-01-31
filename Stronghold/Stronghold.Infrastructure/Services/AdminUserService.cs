using BCrypt.Net;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.AdminUsersDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Core.Exceptions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Infrastructure.Services
{
    public class AdminUserService : BaseService<User, UserDTO, CreateUserDTO, UpdateUserDTO, UserQueryFilter, int>, IAdminUserService
    {
        public AdminUserService(IRepository<User, int> repository, IMapper mapper) : base(repository, mapper)
        {
        }
        protected override async Task BeforeCreateAsync(User entity, CreateUserDTO dto)
        {
            var usernameExists = await _repository.AsQueryable().AnyAsync(x=>x.Username == dto.Username);
            if (usernameExists)
                throw new ConflictException("Username zauzet");
            var emailExists = await _repository.AsQueryable().AnyAsync(x => x.Email == dto.Email);
            if (emailExists)
                throw new ConflictException("Email zauzet");
            var phoneNumberExists = await _repository.AsQueryable().AnyAsync(x => x.PhoneNumber == dto.PhoneNumber);
            if (phoneNumberExists)
                throw new ConflictException("Korisnik sa ovim brojem telefona vec postoji");

            entity.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password);
            entity.Role = Core.Enums.Role.GymMember;
        }
        protected override async Task BeforeUpdateAsync(User entity, UpdateUserDTO dto)
        {
            if(!string.IsNullOrEmpty(dto.Username))
            { 
            var usernameExists = await _repository.AsQueryable()
                                                  .AnyAsync(x => x.Username.ToLower() == dto.Username.ToLower() && x.Id != entity.Id);
                if (usernameExists)
                    throw new ConflictException("Username zauzet");
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
                                                      .AnyAsync(x => x.Email == dto.Email && x.Id != entity.Id);
                if (emailExists)
                    throw new ConflictException("Email zauzet");
            }
            if(!string.IsNullOrEmpty(dto.Password))
            {
                entity.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password);
            }
        }
        protected override Task BeforeDeleteAsync(User entity)
        {
            if (entity.Role == Role.Admin)
                throw new InvalidOperationException("Nemoguće obrisati admin account.");

            return Task.CompletedTask;
        }
        protected override IQueryable<User> ApplyFilter(IQueryable<User> query, UserQueryFilter? filter)
        {
            if (filter == null)
                return query;
            if (!string.IsNullOrEmpty(filter.Name))
                query = query.Where(x => x.FirstName.ToLower().Contains(filter.Name.ToLower())
                                   || x.LastName.ToLower().Contains(filter.Name.ToLower()));
            if(!string.IsNullOrEmpty(filter.OrderBy))
            {
                query = filter.OrderBy.ToLower() switch
                {
                    "firstname" => query.OrderBy(x => x.FirstName),
                    "lastname" => query.OrderBy(x => x.LastName),
                    "datedesc" => query.OrderByDescending(x => x.CreatedAt),
                    _ => query.OrderBy(x => x.CreatedAt)
                };
                return query;

            }
            query = query.OrderBy(x => x.CreatedAt);
            return query;
        }
    }
}
