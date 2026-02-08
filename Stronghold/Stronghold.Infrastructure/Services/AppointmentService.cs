using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
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

        public AppointmentService(IRepository<Appointment, int> appointmentRepository)
        {
            _appointmentRepository = appointmentRepository;
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
    }
}
