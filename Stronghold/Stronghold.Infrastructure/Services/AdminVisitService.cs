using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.AdminUsersDTO;
using Stronghold.Application.DTOs.AdminVisitsDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;
using System.Security.Cryptography.X509Certificates;

namespace Stronghold.Infrastructure.Services
{
    public class AdminVisitService : IAdminVisitService
    {
        private readonly IRepository<GymVisit, int> _visitRepository;
        private readonly IRepository<User, int> _userRepository;
        private readonly IMapper _mapper;

        public AdminVisitService(IRepository<User, int> userRepository,IRepository<GymVisit, int> visitRepository, IMapper mapper)
        {
            _userRepository= userRepository;
            _visitRepository= visitRepository;
            _mapper= mapper;
        }

        public async Task<IEnumerable<VisitDTO>> GetCurrentVisitorsAsync()
        {
            var visit = await _visitRepository.AsQueryable()
                                              .Where(x => x.CheckOutTime == null && !x.IsDeleted)
                                              .Select(x=> new VisitDTO()
                                              {
                                                  Id=x.Id,
                                                  UserId=x.UserId,
                                                  FirstName=x.User.FirstName,
                                                  LastName=x.User.LastName,
                                                  Username=x.User.Username,
                                                  CheckInTime=x.CheckInTime

                                              }).ToListAsync();
            return visit;

        }

        public async Task<VisitDTO> CheckInAsync(CheckInRequestDTO request)
        {
            var user = await _userRepository.GetByIdAsync(request.UserId);

            if (user == null)
                throw new KeyNotFoundException($"Korisnik sa ID '{request.UserId}' nije pronađen.");

            var existingActiveVisit = await _visitRepository.AsQueryable().AnyAsync(x=>x.UserId == request.UserId&& x.CheckOutTime==null);

            if (existingActiveVisit)
                throw new InvalidOperationException($"Korisnik '{user.FirstName} {user.LastName}' je već prijavljen u teretanu.");

            var visit = new GymVisit
            {
                UserId = request.UserId,
                CheckInTime = DateTime.UtcNow
            };

            await _visitRepository.AddAsync(visit);

            return new VisitDTO
            {
                Id = visit.Id,
                UserId = visit.UserId,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Username = user.Username,
                CheckInTime = visit.CheckInTime,
            };
        }

        public async Task<VisitDTO> CheckOutAsync(int visitId)
        {
            var visit = await _visitRepository.GetByIdAsync(visitId);
            if (visit == null)
                throw new KeyNotFoundException($"Posjet sa ID '{visitId}' nije pronađen.");
            var user = await _userRepository.GetByIdAsync(visit.UserId);
            if (user == null) throw new KeyNotFoundException($"User sa ID '{visit.UserId}' nije pronadjen");
            

            if (visit.CheckOutTime != null)
                throw new InvalidOperationException("Korisnik je već odjavljen iz teretane.");

            visit.CheckOutTime = DateTime.UtcNow;
            await _visitRepository.UpdateAsync(visit);
            return new VisitDTO()
            {
                Id = visit.Id,
                UserId = visit.UserId,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Username=user.Username,
                CheckInTime = visit.CheckInTime,
                CheckOutTime = visit.CheckOutTime
            };

        }
    }
}
