using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.AdminSupplementsDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Exceptions;


namespace Stronghold.Infrastructure.Services
{
    public class AdminSupplementService : BaseService<Supplement, SupplementDTO, CreateSupplementDTO, UpdateSupplementDTO, SupplementQueryFilter, int>, IAdminSupplementService
    {
        private readonly IRepository<SupplementCategory, int> _supplementCategoryRepo;
        private readonly IRepository<Supplier, int> _supplierRepo;
        private readonly IFileStorageService _fileStorageService;

        public AdminSupplementService(IRepository<SupplementCategory, int> supplementCategoryRepo, IRepository<Supplier, int> supplierRepo, IRepository<Supplement, int> repository, IMapper mapper, IFileStorageService fileStorageService) : base(repository, mapper)
        {
            _supplementCategoryRepo = supplementCategoryRepo;
            _supplierRepo = supplierRepo;
            _fileStorageService = fileStorageService;
        }
        protected override async Task BeforeCreateAsync(Supplement entity, CreateSupplementDTO dto)
        {
            var supplementExists = await _repository.AsQueryable().AnyAsync(x => x.Name.ToLower()==dto.Name.ToLower());
            if (supplementExists) throw new ConflictException("Suplement već postoji");
            var categoryExists = await _supplementCategoryRepo.AsQueryable().AnyAsync(x => x.Id == dto.SupplementCategoryId);
            if (!categoryExists) throw new KeyNotFoundException("Odabrana kategorija ne postoji");
            var supplierExists = await _supplierRepo.AsQueryable().AnyAsync(x=>x.Id == dto.SupplierId);
            if (!supplierExists) throw new KeyNotFoundException("Odabrani dobavljac ne postoji");
        }
        protected override async Task BeforeUpdateAsync(Supplement entity, UpdateSupplementDTO dto)
        {
            var supplementExists = await _repository.AsQueryable().AnyAsync(x => x.Name == dto.Name && x.Id != entity.Id);
            if (supplementExists) throw new ConflictException("Supplement sa ovim imenom već postoji");
        }
        protected override IQueryable<Supplement> ApplyFilter(IQueryable<Supplement> query, SupplementQueryFilter? filter)
        {
            query = query.Include(x => x.Supplier);
            query = query.Include(x => x.SupplementCategory);

            if (filter == null)
                return query;
            if(!string.IsNullOrEmpty(filter.Search))
            {
                var search = filter.Search.ToLower();
                query = query.Where(x => x.Name.ToLower().Contains(search)
                              || (x.Supplier != null && x.Supplier.Name.ToLower().Contains(search))
                              || (x.SupplementCategory != null && x.SupplementCategory.Name.ToLower().Contains(search)));
            }
            if (!string.IsNullOrEmpty(filter.OrderBy))
            {
                query = filter.OrderBy.ToLower() switch
                {
                    "supplement" => query.OrderBy(x => x.Name),
                    "category" => query.OrderBy(x => x.SupplementCategory.Name),
                    "supplier" => query.OrderBy(x => x.Supplier.Name),
                    _ => query.OrderBy(x => x.CreatedAt)
                };
                return query;
            }
            query = query.OrderBy(x => x.CreatedAt);
            return query;
        }

        public async Task<SupplementDTO> UploadImageAsync(int supplementId, FileUploadRequest fileRequest)
        {
            var supplement = await _repository.AsQueryable()
                .Include(x => x.Supplier)
                .Include(x => x.SupplementCategory)
                .FirstOrDefaultAsync(x => x.Id == supplementId);

            if (supplement == null)
                throw new KeyNotFoundException("Supplement nije pronađen");

            if (!string.IsNullOrEmpty(supplement.SupplementImageUrl))
            {
                await _fileStorageService.DeleteAsync(supplement.SupplementImageUrl);
            }

            var uploadResult = await _fileStorageService.UploadAsync(fileRequest, "supplements", supplementId.ToString());

            if (!uploadResult.Success)
                throw new InvalidOperationException(uploadResult.ErrorMessage);

            supplement.SupplementImageUrl = uploadResult.FileUrl;
            await _repository.UpdateAsync(supplement);

            return _mapper.Map<SupplementDTO>(supplement);
        }

        public async Task<bool> DeleteImageAsync(int supplementId)
        {
            var supplement = await _repository.GetByIdAsync(supplementId);

            if (supplement == null)
                throw new KeyNotFoundException("Supplement nije pronađen");

            if (string.IsNullOrEmpty(supplement.SupplementImageUrl))
                return false;

            var deleted = await _fileStorageService.DeleteAsync(supplement.SupplementImageUrl);

            supplement.SupplementImageUrl = null;
            await _repository.UpdateAsync(supplement);

            return deleted;
        }
    }
}
