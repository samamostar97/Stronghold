using Stronghold.Application.DTOs.UserDTOs;


namespace Stronghold.Application.IServices
{
    public interface IUserOrderService
    {
        Task<IEnumerable<UserOrdersDTO>> GetOrderList(int userId);
    }
}
