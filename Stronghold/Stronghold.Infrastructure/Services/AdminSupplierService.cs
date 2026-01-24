using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.AdminSupplierDTO;
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
    public class AdminSupplierService : BaseService<Supplier, SupplierDTO, CreateSupplierDTO, UpdateSupplierDTO, SupplierQueryFilter, int>, IAdminSupplierService
    {
        public AdminSupplierService(IRepository<Supplier, int> repository, IMapper mapper) : base(repository, mapper)
        {
        }
        protected override async Task BeforeCreateAsync(Supplier entity, CreateSupplierDTO dto)
        {
            var supplierExists = await _repository.AsQueryable().AnyAsync(x => x.Name.ToLower().Contains(dto.Name.ToLower()));
            if (supplierExists) throw new ConflictException("Supplier sa ovim imenom već postoji");

        }
        protected override async Task BeforeUpdateAsync(Supplier entity, UpdateSupplierDTO dto)
        {
            if (!string.IsNullOrEmpty(dto.Name))
            {
                var supplierExists = await _repository.AsQueryable().AnyAsync(x => x.Name.ToLower().Contains(dto.Name.ToLower()) && x.Id != entity.Id);
                if (supplierExists) throw new ConflictException("Supplier sa ovim imenom već postoji");
            }
        }
        protected override IQueryable<Supplier> ApplyFilter(IQueryable<Supplier> query, SupplierQueryFilter? filter)
        {
            query = query.Where(x => !x.IsDeleted);
            if (filter != null)
                return query;
            if (!string.IsNullOrEmpty(filter.Search))
                query = query.Where(x => x.Name.ToLower().Contains(filter.Search.ToLower()));
            if (!string.IsNullOrEmpty(filter.OrderBy))
            { 
                query = filter.OrderBy.ToLower() switch
                {
                    "naziv" => query.OrderBy(x => x.Name),
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

