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
                .Where(x => x.UserId == userId && x.AppointmentDate > DateTime.UtcNow)
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
                .Select(x => new AppointmentResponse()
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
            var baseQuery = _appointmentRepository.AsQueryable()
                .Include(x => x.User)
                .Include(x => x.Trainer)
                .Include(x => x.Nutritionist)
                .AsQueryable();

            // Search filter
            if (!string.IsNullOrEmpty(filter.Search))
            {
                var search = filter.Search.ToLower();
                baseQuery = baseQuery.Where(x =>
                    (x.User.FirstName + " " + x.User.LastName).ToLower().Contains(search) ||
                    (x.Trainer != null && (x.Trainer.FirstName + " " + x.Trainer.LastName).ToLower().Contains(search)) ||
                    (x.Nutritionist != null && (x.Nutritionist.FirstName + " " + x.Nutritionist.LastName).ToLower().Contains(search)));
            }

            // Sorting
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

            if (appointment.AppointmentDate < DateTime.UtcNow)
                throw new InvalidOperationException("Nemoguce otkazati zavrseni termin");

            await _appointmentRepository.DeleteAsync(appointment);
        }

        public async Task<int> AdminCreateAsync(AdminCreateAppointmentRequest request)
        {
            // Delegate to existing booking services which handle all validation
            // (working hours, staff availability, user daily limit)
            if (request.TrainerId != null)
            {
                var result = await _trainerService.BookAppointmentAsync(
                    request.UserId, request.TrainerId.Value, request.AppointmentDate);
                return result.Id;
            }
            else
            {
                var result = await _nutritionistService.BookAppointmentAsync(
                    request.UserId, request.NutritionistId!.Value, request.AppointmentDate);
                return result.Id;
            }
        }

        public async Task AdminUpdateAsync(int id, AdminUpdateAppointmentRequest request)
        {
            var appointment = await _appointmentRepository.AsQueryable()
                .FirstOrDefaultAsync(x => x.Id == id);

            if (appointment == null)
                throw new KeyNotFoundException("Termin ne postoji.");

            var date = request.AppointmentDate;

            // Same validation rules as BookAppointmentAsync
            if (date <= DateTime.UtcNow)
                throw new ArgumentException("Datum termina mora biti u buducnosti.");

            if (date.Hour < 9 || date.Hour >= 17)
                throw new ArgumentException("Termini su mogući samo između 9:00 i 17:00.");

            // User can only have 1 appointment per day (exclude current appointment)
            var userHasAppointment = await _appointmentRepository.AsQueryable()
                .AnyAsync(x => x.UserId == appointment.UserId
                    && x.AppointmentDate.Date == date.Date
                    && x.Id != id);
            if (userHasAppointment)
                throw new InvalidOperationException("Korisnik vec ima termin na ovaj datum.");

            // Staff availability - 1h slot overlap (exclude current appointment)
            var slotStart = date.AddHours(-1);
            var slotEnd = date.AddHours(1);

            if (request.TrainerId != null)
            {
                var isTrainerBusy = await _appointmentRepository.AsQueryable()
                    .AnyAsync(x => x.TrainerId == request.TrainerId
                        && x.AppointmentDate >= slotStart
                        && x.AppointmentDate <= slotEnd
                        && x.Id != id);
                if (isTrainerBusy)
                    throw new InvalidOperationException("Odabrani trener je zauzet u ovom terminu.");
            }

            if (request.NutritionistId != null)
            {
                var isNutritionistBusy = await _appointmentRepository.AsQueryable()
                    .AnyAsync(x => x.NutritionistId == request.NutritionistId
                        && x.AppointmentDate >= slotStart
                        && x.AppointmentDate <= slotEnd
                        && x.Id != id);
                if (isNutritionistBusy)
                    throw new InvalidOperationException("Odabrani nutricionista je zauzet/a u ovom terminu.");
            }

            appointment.TrainerId = request.TrainerId;
            appointment.NutritionistId = request.NutritionistId;
            appointment.AppointmentDate = request.AppointmentDate;

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
    }
}
