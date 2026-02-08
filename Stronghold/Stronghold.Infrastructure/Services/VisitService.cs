using MapsterMapper;
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
    public class VisitService : IVisitService
    {
        private readonly IRepository<GymVisit, int> _visitRepository;
        private readonly IRepository<User, int> _userRepository;
        private readonly IRepository<Membership, int> _membershipRepository;
        private readonly IMapper _mapper;

        public VisitService(IRepository<User, int> userRepository, IRepository<GymVisit, int> visitRepository, IMapper mapper, IRepository<Membership, int> membershipRepository)
        {
            _userRepository = userRepository;
            _visitRepository = visitRepository;
            _mapper = mapper;
            _membershipRepository = membershipRepository;
        }

        public async Task<PagedResult<VisitResponse>> GetCurrentVisitorsAsync(VisitQueryFilter filter)
        {
            var query = _visitRepository.AsQueryable()
                .Include(x => x.User)
                .Where(x => x.CheckOutTime == null && !x.IsDeleted);

            if (!string.IsNullOrEmpty(filter.Search))
            {
                var search = filter.Search.ToLower();
                query = query.Where(x => x.User != null &&
                    (x.User.FirstName.ToLower().Contains(search) ||
                    x.User.LastName.ToLower().Contains(search) ||
                    x.User.Username.ToLower().Contains(search)));
            }

            if (!string.IsNullOrEmpty(filter.OrderBy))
            {
                query = filter.OrderBy.ToLower() switch
                {
                    "firstname" => query.OrderBy(x => x.User != null ? x.User.FirstName : string.Empty),
                    "lastname" => query.OrderBy(x => x.User != null ? x.User.LastName : string.Empty),
                    "username" => query.OrderBy(x => x.User != null ? x.User.Username : string.Empty),
                    "checkin" => query.OrderBy(x => x.CheckInTime),
                    "checkindesc" => query.OrderByDescending(x => x.CheckInTime),
                    _ => query.OrderByDescending(x => x.CheckInTime)
                };
            }
            else
            {
                query = query.OrderByDescending(x => x.CheckInTime);
            }

            var totalCount = await query.CountAsync();

            var visits = await query
                .Skip((filter.PageNumber - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .Select(x => new VisitResponse()
                {
                    Id = x.Id,
                    UserId = x.UserId,
                    FirstName = x.User != null ? x.User.FirstName : string.Empty,
                    LastName = x.User != null ? x.User.LastName : string.Empty,
                    Username = x.User != null ? x.User.Username : string.Empty,
                    CheckInTime = x.CheckInTime
                }).ToListAsync();

            return new PagedResult<VisitResponse>
            {
                Items = visits,
                TotalCount = totalCount,
                PageNumber = filter.PageNumber
            };
        }

        public async Task<VisitResponse> CheckInAsync(CheckInRequest request)
        {
            var user = await _userRepository.GetByIdAsync(request.UserId);

            if (user == null)
                throw new KeyNotFoundException($"Korisnik sa ID '{request.UserId}' nije pronađen.");
            var existingActiveVisit = await _visitRepository.AsQueryable().AnyAsync(x => x.UserId == request.UserId && x.CheckOutTime == null);
            var hasActiveMembership = await _membershipRepository.AsQueryable().AnyAsync(x => x.UserId == request.UserId && x.EndDate > DateTime.UtcNow);
            if (!hasActiveMembership)
                throw new InvalidOperationException($"Korisnik '{user.FirstName} {user.LastName}' nema aktivnu članarinu.");
            if (existingActiveVisit)
                throw new InvalidOperationException($"Korisnik '{user.FirstName} {user.LastName}' je već prijavljen u teretanu.");

            var visit = new GymVisit
            {
                UserId = request.UserId,
                CheckInTime = DateTime.UtcNow
            };

            await _visitRepository.AddAsync(visit);

            return new VisitResponse
            {
                Id = visit.Id,
                UserId = visit.UserId,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Username = user.Username,
                CheckInTime = visit.CheckInTime,
            };
        }

        public async Task<VisitResponse> CheckOutAsync(int visitId)
        {
            var visit = await _visitRepository.GetByIdAsync(visitId);
            if (visit == null)
                throw new KeyNotFoundException($"Posjet sa ID '{visitId}' nije pronađen.");
            var user = await _userRepository.GetByIdAsync(visit.UserId);
            if (user == null) throw new KeyNotFoundException($"Korisnik sa ID '{visit.UserId}' nije pronađen");

            if (visit.CheckOutTime != null)
                throw new InvalidOperationException("Korisnik je već odjavljen iz teretane.");

            visit.CheckOutTime = DateTime.UtcNow;
            await _visitRepository.UpdateAsync(visit);
            return new VisitResponse()
            {
                Id = visit.Id,
                UserId = visit.UserId,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Username = user.Username,
                CheckInTime = visit.CheckInTime,
                CheckOutTime = visit.CheckOutTime
            };
        }
    }
}
