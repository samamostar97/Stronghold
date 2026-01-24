using MapsterMapper;
using Stronghold.Application.DTOs.AdminFaqDTO;
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
    public class AdminFaqService : BaseService<FAQ, FaqDTO, CreateFaqDTO, UpdateFaqDTO, FaqQueryFilter, int>, IAdminFaqService
    {
        public AdminFaqService(IRepository<FAQ, int> repository, IMapper mapper) : base(repository, mapper)
        {
        }
        protected override IQueryable<FAQ> ApplyFilter(IQueryable<FAQ> query, FaqQueryFilter? filter)
        {
            if (filter ==null)
                return query;
            if(!string.IsNullOrEmpty(filter.Search))
                query = query.Where(x => x.Question.ToLower().Contains(filter.Search.ToLower())
                                        || x.Answer.ToLower().Contains(filter.Search.ToLower()));
            if (!string.IsNullOrEmpty(filter.OrderBy))
            {
                query = filter.OrderBy.ToLower() switch
                {
                    "createdatdesc" => query.OrderByDescending(x => x.CreatedAt),
                    _ => query.OrderBy(x => x.CreatedAt),
                };
                return query;
            }
            query = query.OrderBy(x => x.CreatedAt);
            return query;
        }
    }
}
