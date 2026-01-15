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
    public class CategoryRepository : BaseRepository<SupplementCategory, int>, ICategoryRepository
    {
        private readonly StrongholdDbContext _context;
        public CategoryRepository(StrongholdDbContext context) : base(context)
        {
            _context = context;
        }
       
    }
}
