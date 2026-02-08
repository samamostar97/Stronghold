using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Services
{
    public class SupplierService : BaseService<Supplier, SupplierResponse, CreateSupplierRequest, UpdateSupplierRequest, SupplierQueryFilter, int>, ISupplierService
    {
        public SupplierService(IRepository<Supplier, int> repository, IMapper mapper) : base(repository, mapper)
        {
        }

        protected override async Task BeforeCreateAsync(Supplier entity, CreateSupplierRequest dto)
        {
            var supplierExists = await _repository.AsQueryable().AnyAsync(x => x.Name.ToLower() == dto.Name.ToLower());
            if (supplierExists) throw new ConflictException("Dobavljač sa ovim imenom već postoji.");
        }

        protected override async Task BeforeUpdateAsync(Supplier entity, UpdateSupplierRequest dto)
        {
            if (!string.IsNullOrEmpty(dto.Name))
            {
                var supplierExists = await _repository.AsQueryable().AnyAsync(x => x.Name.ToLower() == dto.Name.ToLower() && x.Id != entity.Id);
                if (supplierExists) throw new ConflictException("Dobavljač sa ovim imenom već postoji.");
            }
        }

        protected override async Task BeforeDeleteAsync(Supplier entity)
        {
            var hasSupplements = await _repository.AsQueryable()
                .Where(x => x.Id == entity.Id)
                .SelectMany(x => x.Supplements)
                .AnyAsync();

            if (hasSupplements)
                throw new EntityHasDependentsException("dobavljača", "suplemente");
        }

        protected override IQueryable<Supplier> ApplyFilter(IQueryable<Supplier> query, SupplierQueryFilter filter)
        {
            if (!string.IsNullOrEmpty(filter.Search))
                query = query.Where(x => x.Name.ToLower().Contains(filter.Search.ToLower()));

            if (!string.IsNullOrEmpty(filter.OrderBy))
            {
                return filter.OrderBy.ToLower() switch
                {
                    "naziv" => query.OrderBy(x => x.Name),
                    "createdatdesc" => query.OrderByDescending(x => x.CreatedAt),
                    _ => query.OrderBy(x => x.CreatedAt),
                };
            }

            return query.OrderBy(x => x.CreatedAt);
        }
    }
}
