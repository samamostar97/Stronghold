using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Application.Common;

namespace Stronghold.Infrastructure.Services
{
    public class NutritionistService : BaseService<Nutritionist, NutritionistResponse, CreateNutritionistRequest, UpdateNutritionistRequest, NutritionistQueryFilter, int>, INutritionistService
    {
        private readonly IRepository<Appointment, int> _appointmentRepository;

        public NutritionistService(IRepository<Nutritionist, int> repository, IRepository<Appointment, int> appointmentRepository, IMapper mapper) : base(repository, mapper)
        {
            _appointmentRepository = appointmentRepository;
        }

        protected override async Task BeforeCreateAsync(Nutritionist entity, CreateNutritionistRequest dto)
        {
            var emailExists = await _repository.AsQueryable().AnyAsync(x => x.Email.ToLower() == dto.Email.ToLower());
            if (emailExists) throw new ConflictException("Email je vec zauzet.");

            var phoneExists = await _repository.AsQueryable().AnyAsync(x => x.PhoneNumber == dto.PhoneNumber);
            if (phoneExists) throw new ConflictException("Nutricionista sa ovim brojem telefona vec postoji.");
        }

        protected override async Task BeforeUpdateAsync(Nutritionist entity, UpdateNutritionistRequest dto)
        {
            if (!string.IsNullOrEmpty(dto.Email))
            {
                var emailExists = await _repository.AsQueryable().AnyAsync(x => x.Email.ToLower() == dto.Email.ToLower() && x.Id != entity.Id);
                if (emailExists) throw new ConflictException("Email je vec zauzet.");
            }

            if (!string.IsNullOrEmpty(dto.PhoneNumber))
            {
                var phoneExists = await _repository.AsQueryable().AnyAsync(x => x.PhoneNumber == dto.PhoneNumber && x.Id != entity.Id);
                if (phoneExists) throw new ConflictException("Nutricionista sa ovim brojem telefona vec postoji.");
            }
        }

        protected override async Task BeforeDeleteAsync(Nutritionist entity)
        {
            var hasAppointments = await _repository.AsQueryable()
                .Where(x => x.Id == entity.Id)
                .SelectMany(x => x.Appointments)
                .AnyAsync();

            if (hasAppointments)
                throw new EntityHasDependentsException("nutricionistu", "termine");
        }

        protected override IQueryable<Nutritionist> ApplyFilter(IQueryable<Nutritionist> query, NutritionistQueryFilter filter)
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

        public async Task<AppointmentResponse> BookAppointmentAsync(int userId, int nutritionistId, DateTime date)
        {
            var normalizedDate = NormalizeAndValidateAppointmentDate(date);

            var nutritionist = await _repository.GetByIdAsync(nutritionistId);
            if (nutritionist == null) throw new KeyNotFoundException("Nutricionist ne postoji.");

            var userHasAppointment = await _appointmentRepository.AsQueryable()
                .AnyAsync(x => x.UserId == userId && x.AppointmentDate.Date == normalizedDate.Date);
            if (userHasAppointment) throw new ConflictException("Korisnik vec ima termin na ovaj datum.");

            // Appointment duration is fixed to 1h: overlap only if intervals intersect.
            var slotStart = normalizedDate;
            var slotEnd = normalizedDate.AddHours(1);
            var isNutritionistBusy = await _appointmentRepository.AsQueryable()
                .AnyAsync(x => x.NutritionistId == nutritionistId
                    && x.AppointmentDate < slotEnd
                    && x.AppointmentDate.AddHours(1) > slotStart);
            if (isNutritionistBusy) throw new InvalidOperationException("Odabrani nutricionist je zauzet u ovom terminu, pokusajte drugi termin.");

            var newAppointment = new Appointment
            {
                UserId = userId,
                NutritionistId = nutritionistId,
                AppointmentDate = normalizedDate
            };

            try
            {
                await _appointmentRepository.AddAsync(newAppointment);
            }
            catch (DbUpdateException)
            {
                throw new ConflictException("Termin nije moguce rezervisati. Korisnik vec ima termin tog dana ili je odabrani nutricionist zauzet.");
            }

            return new AppointmentResponse
            {
                Id = newAppointment.Id,
                NutritionistName = nutritionist.FirstName + " " + nutritionist.LastName,
                AppointmentDate = newAppointment.AppointmentDate
            };
        }

        public async Task<IEnumerable<int>> GetAvailableHoursAsync(int nutritionistId, DateTime date)
        {
            const int workStartHour = 9;
            const int workEndHour = 17;

            var localDate = StrongholdTimeUtils.ToLocal(date);
            var targetDate = localDate.Date;
            if (targetDate <= StrongholdTimeUtils.LocalToday)
            {
                return Enumerable.Empty<int>();
            }

            var appointments = await _appointmentRepository.AsQueryable()
                .Where(x => x.NutritionistId == nutritionistId && x.AppointmentDate.Date == targetDate)
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
            var localDate = StrongholdTimeUtils.ToLocal(date);

            if (localDate < StrongholdTimeUtils.LocalNow) throw new ArgumentException("Nemoguce unijeti datum u proslosti");
            if (localDate.Date == StrongholdTimeUtils.LocalToday) throw new ArgumentException("Nemoguce napraviti termin na isti dan");
            if (localDate.Hour < 9 || localDate.Hour >= 17) throw new ArgumentException("Termini su moguci samo izmedju 9:00 i 17:00");
            if (localDate.Minute != 0 || localDate.Second != 0 || localDate.Millisecond != 0)
                throw new ArgumentException("Termin mora biti unesen na puni sat.");

            return new DateTime(localDate.Year, localDate.Month, localDate.Day, localDate.Hour, 0, 0, localDate.Kind);
        }
    }
}
