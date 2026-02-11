using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Common;

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
            var now = DateTimeUtils.UtcNow;

            var userExists = await _userRepository.AsQueryable().AnyAsync(x => x.Id == userId && !x.IsDeleted);
            if (!userExists)
            {
                throw new KeyNotFoundException("User ne postoji");
            }

            var activeMembership = await _membershipRepository.AsQueryable()
                .FirstOrDefaultAsync(x => x.UserId == userId && x.EndDate > now && !x.IsDeleted);
            var activePaymentHistories = await _paymentHistoryRepo.AsQueryable()
                .Where(p => p.UserId == userId
                    && p.StartDate <= now
                    && p.EndDate > now
                    && !p.IsDeleted)
                .ToListAsync();

            if (activeMembership == null && activePaymentHistories.Count == 0)
            {
                throw new InvalidOperationException("User nema aktivnu clanarinu");
            }

            if (activeMembership != null)
            {
                activeMembership.IsDeleted = true;
                activeMembership.EndDate = now;
                await _membershipRepository.UpdateAsync(activeMembership);
            }

            foreach (var paymentHistory in activePaymentHistories)
            {
                paymentHistory.EndDate = now;
                await _paymentHistoryRepo.UpdateAsync(paymentHistory);
            }

            return true;
        }

        public async Task<bool> HasActiveMembershipAsync(int userId)
        {
            var userExists = await _userRepository.AsQueryable().AnyAsync(x => x.Id == userId && !x.IsDeleted);
            if (!userExists)
            {
                return false;
            }

            var now = DateTimeUtils.UtcNow;
            return await _membershipRepository.AsQueryable()
                .AnyAsync(x => x.UserId == userId && x.EndDate > now && !x.IsDeleted);
        }

        public async Task<PagedResult<MembershipPaymentResponse>> GetPaymentsAsync(int userId, MembershipQueryFilter filter)
        {
            var userExists = await _userRepository.AsQueryable().AnyAsync(u => u.Id == userId && !u.IsDeleted);
            if (!userExists)
            {
                return new PagedResult<MembershipPaymentResponse>
                {
                    Items = new(),
                    TotalCount = 0,
                    PageNumber = filter.PageNumber
                };
            }

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
            var now = DateTimeUtils.UtcNow;

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
            var normalizedStartDate = DateTimeUtils.ToUtcDate(request.StartDate);
            var normalizedEndDate = DateTimeUtils.ToUtcDate(request.EndDate);
            var normalizedPaymentDate = DateTimeUtils.ToUtcDate(request.PaymentDate);

            if (normalizedStartDate < DateTimeUtils.UtcToday)
            {
                throw new ArgumentException("Nemoguce unijeti datum u proslosti");
            }

            if (normalizedEndDate < normalizedStartDate)
            {
                throw new ArgumentException("EndDate ne moze biti prije StartDate-a");
            }

            if (normalizedPaymentDate.Date < normalizedStartDate.Date || normalizedPaymentDate.Date > normalizedEndDate.Date)
            {
                throw new ArgumentException("PaymentDate mora biti unutar perioda clanarine.");
            }

            var userExists = await _userRepository.AsQueryable().AnyAsync(x => x.Id == request.UserId && !x.IsDeleted);
            if (!userExists)
            {
                throw new KeyNotFoundException("User ne postoji");
            }

            var membershipExists = await _membershipRepository.AsQueryable()
                .AnyAsync(x => x.UserId == request.UserId && x.EndDate > DateTimeUtils.UtcNow && !x.IsDeleted);
            if (membershipExists)
            {
                throw new InvalidOperationException("User vec ima aktivnu clanarinu");
            }

            var packageExists = await _membershipPackageRepository.AsQueryable()
                .AnyAsync(x => x.Id == request.MembershipPackageId && !x.IsDeleted);
            if (!packageExists)
            {
                throw new KeyNotFoundException("Ta clanarina ne postoji");
            }

            var membership = new Membership
            {
                UserId = request.UserId,
                MembershipPackageId = request.MembershipPackageId,
                StartDate = normalizedStartDate,
                EndDate = normalizedEndDate
            };
            await _membershipRepository.AddAsync(membership);

            var paymentHistory = new MembershipPaymentHistory
            {
                UserId = request.UserId,
                MembershipPackageId = request.MembershipPackageId,
                AmountPaid = request.AmountPaid,
                PaymentDate = normalizedPaymentDate,
                StartDate = normalizedStartDate,
                EndDate = normalizedEndDate
            };
            await _paymentHistoryRepo.AddAsync(paymentHistory);

            return new MembershipResponse
            {
                Id = membership.Id,
                UserId = membership.UserId,
                MembershipPackageId = membership.MembershipPackageId,
                StartDate = membership.StartDate,
                EndDate = membership.EndDate
            };
        }
    }
}
