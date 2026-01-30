using Stronghold.Application.DTOs.UserDTOs;

namespace Stronghold.Application.IServices
{
    public interface IUserFaqService
    {
        Task<IEnumerable<UserFaqDTO>> GetAllFaqs();
    }
}
