using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Services
{
    public class SeminarService : BaseService<Seminar, SeminarResponse, CreateSeminarRequest, UpdateSeminarRequest, SeminarQueryFilter, int>, ISeminarService
    {
        private readonly IRepository<SeminarAttendee, int> _attendeeRepository;

        public SeminarService(IRepository<Seminar, int> repository, IRepository<SeminarAttendee, int> attendeeRepository, IMapper mapper) : base(repository, mapper)
        {
            _attendeeRepository = attendeeRepository;
        }

        protected override async Task BeforeCreateAsync(Seminar entity, CreateSeminarRequest dto)
        {
            var seminarExists = await _repository.AsQueryable().AnyAsync(x => x.Topic.ToLower() == dto.Topic.ToLower() && x.EventDate == dto.EventDate);
            if (seminarExists) throw new ConflictException("Seminar sa ovom temom na odabrani datum već postoji.");

            if (dto.EventDate < DateTime.UtcNow)
                throw new ArgumentException("Nemoguće unijeti datum u prošlosti.");
        }

        protected override async Task BeforeUpdateAsync(Seminar entity, UpdateSeminarRequest dto)
        {
            var eventDate = dto.EventDate ?? entity.EventDate;
            var topic = !string.IsNullOrEmpty(dto.Topic) ? dto.Topic : entity.Topic;

            if (dto.EventDate != null && dto.EventDate < DateTime.UtcNow)
                throw new ArgumentException("Nemoguće unijeti datum u prošlosti.");

            if (!string.IsNullOrEmpty(dto.Topic) || dto.EventDate != null)
            {
                var seminarExists = await _repository.AsQueryable().AnyAsync(x => x.Topic.ToLower() == topic.ToLower() && x.EventDate == eventDate && x.Id != entity.Id);
                if (seminarExists) throw new ConflictException("Seminar sa ovom temom već postoji na odabranom datumu.");
            }
        }

        protected override async Task BeforeDeleteAsync(Seminar entity)
        {
            var hasAttendees = await _repository.AsQueryable()
                .Where(x => x.Id == entity.Id)
                .SelectMany(x => x.SeminarAttendees)
                .AnyAsync();

            if (hasAttendees)
                throw new EntityHasDependentsException("seminar", "učesnike");
        }

        protected override IQueryable<Seminar> ApplyFilter(IQueryable<Seminar> query, SeminarQueryFilter filter)
        {
            if (!string.IsNullOrEmpty(filter.Search))
                query = query.Where(x => x.SpeakerName.ToLower().Contains(filter.Search.ToLower())
                                         || x.Topic.ToLower().Contains(filter.Search.ToLower()));

            if (!string.IsNullOrEmpty(filter.OrderBy))
            {
                return filter.OrderBy.ToLower() switch
                {
                    "topic" => query.OrderBy(x => x.Topic),
                    "speakername" => query.OrderBy(x => x.SpeakerName),
                    "eventdate" => query.OrderBy(x => x.EventDate),
                    "eventdatedesc" => query.OrderByDescending(x => x.EventDate),
                    _ => query.OrderByDescending(x => x.EventDate)
                };
            }

            return query.OrderByDescending(x => x.EventDate);
        }

        // Override to include attendee count in paged results
        public override async Task<PagedResult<SeminarResponse>> GetPagedAsync(SeminarQueryFilter filter)
        {
            var result = await base.GetPagedAsync(filter);

            if (result.Items.Any())
            {
                var seminarIds = result.Items.Select(s => s.Id).ToList();
                var attendeeCounts = await _attendeeRepository.AsQueryable()
                    .Where(a => seminarIds.Contains(a.SeminarId))
                    .GroupBy(a => a.SeminarId)
                    .Select(g => new { SeminarId = g.Key, Count = g.Count() })
                    .ToDictionaryAsync(x => x.SeminarId, x => x.Count);

                foreach (var seminar in result.Items)
                {
                    seminar.CurrentAttendees = attendeeCounts.GetValueOrDefault(seminar.Id, 0);
                }
            }

            return result;
        }

        // Override to include attendee count in single item result
        public override async Task<SeminarResponse> GetByIdAsync(int id)
        {
            var result = await base.GetByIdAsync(id);
            result.CurrentAttendees = await _attendeeRepository.AsQueryable()
                .CountAsync(a => a.SeminarId == id);
            return result;
        }

        public async Task<IEnumerable<UserSeminarResponse>> GetUpcomingSeminarsAsync(int userId)
        {
            var userAttendances = _attendeeRepository.AsQueryable()
                .Where(a => a.UserId == userId)
                .Select(a => a.SeminarId);

            var seminarList = _repository.AsQueryable().Where(x => x.EventDate > DateTime.UtcNow);
            var seminarListDTO = await seminarList.Select(x => new UserSeminarResponse()
            {
                Id = x.Id,
                Topic = x.Topic,
                SpeakerName = x.SpeakerName,
                EventDate = x.EventDate,
                IsAttending = userAttendances.Contains(x.Id),
                MaxCapacity = x.MaxCapacity,
                CurrentAttendees = x.SeminarAttendees.Count(),
                IsFull = x.SeminarAttendees.Count() >= x.MaxCapacity,
            }).ToListAsync();
            return seminarListDTO;
        }

        public async Task AttendSeminarAsync(int userId, int seminarId)
        {
            var seminar = await _repository.AsQueryable()
                .FirstOrDefaultAsync(x => x.EventDate > DateTime.UtcNow && x.Id == seminarId);
            if (seminar == null) throw new KeyNotFoundException("Seminar ne postoji, ili je zavrsio");

            // Check capacity
            var attendeeCount = await _attendeeRepository.AsQueryable()
                .CountAsync(x => x.SeminarId == seminarId);
            if (attendeeCount >= seminar.MaxCapacity)
                throw new InvalidOperationException("Seminar je popunjen. Nema slobodnih mjesta.");

            var isAlreadyAttending = await _attendeeRepository.AsQueryable().AnyAsync(x => x.UserId == userId && x.SeminarId == seminarId);
            if (isAlreadyAttending) throw new InvalidOperationException("Korisnik je vec prijavljen na ovaj seminar");
            var addAttendance = new SeminarAttendee()
            {
                UserId = userId,
                SeminarId = seminarId,
                RegisteredAt = DateTime.UtcNow,
            };

            try
            {
                await _attendeeRepository.AddAsync(addAttendance);
            }
            catch (DbUpdateException)
            {
                throw new ConflictException("Korisnik je vec prijavljen na ovaj seminar.");
            }
        }

        public async Task CancelAttendanceAsync(int userId, int seminarId)
        {
            var hasSeminarEnded = await _repository.AsQueryable().AnyAsync(x => x.Id == seminarId && x.EventDate < DateTime.UtcNow);
            if (hasSeminarEnded) throw new InvalidOperationException("Nemoguce otkazati seminar u proslosti");
            var isAttending = await _attendeeRepository.AsQueryable().FirstOrDefaultAsync(x => x.UserId == userId && x.SeminarId == seminarId);
            if (isAttending == null) throw new InvalidOperationException("Niste prijavljeni na ovaj seminar");
            await _attendeeRepository.DeleteAsync(isAttending);
        }

        public async Task<IEnumerable<SeminarAttendeeResponse>> GetSeminarAttendeesAsync(int seminarId)
        {
            var seminarExists = await _repository.AsQueryable().AnyAsync(x => x.Id == seminarId);
            if (!seminarExists) throw new KeyNotFoundException("Seminar ne postoji.");

            var attendees = await _attendeeRepository.AsQueryable()
                .Where(a => a.SeminarId == seminarId)
                .Include(a => a.User)
                .OrderBy(a => a.RegisteredAt)
                .Select(a => new SeminarAttendeeResponse
                {
                    UserId = a.UserId,
                    UserName = a.User.FirstName + " " + a.User.LastName,
                    RegisteredAt = a.RegisteredAt,
                })
                .ToListAsync();

            return attendees;
        }
    }
}
