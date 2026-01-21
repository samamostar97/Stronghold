using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.AdminUserMembershipsDTO;
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
    public class AdminMembershipService: IAdminMembershipService
    {
        private readonly IRepository<Membership, int> _membershipRepository;
        private readonly IRepository<MembershipPackage, int> _membershipPackageRepository;
        private readonly IRepository<User,int> _userRepository;
        public AdminMembershipService(IRepository<User, int> userRepository,IRepository<Membership, int> membershipRepository, IRepository<MembershipPackage, int> membershipPackageRepository)
        {
         _membershipRepository = membershipRepository;
         _membershipPackageRepository = membershipPackageRepository;
        _userRepository= userRepository;
        }
        public async Task<MembershipDTO> AssignMembership(AssignMembershipRequest request)
        {
            if (request.StartDate < DateTime.UtcNow || request.EndDate < request.StartDate)
                throw new ArgumentException("Neispravan format datuma");
            var userExists= await _userRepository.AsQueryable().AnyAsync(x=>x.Id==request.UserId);
            if (!userExists)
                throw new InvalidOperationException("User ne postoji");
            var membershipExists = await _membershipRepository.AsQueryable().AnyAsync(x=>x.UserId==request.UserId&&x.EndDate>DateTime.UtcNow&&!x.IsDeleted);
            if (membershipExists)
                throw new InvalidOperationException("User vec ima aktivnu clanarinu");
            var packageExists = await _membershipPackageRepository.AsQueryable().AnyAsync(x => x.Id == request.MembershipPackageId);
           if (!packageExists)
                throw new InvalidOperationException("Ta članarina ne postoji");
           
            var membership = new Membership()
            {
                UserId = request.UserId,
                MembershipPackageId = request.MembershipPackageId,
                EndDate = request.EndDate,
                StartDate = request.StartDate,
            };
            await _membershipRepository.AddAsync(membership);

            return new MembershipDTO()
            {
                Id = membership.Id,
                UserId = membership.UserId,
                MembershipPackageId= membership.MembershipPackageId,
                StartDate = membership.StartDate,
                EndDate = membership.EndDate,
            };
        }
    }
}
