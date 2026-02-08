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

namespace Stronghold.Infrastructure.Services
{
    public class SupplementService : BaseService<Supplement, SupplementResponse, CreateSupplementRequest, UpdateSupplementRequest, SupplementQueryFilter, int>, ISupplementService
    {
        private readonly IRepository<SupplementCategory, int> _supplementCategoryRepo;
        private readonly IRepository<Supplier, int> _supplierRepo;
        private readonly IRepository<Review, int> _reviewRepo;
        private readonly IFileStorageService _fileStorageService;

        public SupplementService(
            IRepository<SupplementCategory, int> supplementCategoryRepo,
            IRepository<Supplier, int> supplierRepo,
            IRepository<Review, int> reviewRepo,
            IRepository<Supplement, int> repository,
            IMapper mapper,
            IFileStorageService fileStorageService) : base(repository, mapper)
        {
            _supplementCategoryRepo = supplementCategoryRepo;
            _supplierRepo = supplierRepo;
            _reviewRepo = reviewRepo;
            _fileStorageService = fileStorageService;
        }

        protected override async Task BeforeCreateAsync(Supplement entity, CreateSupplementRequest dto)
        {
            var supplementExists = await _repository.AsQueryable().AnyAsync(x => x.Name.ToLower() == dto.Name.ToLower());
            if (supplementExists) throw new ConflictException("Suplement sa ovim imenom već postoji.");

            var categoryExists = await _supplementCategoryRepo.AsQueryable().AnyAsync(x => x.Id == dto.SupplementCategoryId);
            if (!categoryExists) throw new KeyNotFoundException("Odabrana kategorija ne postoji.");

            var supplierExists = await _supplierRepo.AsQueryable().AnyAsync(x => x.Id == dto.SupplierId);
            if (!supplierExists) throw new KeyNotFoundException("Odabrani dobavljač ne postoji.");
        }

        protected override async Task BeforeUpdateAsync(Supplement entity, UpdateSupplementRequest dto)
        {
            if (!string.IsNullOrEmpty(dto.Name))
            {
                var supplementExists = await _repository.AsQueryable().AnyAsync(x => x.Name.ToLower() == dto.Name.ToLower() && x.Id != entity.Id);
                if (supplementExists) throw new ConflictException("Suplement sa ovim imenom već postoji.");
            }

            if (dto.SupplementCategoryId.HasValue)
            {
                var categoryExists = await _supplementCategoryRepo.AsQueryable().AnyAsync(x => x.Id == dto.SupplementCategoryId.Value);
                if (!categoryExists) throw new KeyNotFoundException("Odabrana kategorija ne postoji.");
            }

            if (dto.SupplierId.HasValue)
            {
                var supplierExists = await _supplierRepo.AsQueryable().AnyAsync(x => x.Id == dto.SupplierId.Value);
                if (!supplierExists) throw new KeyNotFoundException("Odabrani dobavljač ne postoji.");
            }
        }

        protected override async Task BeforeDeleteAsync(Supplement entity)
        {
            var hasReviews = await _repository.AsQueryable()
                .Where(x => x.Id == entity.Id)
                .SelectMany(x => x.Reviews)
                .AnyAsync();

            if (hasReviews)
                throw new EntityHasDependentsException("suplement", "recenzije");
        }

        protected override async Task AfterDeleteAsync(Supplement entity)
        {
            if (!string.IsNullOrEmpty(entity.SupplementImageUrl))
            {
                await _fileStorageService.DeleteAsync(entity.SupplementImageUrl);
            }
        }

        protected override IQueryable<Supplement> ApplyFilter(IQueryable<Supplement> query, SupplementQueryFilter filter)
        {
            query = query.Include(x => x.Supplier);
            query = query.Include(x => x.SupplementCategory);

            if (!string.IsNullOrEmpty(filter.Search))
            {
                var search = filter.Search.ToLower();
                query = query.Where(x => x.Name.ToLower().Contains(search)
                              || (x.Supplier != null && x.Supplier.Name.ToLower().Contains(search))
                              || (x.SupplementCategory != null && x.SupplementCategory.Name.ToLower().Contains(search)));
            }

            if (filter.SupplementCategoryId.HasValue)
            {
                query = query.Where(x => x.SupplementCategoryId == filter.SupplementCategoryId.Value);
            }

            if (!string.IsNullOrEmpty(filter.OrderBy))
            {
                return filter.OrderBy.ToLower() switch
                {
                    "name" => query.OrderBy(x => x.Name),
                    "namedesc" => query.OrderByDescending(x => x.Name),
                    "price" => query.OrderBy(x => x.Price),
                    "pricedesc" => query.OrderByDescending(x => x.Price),
                    _ => query.OrderByDescending(x => x.CreatedAt)
                };
            }

            return query.OrderByDescending(x => x.CreatedAt);
        }

        public async Task<SupplementResponse> UploadImageAsync(int supplementId, FileUploadRequest fileRequest)
        {
            var supplement = await _repository.AsQueryable()
                .Include(x => x.Supplier)
                .Include(x => x.SupplementCategory)
                .FirstOrDefaultAsync(x => x.Id == supplementId);

            if (supplement == null)
                throw new KeyNotFoundException("Suplement nije pronađen.");

            if (!string.IsNullOrEmpty(supplement.SupplementImageUrl))
            {
                await _fileStorageService.DeleteAsync(supplement.SupplementImageUrl);
            }

            var uploadResult = await _fileStorageService.UploadAsync(fileRequest, "supplements", supplementId.ToString());

            if (!uploadResult.Success)
                throw new InvalidOperationException(uploadResult.ErrorMessage);

            supplement.SupplementImageUrl = uploadResult.FileUrl;
            await _repository.UpdateAsync(supplement);

            return _mapper.Map<SupplementResponse>(supplement);
        }

        public async Task<bool> DeleteImageAsync(int supplementId)
        {
            var supplement = await _repository.GetByIdAsync(supplementId);

            if (supplement == null)
                throw new KeyNotFoundException("Suplement nije pronađen.");

            if (string.IsNullOrEmpty(supplement.SupplementImageUrl))
                return false;

            var deleted = await _fileStorageService.DeleteAsync(supplement.SupplementImageUrl);

            supplement.SupplementImageUrl = null;
            await _repository.UpdateAsync(supplement);

            return deleted;
        }

        public async Task<IEnumerable<SupplementReviewResponse>> GetReviewsAsync(int supplementId)
        {
            var reviews = await _reviewRepo.AsQueryable()
                .Include(r => r.User)
                .Where(r => r.SupplementId == supplementId)
                .OrderByDescending(r => r.CreatedAt)
                .Select(r => new SupplementReviewResponse
                {
                    Id = r.Id,
                    UserName = r.User != null
                        ? r.User.FirstName + " " + (r.User.LastName != null && r.User.LastName.Length > 0 ? r.User.LastName.Substring(0, 1) + "." : "")
                        : "Anonimno",
                    Rating = r.Rating,
                    Comment = r.Comment,
                    CreatedAt = r.CreatedAt
                })
                .ToListAsync();

            return reviews;
        }
    }
}
