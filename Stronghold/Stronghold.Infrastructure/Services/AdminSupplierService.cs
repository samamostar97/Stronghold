using MapsterMapper;
using Stronghold.Application.DTOs.AdminSuppliersDTO;
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
    public class AdminSupplierService : BaseService<Supplier, SupplierDTO, CreateSupplierDTO, UpdateSupplierDTO, SupplierQueryFilter, int>, IAdminSupplierService
    {
        public AdminSupplierService(IRepository<Supplier, int> repository, IMapper mapper) : base(repository, mapper)
        {
        }
        protected override IQueryable<Supplier> ApplyFilter(IQueryable<Supplier> query, SupplierQueryFilter? filter)
        {
            query = query.Where(x => !x.IsDeleted);
            if (!string.IsNullOrWhiteSpace(filter.Search))
            {
                var search = filter.Search.Trim().ToLower();
                query = query.Where(c => c.Name.ToLower().Contains(search));
            }

            return query;

        }
    }
}
