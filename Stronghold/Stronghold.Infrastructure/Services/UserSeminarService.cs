using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.AdminSeminarDTO;
using Stronghold.Application.DTOs.UserDTOs;
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
    public class UserSeminarService : IUserSeminarService
    {
        private readonly IRepository<Seminar, int> _seminarRepository;
        private readonly IRepository<SeminarAttendee,int> _attendeeRepository;
        public UserSeminarService(IRepository<Seminar,int> seminarRepository, IRepository<SeminarAttendee, int> attendeeRepository)
        {
            _seminarRepository = seminarRepository;
            _attendeeRepository = attendeeRepository;
        }

        public async Task AttendSeminarAsync(int userId, int seminarId)
        {
            var seminarExists = await _seminarRepository.AsQueryable().AnyAsync(x => x.EventDate > DateTime.UtcNow&&x.Id==seminarId);
            if (!seminarExists) throw new KeyNotFoundException("Seminar ne postoji, ili je zavrsio");
            var isAlreadyAttending = await _attendeeRepository.AsQueryable().AnyAsync(x => x.UserId == userId && x.SeminarId == seminarId);
            if (isAlreadyAttending) throw new InvalidOperationException("Korisnik je vec prijavljen na ovaj seminar");
            var addAttendance = new SeminarAttendee()
            {
                UserId = userId,
                SeminarId = seminarId,
                RegisteredAt = DateTime.UtcNow,
            };
            await _attendeeRepository.AddAsync(addAttendance);
            
        }

        public async Task<IEnumerable<UserSeminarDTO>> GetSeminarListAsync(int userId)
        {
            var userAttendances = _attendeeRepository.AsQueryable()
                .Where(a => a.UserId == userId)
                .Select(a => a.SeminarId);

            var seminarList = _seminarRepository.AsQueryable().Where(x => x.EventDate > DateTime.UtcNow);
            var seminarListDTO = await seminarList.Select(x => new UserSeminarDTO()
            {
                Id = x.Id,
                Topic = x.Topic,
                SpeakerName = x.SpeakerName,
                EventDate = x.EventDate,
                IsAttending = userAttendances.Contains(x.Id),
            }).ToListAsync();
            return seminarListDTO;
        }
    }
}
