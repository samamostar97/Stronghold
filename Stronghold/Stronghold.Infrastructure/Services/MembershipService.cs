using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Services
{
    public class MembershipService : IMembershipService
    {
        private readonly IRepository<Membership, int> _membershipRepository;
        private readonly IRepository<MembershipPackage, int> _membershipPackageRepository;
        private readonly IRepository<User, int> _userRepository;
        private readonly IRepository<MembershipPaymentHistory, int> _paymentHistoryRepo;

        public MembershipService(
            IRepository<MembershipPaymentHistory, int> paymentHistoryRepo,
            IRepository<User, int> userRepository,
            IRepository<Membership, int> membershipRepository,
            IRepository<MembershipPackage, int> membershipPackageRepository)
        {
            _membershipRepository = membershipRepository;
            _membershipPackageRepository = membershipPackageRepository;
            _userRepository = userRepository;
            _paymentHistoryRepo = paymentHistoryRepo;
        }

        public async Task<bool> RevokeMembership(int userId)
        {
            var userExists = await _userRepository.AsQueryable().AnyAsync(x => x.Id == userId && !x.IsDeleted);
            if (!userExists) throw new KeyNotFoundException("User ne postoji");

            var activeMembership = await _membershipRepository.AsQueryable()
                .FirstOrDefaultAsync(x => x.UserId == userId && x.EndDate > DateTime.UtcNow && !x.IsDeleted);
            if (activeMembership == null) throw new InvalidOperationException("User nema aktivnu clanarinu");

            activeMembership.IsDeleted = true;
            activeMembership.EndDate = DateTime.UtcNow;
            await _membershipRepository.UpdateAsync(activeMembership);

            var paymentHistory = await _paymentHistoryRepo.AsQueryable()
                .Where(p => p.UserId == userId
                    && p.MembershipPackageId == activeMembership.MembershipPackageId
                    && p.EndDate > DateTime.UtcNow
                    && !p.IsDeleted)
                .OrderByDescending(p => p.PaymentDate)
                .FirstOrDefaultAsync();

            if (paymentHistory != null)
            {
                paymentHistory.EndDate = DateTime.UtcNow;
                await _paymentHistoryRepo.UpdateAsync(paymentHistory);
            }

            return true;
        }

        public async Task<PagedResult<MembershipPaymentResponse>> GetPaymentsAsync(int userId, MembershipQueryFilter filter)
        {
            var userExists = await _userRepository.AsQueryable().AnyAsync(u => u.Id == userId && !u.IsDeleted);
            if (!userExists)
                return new PagedResult<MembershipPaymentResponse> { Items = new(), TotalCount = 0, PageNumber = filter.PageNumber };

            var baseQuery = _paymentHistoryRepo.AsQueryable()
                .AsNoTracking()
                .Include(p => p.MembershipPackage)
                .Where(p => p.UserId == userId && !p.IsDeleted);

            IQueryable<MembershipPaymentHistory> query;
            if (!string.IsNullOrEmpty(filter.OrderBy))
            {
                query = filter.OrderBy.ToLower() switch
                {
                    "date" => baseQuery.OrderBy(p => p.PaymentDate),
                    "datedesc" => baseQuery.OrderByDescending(p => p.PaymentDate),
                    "amount" => baseQuery.OrderBy(p => p.AmountPaid),
                    "amountdesc" => baseQuery.OrderByDescending(p => p.AmountPaid),
                    _ => baseQuery.OrderByDescending(p => p.PaymentDate)
                };
            }
            else
            {
                query = baseQuery.OrderByDescending(p => p.PaymentDate);
            }

            var totalCount = await query.CountAsync();

            var items = await query
                .Skip((filter.PageNumber - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .Select(p => new MembershipPaymentResponse
                {
                    Id = p.Id,
                    MembershipPackageId = p.MembershipPackageId,
                    PackageName = p.MembershipPackage.PackageName,
                    AmountPaid = p.AmountPaid,
                    PaymentDate = p.PaymentDate,
                    StartDate = p.StartDate,
                    EndDate = p.EndDate
                })
                .ToListAsync();

            return new PagedResult<MembershipPaymentResponse>
            {
                Items = items,
                TotalCount = totalCount,
                PageNumber = filter.PageNumber
            };
        }

        public async Task<PagedResult<ActiveMemberResponse>> GetActiveMembersAsync(ActiveMemberQueryFilter filter)
        {
            var now = DateTime.UtcNow;

            var baseQuery = _membershipRepository.AsQueryable()
                .AsNoTracking()
                .Include(m => m.User)
                .Include(m => m.MembershipPackage)
                .Where(m => m.EndDate > now && !m.IsDeleted && !m.User.IsDeleted);

            if (!string.IsNullOrWhiteSpace(filter.Name))
            {
                var name = filter.Name.Trim().ToLower();
                baseQuery = baseQuery.Where(m =>
                    m.User.FirstName.ToLower().Contains(name) ||
                    m.User.LastName.ToLower().Contains(name) ||
                    m.User.Username.ToLower().Contains(name));
            }

            var query = baseQuery.OrderBy(m => m.User.FirstName).ThenBy(m => m.User.LastName);

            var totalCount = await query.CountAsync();

            var items = await query
                .Skip((filter.PageNumber - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .Select(m => new ActiveMemberResponse
                {
                    UserId = m.UserId,
                    FirstName = m.User.FirstName,
                    LastName = m.User.LastName,
                    Username = m.User.Username,
                    ProfileImageUrl = m.User.ProfileImageUrl,
                    PackageName = m.MembershipPackage.PackageName,
                    MembershipEndDate = m.EndDate
                })
                .ToListAsync();

            return new PagedResult<ActiveMemberResponse>
            {
                Items = items,
                TotalCount = totalCount,
                PageNumber = filter.PageNumber
            };
        }

        public async Task<MembershipResponse> AssignMembership(AssignMembershipRequest request)
        {
            if (request.StartDate < DateTime.Today)
                throw new ArgumentException("Nemoguće unijeti datum u prošlosti");
            if (request.EndDate < request.StartDate)
                throw new ArgumentException("EndDate ne moze biti prije StartDate-a");

            var userExists = await _userRepository.AsQueryable().AnyAsync(x => x.Id == request.UserId);
            if (!userExists)
                throw new KeyNotFoundException("User ne postoji");

            var membershipExists = await _membershipRepository.AsQueryable()
                .AnyAsync(x => x.UserId == request.UserId && x.EndDate > DateTime.UtcNow && !x.IsDeleted);
            if (membershipExists)
                throw new InvalidOperationException("User vec ima aktivnu clanarinu");

            var packageExists = await _membershipPackageRepository.AsQueryable().AnyAsync(x => x.Id == request.MembershipPackageId);
            if (!packageExists)
                throw new KeyNotFoundException("Ta članarina ne postoji");

            var membership = new Membership()
            {
                UserId = request.UserId,
                MembershipPackageId = request.MembershipPackageId,
                EndDate = request.EndDate,
                StartDate = request.StartDate,
            };
            await _membershipRepository.AddAsync(membership);

            var paymentHistory = new MembershipPaymentHistory()
            {
                UserId = request.UserId,
                MembershipPackageId = request.MembershipPackageId,
                AmountPaid = request.AmountPaid,
                PaymentDate = request.PaymentDate,
                StartDate = request.StartDate,
                EndDate = request.EndDate,
            };
            await _paymentHistoryRepo.AddAsync(paymentHistory);

            return new MembershipResponse()
            {
                Id = membership.Id,
                UserId = membership.UserId,
                MembershipPackageId = membership.MembershipPackageId,
                StartDate = membership.StartDate,
                EndDate = membership.EndDate,
            };
        }
    }
}
