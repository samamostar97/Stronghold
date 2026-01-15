using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Infrastructure.Repositories
{
    public class SupplementRepository : BaseRepository<Supplement, int>, ISupplementRepository
    {
        protected readonly StrongholdDbContext _context;
        public SupplementRepository(StrongholdDbContext context) : base(context)
        {
            _context = context;
        }

        public async Task<bool> SupplierExists(int id)
        {
            var supplier = await _context.Suppliers.FindAsync(id);
            if (supplier == null)
                return false;
            return true;
        }
        public async Task<bool> CategoryExists(int id)
        {
            var category = await _context.SupplementCategories.FindAsync(id);
            if (category == null)
                return false;
            return true;
        }
    }
}
