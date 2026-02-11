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
using Stronghold.Infrastructure.Common;

namespace Stronghold.Infrastructure.Services
{
    public class SeminarService : BaseService<Seminar, SeminarResponse, CreateSeminarRequest, UpdateSeminarRequest, SeminarQueryFilter, int>, ISeminarService
    {
        private const string StatusActive = "active";
        private const string StatusCancelled = "cancelled";
        private const string StatusFinished = "finished";

        private readonly IRepository<SeminarAttendee, int> _attendeeRepository;

        public SeminarService(
            IRepository<Seminar, int> repository,
            IRepository<SeminarAttendee, int> attendeeRepository,
            IMapper mapper) : base(repository, mapper)
        {
            _attendeeRepository = attendeeRepository;
        }

        protected override async Task BeforeCreateAsync(Seminar entity, CreateSeminarRequest dto)
        {
            var normalizedEventDate = DateTimeUtils.ToUtc(dto.EventDate);

            var seminarExists = await _repository.AsQueryable()
                .AnyAsync(x => x.Topic.ToLower() == dto.Topic.ToLower() && x.EventDate == normalizedEventDate);
            if (seminarExists)
            {
                throw new ConflictException("Seminar sa ovom temom na odabrani datum vec postoji.");
            }

            if (normalizedEventDate < DateTimeUtils.UtcNow)
            {
                throw new ArgumentException("Nemoguce unijeti datum u proslosti.");
            }

            entity.EventDate = normalizedEventDate;
        }

        protected override async Task BeforeUpdateAsync(Seminar entity, UpdateSeminarRequest dto)
        {
            if (entity.IsCancelled)
            {
                throw new InvalidOperationException("Nije moguce izmijeniti otkazan seminar.");
            }

            var eventDate = dto.EventDate.HasValue ? DateTimeUtils.ToUtc(dto.EventDate.Value) : entity.EventDate;
            var topic = !string.IsNullOrEmpty(dto.Topic) ? dto.Topic : entity.Topic;

            if (dto.EventDate != null && eventDate < DateTimeUtils.UtcNow)
            {
                throw new ArgumentException("Nemoguce unijeti datum u proslosti.");
            }

            if (!string.IsNullOrEmpty(dto.Topic) || dto.EventDate != null)
            {
                var seminarExists = await _repository.AsQueryable()
                    .AnyAsync(x => x.Topic.ToLower() == topic.ToLower() && x.EventDate == eventDate && x.Id != entity.Id);
                if (seminarExists)
                {
                    throw new ConflictException("Seminar sa ovom temom vec postoji na odabranom datumu.");
                }
            }

            if (dto.EventDate != null)
            {
                dto.EventDate = eventDate;
            }
        }

        protected override async Task BeforeDeleteAsync(Seminar entity)
        {
            var hasAttendees = await _repository.AsQueryable()
                .Where(x => x.Id == entity.Id)
                .SelectMany(x => x.SeminarAttendees)
                .AnyAsync();

            if (hasAttendees)
            {
                throw new EntityHasDependentsException("seminar", "ucesnike");
            }
        }

        protected override IQueryable<Seminar> ApplyFilter(IQueryable<Seminar> query, SeminarQueryFilter filter)
        {
            var now = DateTimeUtils.UtcNow;

            if (!string.IsNullOrEmpty(filter.Search))
            {
                query = query.Where(x => x.SpeakerName.ToLower().Contains(filter.Search.ToLower())
                                         || x.Topic.ToLower().Contains(filter.Search.ToLower()));
            }

            if (!string.IsNullOrWhiteSpace(filter.Status))
            {
                query = filter.Status.Trim().ToLowerInvariant() switch
                {
                    StatusActive => query.Where(x => !x.IsCancelled && x.EventDate > now),
                    StatusCancelled => query.Where(x => x.IsCancelled),
                    StatusFinished => query.Where(x => !x.IsCancelled && x.EventDate <= now),
                    _ => query
                };
            }
            else if (filter.IsCancelled.HasValue)
            {
                query = query.Where(x => x.IsCancelled == filter.IsCancelled.Value);
            }

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

        public override async Task<PagedResult<SeminarResponse>> GetPagedAsync(SeminarQueryFilter filter)
        {
            var result = await base.GetPagedAsync(filter);
            var now = DateTimeUtils.UtcNow;

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
                    seminar.Status = ResolveStatus(seminar.EventDate, seminar.IsCancelled, now);
                }
            }

            return result;
        }

        public override async Task<IEnumerable<SeminarResponse>> GetAllAsync(SeminarQueryFilter filter)
        {
            var result = (await base.GetAllAsync(filter)).ToList();
            var now = DateTimeUtils.UtcNow;

            if (result.Any())
            {
                var seminarIds = result.Select(x => x.Id).ToList();
                var attendeeCounts = await _attendeeRepository.AsQueryable()
                    .Where(a => seminarIds.Contains(a.SeminarId))
                    .GroupBy(a => a.SeminarId)
                    .Select(g => new { SeminarId = g.Key, Count = g.Count() })
                    .ToDictionaryAsync(x => x.SeminarId, x => x.Count);

                foreach (var seminar in result)
                {
                    seminar.CurrentAttendees = attendeeCounts.GetValueOrDefault(seminar.Id, 0);
                    seminar.Status = ResolveStatus(seminar.EventDate, seminar.IsCancelled, now);
                }
            }

            return result;
        }

        public override async Task<SeminarResponse> GetByIdAsync(int id)
        {
            var result = await base.GetByIdAsync(id);
            var now = DateTimeUtils.UtcNow;
            result.CurrentAttendees = await _attendeeRepository.AsQueryable()
                .CountAsync(a => a.SeminarId == id);
            result.Status = ResolveStatus(result.EventDate, result.IsCancelled, now);
            return result;
        }

        public async Task<IEnumerable<UserSeminarResponse>> GetUpcomingSeminarsAsync(int userId)
        {
            var now = DateTimeUtils.UtcNow;

            var userAttendances = _attendeeRepository.AsQueryable()
                .Where(a => a.UserId == userId)
                .Select(a => a.SeminarId);

            var seminarList = _repository.AsQueryable()
                .Where(x => x.EventDate > now && !x.IsCancelled);
            var seminarListDTO = await seminarList.Select(x => new UserSeminarResponse
            {
                Id = x.Id,
                Topic = x.Topic,
                SpeakerName = x.SpeakerName,
                EventDate = x.EventDate,
                IsAttending = userAttendances.Contains(x.Id),
                MaxCapacity = x.MaxCapacity,
                CurrentAttendees = x.SeminarAttendees.Count(),
                IsFull = x.SeminarAttendees.Count() >= x.MaxCapacity,
                IsCancelled = x.IsCancelled,
                Status = StatusActive,
            }).ToListAsync();

            return seminarListDTO;
        }

        public async Task AttendSeminarAsync(int userId, int seminarId)
        {
            var now = DateTimeUtils.UtcNow;

            var seminar = await _repository.AsQueryable()
                .FirstOrDefaultAsync(x => x.EventDate > now && !x.IsCancelled && x.Id == seminarId);
            if (seminar == null)
            {
                throw new KeyNotFoundException("Seminar ne postoji, zavrsio je, ili je otkazan.");
            }

            var attendeeCount = await _attendeeRepository.AsQueryable()
                .CountAsync(x => x.SeminarId == seminarId);
            if (attendeeCount >= seminar.MaxCapacity)
            {
                throw new InvalidOperationException("Seminar je popunjen. Nema slobodnih mjesta.");
            }

            var isAlreadyAttending = await _attendeeRepository.AsQueryable()
                .AnyAsync(x => x.UserId == userId && x.SeminarId == seminarId);
            if (isAlreadyAttending)
            {
                throw new InvalidOperationException("Korisnik je vec prijavljen na ovaj seminar");
            }

            var addAttendance = new SeminarAttendee
            {
                UserId = userId,
                SeminarId = seminarId,
                RegisteredAt = now,
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
            var now = DateTimeUtils.UtcNow;

            var hasSeminarEnded = await _repository.AsQueryable()
                .AnyAsync(x => x.Id == seminarId && x.EventDate < now);
            if (hasSeminarEnded)
            {
                throw new InvalidOperationException("Nemoguce otkazati seminar u proslosti");
            }

            var isAttending = await _attendeeRepository.AsQueryable()
                .FirstOrDefaultAsync(x => x.UserId == userId && x.SeminarId == seminarId);
            if (isAttending == null)
            {
                throw new InvalidOperationException("Niste prijavljeni na ovaj seminar");
            }

            await _attendeeRepository.DeleteAsync(isAttending);
        }

        public async Task CancelSeminarAsync(int seminarId)
        {
            var seminar = await _repository.GetByIdAsync(seminarId);

            if (seminar.IsCancelled)
            {
                throw new InvalidOperationException("Seminar je vec otkazan.");
            }

            if (seminar.EventDate <= DateTimeUtils.UtcNow)
            {
                throw new InvalidOperationException("Nije moguce otkazati seminar koji je vec poceo ili je zavrsen.");
            }

            seminar.IsCancelled = true;
            await _repository.UpdateAsync(seminar);
        }

        public async Task<IEnumerable<SeminarAttendeeResponse>> GetSeminarAttendeesAsync(int seminarId)
        {
            var seminarExists = await _repository.AsQueryable().AnyAsync(x => x.Id == seminarId);
            if (!seminarExists)
            {
                throw new KeyNotFoundException("Seminar ne postoji.");
            }

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

        private static string ResolveStatus(DateTime eventDate, bool isCancelled, DateTime nowUtc)
        {
            if (isCancelled)
            {
                return StatusCancelled;
            }

            return eventDate <= nowUtc ? StatusFinished : StatusActive;
        }
    }
}
