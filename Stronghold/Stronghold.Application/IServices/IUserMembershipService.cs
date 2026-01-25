using Stronghold.Application.DTOs.UserDTOs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IServices
{
    public interface IUserMembershipService
    {
        Task<IEnumerable<MembershipPaymentDTO>> GetMembershipPaymentHistory(int userId);
    }
}
