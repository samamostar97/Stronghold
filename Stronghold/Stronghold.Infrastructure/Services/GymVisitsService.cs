using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.AdminVisitsDTO;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Infrastructure.Services
{
    public class GymVisitsService : IGymVisitsService
    {
        private readonly IRepository<GymVisit, int> _visitRepository;
        private readonly IRepository<User, int> _userRepository;

        // Constructor injection - .NET gives us the repositories automatically
        public GymVisitsService(
            IRepository<GymVisit, int> visitRepository,
            IRepository<User, int> userRepository)
        {
            _visitRepository = visitRepository;
            _userRepository = userRepository;
        }

        public async Task<IEnumerable<CurrentVisitorDTO>> GetCurrentVisitorsAsync()
        {
            // Query: Get all visits where CheckOutTime is null (still in gym)
            var currentVisits = await _visitRepository.AsQueryable()
                .Include(v => v.User)  // Load the User data too
                .Where(v => v.CheckOutTime == null && !v.IsDeleted)
                .ToListAsync();

            // Convert entities to DTOs
            return currentVisits.Select(v => MapToDTO(v));
        }

        public async Task<CurrentVisitorDTO> CheckInAsync(AdminCheckInDTO dto)
        {
            // Validation 1: Does the user exist?
            var user = await _userRepository.GetByIdAsync(dto.UserId);
            if (user == null)
            {
                throw new ArgumentException($"User with ID {dto.UserId} not found");
            }

            // Validation 2: Is the user already checked in?
            var existingVisit = await _visitRepository.AsQueryable()
                .FirstOrDefaultAsync(v => v.UserId == dto.UserId
                                       && v.CheckOutTime == null
                                       && !v.IsDeleted);
            if (existingVisit != null)
            {
                throw new InvalidOperationException($"User {user.Username} is already checked in");
            }

            // Create new visit record
            var visit = new GymVisit
            {
                UserId = dto.UserId,
                CheckInTime = DateTime.UtcNow
            };

            await _visitRepository.AddAsync(visit);

            // Need to load the user for the response
            visit.User = user;

            return MapToDTO(visit);
        }

        public async Task CheckOutAsync(int gymVisitId)
        {
            // Find the visit
            var visit = await _visitRepository.GetByIdAsync(gymVisitId);
            
            if (visit == null)
            {
                throw new ArgumentException($"Visit with ID {gymVisitId} not found");
            }

            if (visit.CheckOutTime != null)
            {
                throw new InvalidOperationException("This visit is already checked out");
            }

            // Set checkout time to now
            visit.CheckOutTime = DateTime.UtcNow;

            await _visitRepository.UpdateAsync(visit);
        }

        // Helper method to convert GymVisit entity to DTO
        private static CurrentVisitorDTO MapToDTO(GymVisit visit)
        {
            var duration = DateTime.UtcNow - visit.CheckInTime;

            return new CurrentVisitorDTO
            {
                GymVisitId = visit.Id,
                UserId = visit.UserId,
                Username = visit.User?.Username ?? "",
                FirstName = visit.User?.FirstName ?? "",
                LastName = visit.User?.LastName ?? "",
                CheckInTime = visit.CheckInTime,
                Duration = FormatDuration(duration)
            };
        }

        // Helper to format duration nicely
        private static string FormatDuration(TimeSpan duration)
        {
            if (duration.TotalHours >= 1)
            {
                return $"{(int)duration.TotalHours}h {duration.Minutes}m";
            }
            return $"{duration.Minutes}m";
        }
    }
}
