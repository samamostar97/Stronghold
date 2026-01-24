using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.AdminReviewDTO;
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
    public class AdminReviewService:IAdminReviewService
    {
        private readonly IRepository<Review, int> _repository;
        private readonly IMapper _mapper;

        public AdminReviewService(IRepository<Review, int> repository, IMapper mapper)
        {
            _repository = repository;
            _mapper = mapper;
        }

        public async Task<PagedResult<ReviewDTO>> GetReviewsPagedAsync(PaginationRequest request, ReviewQueryFilter? queryFilter)
        {
            var query = _repository.AsQueryable();
            query=ApplyFilter(query, queryFilter);
            var pagedEntities = await _repository.GetPagedAsync(query, request);

            return new PagedResult<ReviewDTO>
            {
                Items = _mapper.Map<List<ReviewDTO>>(pagedEntities.Items),
                TotalCount = pagedEntities.TotalCount,
                PageNumber = request.PageNumber
            };
        }
        public async Task<ReviewDTO> DeleteReviewAsync(int reviewId)
        {
            var query = _repository.AsQueryable().Include(x => x.Supplement).Include(x => x.User);
            var review = await query.FirstOrDefaultAsync(x => x.Id == reviewId);
            if (review == null)
                throw new KeyNotFoundException("Recenzija ne postoji");
            var reviewDTO = _mapper.Map<ReviewDTO>(review);
            await _repository.DeleteAsync(review);
            return reviewDTO;

        }
        private IQueryable<Review> ApplyFilter(IQueryable<Review> query, ReviewQueryFilter? queryFilter)
        {
            query = query.Include(x => x.User)
                       .Include(x => x.Supplement);
            if (queryFilter == null)
                return query;
            if(!string.IsNullOrEmpty(queryFilter.Search))
                query=query.Where(x=>x.User.FirstName.ToLower().Contains(queryFilter.Search.ToLower())
                                    ||x.User.LastName.ToLower().Contains(queryFilter.Search.ToLower())
                                    ||x.Supplement.Name.ToLower().Contains(queryFilter.Search.ToLower()));
            if(!string.IsNullOrEmpty(queryFilter.OrderBy))
            {
                query = queryFilter.OrderBy.ToLower() switch
                {
                    "firstname" => query.OrderBy(x=>x.User.FirstName),
                    "supplement" => query.OrderBy(x=>x.Supplement.Name),
                    "createdatdesc" => query.OrderByDescending(x=>x.CreatedAt),
                    _ => query.OrderBy(x=>x.CreatedAt)
                };
                return query;
            }
            query.OrderBy(x=> x.CreatedAt);
            return query;

        }
    }
}
