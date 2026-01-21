using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.AdminSupplementsDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;


namespace Stronghold.Infrastructure.Services
{
    public class AdminSupplementService : BaseService<Supplement, SupplementDTO, CreateSupplementDTO, UpdateSupplementDTO, SupplementQueryFilter, int>, IAdminSupplementService
    {
        private readonly IRepository<SupplementCategory, int> _supplementCategoryRepo;
        private readonly IRepository<Supplier, int> _supplierRepo;

        public AdminSupplementService(IRepository<SupplementCategory, int> supplementCategoryRepo,IRepository<Supplier, int> supplierRepo,IRepository<Supplement, int> repository, IMapper mapper) : base(repository, mapper)
        {
            _supplementCategoryRepo = supplementCategoryRepo;
            _supplierRepo = supplierRepo;
        }
        protected override async Task BeforeCreateAsync(Supplement entity, CreateSupplementDTO dto)
        {
            var supplementExists = await _repository.AsQueryable().AnyAsync(x => x.Name.ToLower()==dto.Name.ToLower()&&!x.IsDeleted);
            if (supplementExists) throw new InvalidOperationException("Suplement već postoji");
            var categoryExists = await _supplementCategoryRepo.AsQueryable().AnyAsync(x => x.Id == dto.SupplementCategoryId);
            if (!categoryExists) throw new InvalidOperationException("Odabrana kategorija ne postoji");
            var supplierExists = await _supplierRepo.AsQueryable().AnyAsync(x=>x.Id == dto.SupplierId);
            if (!supplierExists) throw new InvalidOperationException("Odabrani dobavljac ne postoji");
        }
        protected override async Task BeforeUpdateAsync(Supplement entity, UpdateSupplementDTO dto)
        {
            var supplementExists = await _repository.AsQueryable().AnyAsync(x => x.Name == dto.Name && x.Id != entity.Id);
            if (supplementExists) throw new InvalidOperationException("Supplement sa ovim imenom već postoji");
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
    }
}
