using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.AdminSeminarDTO;
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
    public class AdminSeminarService : BaseService<Seminar, SeminarDTO, CreateSeminarDTO, UpdateSeminarDTO, SeminarQueryFilter, int>, IAdminSeminarService
    {
        public AdminSeminarService(IRepository<Seminar, int> repository, IMapper mapper) : base(repository, mapper)
        {
        }
        protected override async Task BeforeCreateAsync(Seminar entity, CreateSeminarDTO dto)
        {
            var seminarExists = await _repository.AsQueryable().AnyAsync(x => x.Topic.ToLower() == dto.Topic.ToLower() && x.EventDate == dto.EventDate);
            if (seminarExists) throw new InvalidOperationException("Seminar vec postoji");
            if (dto.EventDate < DateTime.UtcNow)
                throw new InvalidOperationException("Nemoguce unijeti datum u proslosti");

        }
        protected override async Task BeforeUpdateAsync(Seminar entity, UpdateSeminarDTO dto)
        {
            var seminarExists = await _repository.AsQueryable().AnyAsync(x => x.Topic.ToLower() == dto.Topic.ToLower() && x.EventDate == dto.EventDate&&x.Id!=entity.Id);
            if (seminarExists) throw new InvalidOperationException("Seminar sa ovim imenom vec postoji");
            if(dto.EventDate!=null)
            {
                if (dto.EventDate < DateTime.UtcNow)
                    throw new InvalidOperationException("Nemoguce unijeti datum u proslosti");
            }
            
        }
        protected override IQueryable<Seminar> ApplyFilter(IQueryable<Seminar> query, SeminarQueryFilter? filter)
        {
            if (filter == null)
                return query;
            if(!string.IsNullOrEmpty(filter.Search))
                query=query.Where(x=>x.SpeakerName.ToLower().Contains(filter.Search)
                                         ||x.Topic.ToLower().Contains(filter.Search.ToLower()));
            if(!string.IsNullOrEmpty(filter.OrderBy))
            {
                query = filter.OrderBy.ToLower() switch
                {
                    "topic" => query.OrderBy(x => x.Topic),
                    "speakername" => query.OrderBy(x => x.SpeakerName),
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
