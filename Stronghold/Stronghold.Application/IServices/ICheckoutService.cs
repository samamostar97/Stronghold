using Stronghold.Application.DTOs.UserDTOs;

namespace Stronghold.Application.IServices
{
    public interface ICheckoutService
    {
        Task<CheckoutResponseDTO> CreatePaymentIntent(int userId, CheckoutRequestDTO request);
        Task<UserOrdersDTO> ConfirmOrder(int userId, ConfirmOrderDTO request);
    }
}
