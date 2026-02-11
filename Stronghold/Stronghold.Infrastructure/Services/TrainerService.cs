using MapsterMapper;
using Microsoft.EntityFrameworkCore;
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
    public class TrainerService : BaseService<Trainer, TrainerResponse, CreateTrainerRequest, UpdateTrainerRequest, TrainerQueryFilter, int>, ITrainerService
    {
        private readonly IRepository<Appointment, int> _appointmentRepository;

        public TrainerService(IRepository<Trainer, int> repository, IRepository<Appointment, int> appointmentRepository, IMapper mapper) : base(repository, mapper)
        {
            _appointmentRepository = appointmentRepository;
        }

        protected override async Task BeforeCreateAsync(Trainer entity, CreateTrainerRequest dto)
        {
            var emailExists = await _repository.AsQueryable().AnyAsync(x => x.Email.ToLower() == dto.Email.ToLower());
            if (emailExists) throw new ConflictException("Email je vec zauzet.");

            var phoneExists = await _repository.AsQueryable().AnyAsync(x => x.PhoneNumber == dto.PhoneNumber);
            if (phoneExists) throw new ConflictException("Trener sa ovim brojem telefona vec postoji.");
        }

        protected override async Task BeforeUpdateAsync(Trainer entity, UpdateTrainerRequest dto)
        {
            if (!string.IsNullOrEmpty(dto.Email))
            {
                var emailExists = await _repository.AsQueryable().AnyAsync(x => x.Email.ToLower() == dto.Email.ToLower() && x.Id != entity.Id);
                if (emailExists) throw new ConflictException("Email je vec zauzet.");
            }

            if (!string.IsNullOrEmpty(dto.PhoneNumber))
            {
                var phoneExists = await _repository.AsQueryable().AnyAsync(x => x.PhoneNumber == dto.PhoneNumber && x.Id != entity.Id);
                if (phoneExists) throw new ConflictException("Trener sa ovim brojem telefona vec postoji.");
            }
        }

        protected override async Task BeforeDeleteAsync(Trainer entity)
        {
            var hasAppointments = await _repository.AsQueryable()
                .Where(x => x.Id == entity.Id)
                .SelectMany(x => x.Appointments)
                .AnyAsync();

            if (hasAppointments)
                throw new EntityHasDependentsException("trenera", "termine");
        }

        protected override IQueryable<Trainer> ApplyFilter(IQueryable<Trainer> query, TrainerQueryFilter filter)
        {
            if (!string.IsNullOrEmpty(filter.Search))
                query = query.Where(x => x.FirstName.ToLower().Contains(filter.Search.ToLower())
                    || x.LastName.ToLower().Contains(filter.Search.ToLower()));

            if (!string.IsNullOrEmpty(filter.OrderBy))
            {
                return filter.OrderBy.ToLower() switch
                {
                    "firstname" => query.OrderBy(x => x.FirstName),
                    "lastname" => query.OrderBy(x => x.LastName),
                    "createdatdesc" => query.OrderByDescending(x => x.CreatedAt),
                    _ => query.OrderBy(x => x.CreatedAt)
                };
            }

            return query.OrderBy(x => x.CreatedAt);
        }

        public async Task<AppointmentResponse> BookAppointmentAsync(int userId, int trainerId, DateTime date)
        {
            var normalizedDate = NormalizeAndValidateAppointmentDate(date);

            var trainer = await _repository.GetByIdAsync(trainerId);
            if (trainer == null) throw new KeyNotFoundException("Trener ne postoji.");

            var userHasAppointment = await _appointmentRepository.AsQueryable()
                .AnyAsync(x => x.UserId == userId && x.AppointmentDate.Date == normalizedDate.Date);
            if (userHasAppointment) throw new ConflictException("Korisnik vec ima termin na ovaj datum.");

            // Appointment duration is fixed to 1h: overlap only if intervals intersect.
            var slotStart = normalizedDate;
            var slotEnd = normalizedDate.AddHours(1);
            var isTrainerBusy = await _appointmentRepository.AsQueryable()
                .AnyAsync(x => x.TrainerId == trainerId
                    && x.AppointmentDate < slotEnd
                    && x.AppointmentDate.AddHours(1) > slotStart);
            if (isTrainerBusy) throw new InvalidOperationException("Odabrani trener je zauzet u ovom terminu.");

            var newAppointment = new Appointment
            {
                UserId = userId,
                TrainerId = trainerId,
                AppointmentDate = normalizedDate
            };

            try
            {
                await _appointmentRepository.AddAsync(newAppointment);
            }
            catch (DbUpdateException)
            {
                throw new ConflictException("Odabrani trener je zauzet u ovom terminu.");
            }

            return new AppointmentResponse
            {
                Id = newAppointment.Id,
                TrainerName = trainer.FirstName + " " + trainer.LastName,
                AppointmentDate = newAppointment.AppointmentDate
            };
        }

        public async Task<IEnumerable<int>> GetAvailableHoursAsync(int trainerId, DateTime date)
        {
            const int workStartHour = 9;
            const int workEndHour = 17;

            var localDate = DateTimeUtils.ToLocal(date);
            var targetDate = localDate.Date;
            if (targetDate <= DateTimeUtils.LocalToday)
            {
                return Enumerable.Empty<int>();
            }

            var appointments = await _appointmentRepository.AsQueryable()
                .Where(x => x.TrainerId == trainerId && x.AppointmentDate.Date == targetDate)
                .Select(x => x.AppointmentDate)
                .ToListAsync();

            var availableHours = new List<int>();
            for (int hour = workStartHour; hour < workEndHour; hour++)
            {
                var slotStart = targetDate.AddHours(hour);
                var slotEnd = slotStart.AddHours(1);
                var isBusy = appointments.Any(x => x < slotEnd && x.AddHours(1) > slotStart);
                if (!isBusy)
                {
                    availableHours.Add(hour);
                }
            }

            return availableHours;
        }

        private static DateTime NormalizeAndValidateAppointmentDate(DateTime date)
        {
            var localDate = DateTimeUtils.ToLocal(date);

            if (localDate < DateTimeUtils.LocalNow) throw new ArgumentException("Nemoguce unijeti datum u proslosti");
            if (localDate.Date == DateTimeUtils.LocalToday) throw new ArgumentException("Nemoguce napraviti termin na isti dan");
            if (localDate.Hour < 9 || localDate.Hour >= 17) throw new ArgumentException("Termini su moguci samo izmedju 9:00 i 17:00");
            if (localDate.Minute != 0 || localDate.Second != 0 || localDate.Millisecond != 0)
                throw new ArgumentException("Termin mora biti unesen na puni sat.");

            return new DateTime(localDate.Year, localDate.Month, localDate.Day, localDate.Hour, 0, 0, localDate.Kind);
        }
    }
}
