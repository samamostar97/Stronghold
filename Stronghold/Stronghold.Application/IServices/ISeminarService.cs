using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IServices
{
    public interface ISeminarService : IService<Seminar, SeminarResponse, CreateSeminarRequest, UpdateSeminarRequest, SeminarQueryFilter, int>
    {
        Task<IEnumerable<UserSeminarResponse>> GetUpcomingSeminarsAsync(int userId);
        Task AttendSeminarAsync(int userId, int seminarId);
        Task CancelAttendanceAsync(int userId, int seminarId);
        Task<IEnumerable<SeminarAttendeeResponse>> GetSeminarAttendeesAsync(int seminarId);
    }
}
