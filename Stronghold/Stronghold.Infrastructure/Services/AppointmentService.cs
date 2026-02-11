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
    public class AppointmentService : IAppointmentService
    {
        private readonly IRepository<Appointment, int> _appointmentRepository;
        private readonly ITrainerService _trainerService;
        private readonly INutritionistService _nutritionistService;

        public AppointmentService(
            IRepository<Appointment, int> appointmentRepository,
            ITrainerService trainerService,
            INutritionistService nutritionistService)
        {
            _appointmentRepository = appointmentRepository;
            _trainerService = trainerService;
            _nutritionistService = nutritionistService;
        }

        public async Task<PagedResult<AppointmentResponse>> GetAppointmentsByUserIdAsync(int userId, AppointmentQueryFilter filter)
        {
            var baseQuery = _appointmentRepository.AsQueryable()
                .Where(x => x.UserId == userId && x.AppointmentDate > DateTimeUtils.LocalNow)
                .Include(x => x.Trainer)
                .Include(x => x.Nutritionist);

            IQueryable<Appointment> query;
            if (!string.IsNullOrEmpty(filter.OrderBy))
            {
                query = filter.OrderBy.ToLower() switch
                {
                    "date" => baseQuery.OrderBy(x => x.AppointmentDate),
                    "datedesc" => baseQuery.OrderByDescending(x => x.AppointmentDate),
                    _ => baseQuery.OrderBy(x => x.AppointmentDate)
                };
            }
            else
            {
                query = baseQuery.OrderBy(x => x.AppointmentDate);
            }

            var totalCount = await query.CountAsync();

            var appointments = await query
                .Skip((filter.PageNumber - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .Select(x => new AppointmentResponse
                {
                    Id = x.Id,
                    TrainerName = x.Trainer != null ? x.Trainer.FirstName + " " + x.Trainer.LastName : null,
                    NutritionistName = x.Nutritionist != null ? x.Nutritionist.FirstName + " " + x.Nutritionist.LastName : null,
                    AppointmentDate = x.AppointmentDate,
                }).ToListAsync();

            return new PagedResult<AppointmentResponse>
            {
                Items = appointments,
                TotalCount = totalCount,
                PageNumber = filter.PageNumber
            };
        }

        public async Task<PagedResult<AdminAppointmentResponse>> GetAllAppointmentsAsync(AppointmentQueryFilter filter)
        {
            IQueryable<Appointment> baseQuery = _appointmentRepository.AsQueryable()
                .Include(x => x.User)
                .Include(x => x.Trainer)
                .Include(x => x.Nutritionist);

            if (!string.IsNullOrEmpty(filter.Search))
            {
                var search = filter.Search.ToLower();
                baseQuery = baseQuery.Where(x =>
                    (x.User.FirstName + " " + x.User.LastName).ToLower().Contains(search) ||
                    (x.Trainer != null && (x.Trainer.FirstName + " " + x.Trainer.LastName).ToLower().Contains(search)) ||
                    (x.Nutritionist != null && (x.Nutritionist.FirstName + " " + x.Nutritionist.LastName).ToLower().Contains(search)));
            }

            IQueryable<Appointment> query;
            if (!string.IsNullOrEmpty(filter.OrderBy))
            {
                query = filter.OrderBy.ToLower() switch
                {
                    "date" => baseQuery.OrderBy(x => x.AppointmentDate),
                    "datedesc" => baseQuery.OrderByDescending(x => x.AppointmentDate),
                    "user" => baseQuery.OrderBy(x => x.User.FirstName).ThenBy(x => x.User.LastName),
                    "userdesc" => baseQuery.OrderByDescending(x => x.User.FirstName).ThenByDescending(x => x.User.LastName),
                    _ => baseQuery.OrderByDescending(x => x.AppointmentDate)
                };
            }
            else
            {
                query = baseQuery.OrderByDescending(x => x.AppointmentDate);
            }

            var totalCount = await query.CountAsync();

            var appointments = await query
                .Skip((filter.PageNumber - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .Select(x => new AdminAppointmentResponse
                {
                    Id = x.Id,
                    UserId = x.UserId,
                    TrainerId = x.TrainerId,
                    NutritionistId = x.NutritionistId,
                    UserName = x.User.FirstName + " " + x.User.LastName,
                    TrainerName = x.Trainer != null ? x.Trainer.FirstName + " " + x.Trainer.LastName : null,
                    NutritionistName = x.Nutritionist != null ? x.Nutritionist.FirstName + " " + x.Nutritionist.LastName : null,
                    AppointmentDate = x.AppointmentDate,
                    Type = x.TrainerId != null ? "Trener" : "Nutricionista",
                }).ToListAsync();

            return new PagedResult<AdminAppointmentResponse>
            {
                Items = appointments,
                TotalCount = totalCount,
                PageNumber = filter.PageNumber,
            };
        }

        public async Task CancelAppointmentAsync(int userId, int appointmentId)
        {
            var appointment = await _appointmentRepository.AsQueryable()
                .FirstOrDefaultAsync(x => x.UserId == userId && x.Id == appointmentId);

            if (appointment == null)
                throw new KeyNotFoundException("Termin ne postoji");

            if (appointment.AppointmentDate < DateTimeUtils.LocalNow)
                throw new InvalidOperationException("Nemoguce otkazati zavrseni termin");

            await _appointmentRepository.DeleteAsync(appointment);
        }

        public async Task<int> AdminCreateAsync(AdminCreateAppointmentRequest request)
        {
            ValidateSingleStaffSelection(request.TrainerId, request.NutritionistId);
            var normalizedDate = NormalizeAndValidateAppointmentDate(request.AppointmentDate);

            if (request.TrainerId != null)
            {
                var result = await _trainerService.BookAppointmentAsync(
                    request.UserId, request.TrainerId.Value, normalizedDate);
                return result.Id;
            }

            var nutritionistResult = await _nutritionistService.BookAppointmentAsync(
                request.UserId, request.NutritionistId!.Value, normalizedDate);
            return nutritionistResult.Id;
        }

        public async Task AdminUpdateAsync(int id, AdminUpdateAppointmentRequest request)
        {
            var appointment = await _appointmentRepository.AsQueryable()
                .FirstOrDefaultAsync(x => x.Id == id);

            if (appointment == null)
                throw new KeyNotFoundException("Termin ne postoji.");

            ValidateSingleStaffSelection(request.TrainerId, request.NutritionistId);
            var normalizedDate = NormalizeAndValidateAppointmentDate(request.AppointmentDate);

            var userHasAppointment = await _appointmentRepository.AsQueryable()
                .AnyAsync(x => x.UserId == appointment.UserId
                    && x.AppointmentDate.Date == normalizedDate.Date
                    && x.Id != id);
            if (userHasAppointment)
                throw new InvalidOperationException("Korisnik vec ima termin na ovaj datum.");

            var slotStart = normalizedDate;
            var slotEnd = normalizedDate.AddHours(1);

            if (request.TrainerId != null)
            {
                var isTrainerBusy = await _appointmentRepository.AsQueryable()
                    .AnyAsync(x => x.TrainerId == request.TrainerId
                        && x.Id != id
                        && x.AppointmentDate < slotEnd
                        && x.AppointmentDate.AddHours(1) > slotStart);
                if (isTrainerBusy)
                    throw new InvalidOperationException("Odabrani trener je zauzet u ovom terminu.");
            }

            if (request.NutritionistId != null)
            {
                var isNutritionistBusy = await _appointmentRepository.AsQueryable()
                    .AnyAsync(x => x.NutritionistId == request.NutritionistId
                        && x.Id != id
                        && x.AppointmentDate < slotEnd
                        && x.AppointmentDate.AddHours(1) > slotStart);
                if (isNutritionistBusy)
                    throw new InvalidOperationException("Odabrani nutricionista je zauzet/a u ovom terminu.");
            }

            appointment.TrainerId = request.TrainerId;
            appointment.NutritionistId = request.NutritionistId;
            appointment.AppointmentDate = normalizedDate;

            await _appointmentRepository.UpdateAsync(appointment);
        }

        public async Task AdminDeleteAsync(int id)
        {
            var appointment = await _appointmentRepository.AsQueryable()
                .FirstOrDefaultAsync(x => x.Id == id);

            if (appointment == null)
                throw new KeyNotFoundException("Termin ne postoji.");

            await _appointmentRepository.DeleteAsync(appointment);
        }

        private static void ValidateSingleStaffSelection(int? trainerId, int? nutritionistId)
        {
            if (trainerId == null && nutritionistId == null)
                throw new ArgumentException("Morate odabrati trenera ili nutricionistu.");

            if (trainerId != null && nutritionistId != null)
                throw new ArgumentException("Termin moze biti samo kod trenera ili nutricioniste, ne oba.");
        }

        private static DateTime NormalizeAndValidateAppointmentDate(DateTime date)
        {
            var localDate = DateTimeUtils.ToLocal(date);

            if (localDate < DateTimeUtils.LocalNow)
                throw new ArgumentException("Nemoguce unijeti datum u proslosti");

            if (localDate.Date == DateTimeUtils.LocalToday)
                throw new ArgumentException("Nemoguce napraviti termin na isti dan");

            if (localDate.Hour < 9 || localDate.Hour >= 17)
                throw new ArgumentException("Termini su moguci samo izmedju 9:00 i 17:00.");

            if (localDate.Minute != 0 || localDate.Second != 0 || localDate.Millisecond != 0)
                throw new ArgumentException("Termin mora biti unesen na puni sat.");

            return new DateTime(localDate.Year, localDate.Month, localDate.Day, localDate.Hour, 0, 0, localDate.Kind);
        }
    }
}
