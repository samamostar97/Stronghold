using Stronghold.Application.DTOs.AdminSeminarDTO;
using Stronghold.Application.DTOs.UserDTOs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IServices
{
    public interface IUserSeminarService
    {
        Task<IEnumerable<UserSeminarDTO>> GetSeminarListAsync(int userId);
        Task AttendSeminarAsync(int userId, int seminarId);
    }
}
