using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;

namespace Stronghold.Application.GymVisits;

public class GymVisitService : IGymVisitService
{
    private readonly IRepository<GymVisit, int> _gymVisits;

    public GymVisitService(IRepository<GymVisit, int> gymVisits)
    {
        _gymVisits = gymVisits;
    }
    public async Task CheckInAsync(int userId)
    {
        var alreadyInside = await _gymVisits.AsQueryable()
            .AnyAsync(v => v.UserId == userId && v.CheckOutTime == null);

        if (alreadyInside)
            throw new InvalidOperationException("User is already checked in.");

        await _gymVisits.AddAsync(new GymVisit
        {
            UserId = userId,
            CheckInTime = DateTime.UtcNow
        });
    }
    public async Task<List<CurrentGymUserDto>> GetCurrentlyInGymAsync()
    {
        return await _gymVisits.AsQueryable()
            .AsNoTracking()
            .Where(v => v.CheckOutTime == null)
            .OrderBy(v => v.CheckInTime)
            .Select(v => new CurrentGymUserDto
            {
                UserId = v.UserId,
                Username = v.User.Username,
                FirstName = v.User.FirstName,
                LastName = v.User.LastName,
                CheckInTime = v.CheckInTime
            })
            .ToListAsync();
    }
}
