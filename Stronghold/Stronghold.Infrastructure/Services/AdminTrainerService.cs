using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.AdminNutritionistDTO;
using Stronghold.Application.DTOs.AdminTrainerDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
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
            if (emailExists) throw new InvalidOperationException("Email zauzet");
            if (phoneExists) throw new InvalidOperationException("Postoji trener sa ovim brojem");
            var nutritionistExists = await _repository.AsQueryable().AnyAsync(x=>x.FirstName.ToLower()==dto.FirstName.ToLower()&&x.Email.ToLower()==dto.Email.ToLower());
            if (nutritionistExists) throw new InvalidOperationException("Nemoguce dodati postojeceg trenera");
        }
        protected override async Task BeforeUpdateAsync(Trainer entity, UpdateTrainerDTO dto)
        {
            var emailExists = await _repository.AsQueryable().AnyAsync(x => x.Email.ToLower() == dto.Email.ToLower()&&x.Id!=entity.Id);
            var phoneExists = await _repository.AsQueryable().AnyAsync(x => x.PhoneNumber == dto.PhoneNumber && x.Id != entity.Id);
            if (emailExists) throw new InvalidOperationException("Email zauzet");
            if (phoneExists) throw new InvalidOperationException("Postoji trener sa ovim brojem");
            var nutritionistExists = await _repository.AsQueryable().AnyAsync(x => x.FirstName.ToLower() == dto.FirstName.ToLower() && x.Email.ToLower() == dto.Email.ToLower() && x.Id != entity.Id);
            if (nutritionistExists) throw new InvalidOperationException("Nemoguce dodati postojeceg nutricionistu");
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
