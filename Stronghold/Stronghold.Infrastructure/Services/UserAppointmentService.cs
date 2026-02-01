using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.AdminNutritionistDTO;
using Stronghold.Application.DTOs.AdminTrainerDTO;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Exceptions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Infrastructure.Services
{
    public class UserAppointmentService : IUserAppointmentService
    {
        private readonly IRepository<Appointment, int> _appointmentRepository;
        private readonly IRepository<Trainer,int> _trainerRepository;
        private readonly IRepository<Nutritionist, int> _nutritionistRepository;
        public UserAppointmentService(IRepository<Appointment, int> appointmentRepository, IRepository<Trainer, int> trainerRepository, IRepository<Nutritionist, int> nutritionistRepository)
        {
            _appointmentRepository = appointmentRepository;
            _trainerRepository = trainerRepository;
            _nutritionistRepository = nutritionistRepository;
        }

        public async Task<IEnumerable<UserAppointmentDTO>> GetAppointmentList(int userId)
        {

            var appointmentList = _appointmentRepository.AsQueryable().Where(x => x.UserId == userId && x.AppointmentDate > DateTime.UtcNow).Include(x => x.Trainer).Include(x => x.Nutritionist);
            var appointmentListDTO = await appointmentList.Select(x => new UserAppointmentDTO()
            {
                Id = x.Id,
                TrainerName = x.Trainer != null ? x.Trainer.FirstName + " " + x.Trainer.LastName : null,
                NutritionistName = x.Nutritionist != null ? x.Nutritionist.FirstName + " " + x.Nutritionist.LastName : null,
                AppointmentDate = x.AppointmentDate,
            }).ToListAsync();
            return appointmentListDTO;
        }
        public async Task<UserAppointmentDTO> MakeTrainingAppointmentAsync(int userId, int trainerId, DateTime date)
        {
            if (date < DateTime.UtcNow) throw new ArgumentException("Nemoguce unijeti datum u proslosti");
            if (date.Date==DateTime.Today) throw new ArgumentException("Nemoguce napraviti termin na isti dan");
            if (date.Hour < 9 || date.Hour >= 17) throw new ArgumentException("Termini su mogući samo između 9:00 i 17:00");


            var trainer = await _trainerRepository.GetByIdAsync(trainerId);
            if (trainer == null) throw new KeyNotFoundException("Trener ne postoji.");

            var userHasAppointment = await _appointmentRepository.AsQueryable()
                .AnyAsync(x => x.UserId == userId && x.AppointmentDate.Date==date.Date);
            if (userHasAppointment) throw new ConflictException("Korisnik vec ima termin na ovaj datum.");

            // Trainer availability check - 1 hour slots, check for overlap
            var slotStart = date.AddHours(-1);
            var slotEnd = date.AddHours(1);
            var isTrainerBusy = await _appointmentRepository.AsQueryable()
                .AnyAsync(x => x.TrainerId == trainerId && x.AppointmentDate > slotStart && x.AppointmentDate < slotEnd);
            if (isTrainerBusy) throw new InvalidOperationException("Odabrani trener je zauzet u ovom terminu.");

            var newAppointment = new Appointment()
            {
                UserId = userId,
                TrainerId = trainerId,
                AppointmentDate = date
            };

            try
            {
                await _appointmentRepository.AddAsync(newAppointment);
            }
            catch (DbUpdateException)
            {
                throw new ConflictException("Odabrani trener je zauzet u ovom terminu.");
            }

            return new UserAppointmentDTO()
            {
                Id = newAppointment.Id,
                TrainerName = trainer.FirstName + " " + trainer.LastName,
                AppointmentDate = newAppointment.AppointmentDate
            };
        }

        public async Task<UserAppointmentDTO> MakeNutritionistAppointmentAsync(int userId, int nutritionistId, DateTime date)
        {
            if (date < DateTime.UtcNow) throw new ArgumentException("Nemoguce unijeti datum u proslosti");
            if (date.Date == DateTime.Today) throw new ArgumentException("Nemoguce napraviti termin na isti dan");
            if (date.Hour < 9 || date.Hour >= 17) throw new ArgumentException("Termini su mogući samo između 9:00 i 17:00");


            var nutritionist = await _nutritionistRepository.GetByIdAsync(nutritionistId);
            if (nutritionist == null) throw new KeyNotFoundException("Nutricionist ne postoji.");

            // User can only have 1 appointment per day (date-only check)
            var userHasAppointment = await _appointmentRepository.AsQueryable()
                .AnyAsync(x => x.UserId == userId && x.AppointmentDate.Date ==date.Date);
            if (userHasAppointment) throw new ConflictException("Korisnik vec ima termin na ovaj datum.");

            // Nutritionist availability check - 1 hour slots, check for overlap
            var slotStart = date.AddHours(-1);
            var slotEnd = date.AddHours(1);
            var isNutritionistBusy = await _appointmentRepository.AsQueryable()
                .AnyAsync(x => x.NutritionistId == nutritionistId && x.AppointmentDate > slotStart && x.AppointmentDate < slotEnd);
            if (isNutritionistBusy) throw new InvalidOperationException("Odabrani nutricionist je zauzet u ovom terminu,pokušajte drugi termin.");

            var newAppointment = new Appointment()
            {
                UserId = userId,
                NutritionistId = nutritionistId,
                AppointmentDate = date
            };

            try
            {
                await _appointmentRepository.AddAsync(newAppointment);
            }
            catch (DbUpdateException)
            {
                throw new ConflictException("Odabrani nutricionist je zauzet u ovom terminu.");
            }

            return new UserAppointmentDTO()
            {
                Id = newAppointment.Id,
                NutritionistName = nutritionist.FirstName + " " + nutritionist.LastName,
                AppointmentDate = newAppointment.AppointmentDate
            };
        }
        public async Task<IEnumerable<TrainerDTO>> GetTrainerListAsync()
        {
            var trainerList = await _trainerRepository.GetAllAsync();
            var trainerListDTO = trainerList.Select(x => new TrainerDTO() 
            { 
                Id = x.Id,
                FirstName = x.FirstName,
                LastName = x.LastName,
                PhoneNumber = x.PhoneNumber,
                Email = x.Email
            }).ToList();
            return trainerListDTO;
        }
        public async Task<IEnumerable<NutritionistDTO>> GetNutritionistListAsync()
        {
            var nutritionistList = await _nutritionistRepository.GetAllAsync();
            var nutritionistListDTO = nutritionistList.Select(x => new NutritionistDTO()
            {
                Id = x.Id,
                FirstName = x.FirstName,
                LastName = x.LastName,
                PhoneNumber = x.PhoneNumber,
                Email = x.Email
            }).ToList();
            return nutritionistListDTO;
        }

        public async Task CancelAppointmentAsync(int userId, int appointmentId)
        {
            var appointment = await _appointmentRepository.AsQueryable().FirstOrDefaultAsync(x => x.UserId == userId && x.Id == appointmentId);
            if (appointment == null) throw new KeyNotFoundException("Termin ne postoji");
            if (appointment.AppointmentDate < DateTime.UtcNow) throw new InvalidOperationException("Nemoguce otkazati zavrseni termin");
            await _appointmentRepository.DeleteAsync(appointment);
        }

        public async Task<IEnumerable<int>> GetAvailableHoursAsync(int staffId, DateTime date, bool isTrainer)
        {
            const int workStartHour = 9;
            const int workEndHour = 17;

            // Get all appointments for this staff member on the given date
            List<int> bookedHours;
            if (isTrainer)
            {
                bookedHours = await _appointmentRepository.AsQueryable()
                    .Where(x => x.TrainerId == staffId && x.AppointmentDate.Date == date.Date)
                    .Select(x => x.AppointmentDate.Hour)
                    .ToListAsync();
            }
            else
            {
                bookedHours = await _appointmentRepository.AsQueryable()
                    .Where(x => x.NutritionistId == staffId && x.AppointmentDate.Date == date.Date)
                    .Select(x => x.AppointmentDate.Hour)
                    .ToListAsync();
            }

            // Generate available hours (9:00 - 17:00, excluding booked ones)
            var availableHours = new List<int>();
            for (int hour = workStartHour; hour < workEndHour; hour++)
            {
                if (!bookedHours.Contains(hour))
                {
                    availableHours.Add(hour);
                }
            }

            return availableHours;
        }
    }
}
