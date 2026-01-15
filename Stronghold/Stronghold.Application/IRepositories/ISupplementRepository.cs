using Stronghold.Core.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IRepositories
{
    public interface ISupplementRepository : IRepository<Supplement, int>
    {
        Task<bool> SupplierExists(int id);
        Task<bool> CategoryExists(int id);
    }
}
