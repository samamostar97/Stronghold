using Stronghold.Application.DTOs.UserDTOs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IServices
{
    public interface IUserReviewService
    {
        Task<IEnumerable<UserReviewsDTO>> GetReviewList(int userId);
        Task DeleteReviewAsync(int userId, int reviewId);
    }
}
