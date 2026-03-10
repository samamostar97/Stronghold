using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Infrastructure.Persistence;

namespace Stronghold.Infrastructure.Repositories;

public class MembershipPackageRepository : Repository<MembershipPackage>, IMembershipPackageRepository
{
    public MembershipPackageRepository(StrongholdDbContext context) : base(context) { }
}
