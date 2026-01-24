using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.AdminNutritionistDTO;
using Stronghold.Application.DTOs.AdminTrainerDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Exceptions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Infrastructure.Services
{
    public class AdminTrainerService : BaseService<Trainer, TrainerDTO, CreateTrainerDTO, UpdateTrainerDTO, TrainerQueryFilter, int>,IAdminTrainerService
    {
        public AdminTrainerService(IRepository<Trainer, int> repository, IMapper mapper) : base(repository, mapper)
        {
        }
        protected override async Task BeforeCreateAsync(Trainer entity, CreateTrainerDTO dto)
        {
            var emailExists = await _repository.AsQueryable().AnyAsync(x=>x.Email.ToLower()==dto.Email.ToLower());
            var phoneExists = await _repository.AsQueryable().AnyAsync(x => x.PhoneNumber == dto.PhoneNumber);
            if (emailExists) throw new ConflictException("Email zauzet");
            if (phoneExists) throw new ConflictException("Postoji trener sa ovim brojem");

        }
        protected override async Task BeforeUpdateAsync(Trainer entity, UpdateTrainerDTO dto)
        {
            if (!string.IsNullOrEmpty(dto.Email)) { 
            var emailExists = await _repository.AsQueryable().AnyAsync(x => x.Email.ToLower() == dto.Email.ToLower()&&x.Id!=entity.Id);
            if (emailExists) throw new ConflictException("Email zauzet");
            }
            if (!string.IsNullOrEmpty(dto.PhoneNumber)) { 
            var phoneExists = await _repository.AsQueryable().AnyAsync(x => x.PhoneNumber == dto.PhoneNumber && x.Id != entity.Id);
            if (phoneExists) throw new ConflictException("Postoji trener sa ovim brojem");
            }
        }
        protected override IQueryable<Trainer> ApplyFilter(IQueryable<Trainer> query, TrainerQueryFilter? filter)
        {
            if (filter == null)
                return query;
            if(!string.IsNullOrEmpty(filter.Search))
                query=query.Where(x=>x.FirstName.ToLower().Contains(filter.Search.ToLower())
                                    ||x.LastName.ToLower().Contains(filter.Search.ToLower()));
            if(!string.IsNullOrEmpty(filter.OrderBy))
            {
                query = filter.OrderBy.ToLower() switch
                {
                    "firstname" => query.OrderBy(x => x.FirstName),
                    "lastname" => query.OrderBy(x => x.LastName),
                    "createdatdesc" => query.OrderByDescending(x => x.CreatedAt),
                    _ => query.OrderBy(x => x.CreatedAt)
                };
                return query;
            }
            query = query.OrderBy(x => x.CreatedAt);
            return query;
        }
    }
}
