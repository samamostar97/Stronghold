using MapsterMapper;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Services
{
    public class FaqService : BaseService<FAQ, FaqResponse, CreateFaqRequest, UpdateFaqRequest, FaqQueryFilter, int>, IFaqService
    {
        public FaqService(IRepository<FAQ, int> repository, IMapper mapper) : base(repository, mapper)
        {
        }

        protected override IQueryable<FAQ> ApplyFilter(IQueryable<FAQ> query, FaqQueryFilter filter)
        {
            if (!string.IsNullOrEmpty(filter.Search))
                query = query.Where(x => x.Question.ToLower().Contains(filter.Search.ToLower())
                                        || x.Answer.ToLower().Contains(filter.Search.ToLower()));

            if (!string.IsNullOrEmpty(filter.OrderBy))
            {
                return filter.OrderBy.ToLower() switch
                {
                    "question" => query.OrderBy(x => x.Question),
                    "questiondesc" => query.OrderByDescending(x => x.Question),
                    "createdat" => query.OrderBy(x => x.CreatedAt),
                    "createdatdesc" => query.OrderByDescending(x => x.CreatedAt),
                    _ => query.OrderByDescending(x => x.CreatedAt),
                };
            }

            return query.OrderByDescending(x => x.CreatedAt);
        }
    }
}
