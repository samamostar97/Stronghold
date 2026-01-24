using Mapster;
using Stronghold.Application.DTOs.AdminOrderDTO;
using Stronghold.Application.DTOs.AdminReviewDTO;
using Stronghold.Application.DTOs.AdminSupplementsDTO;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Mapping
{
    public static class MappingConfig
    {
        public static void Configure()
        {
            // Supplement -> SupplementDTO
            TypeAdapterConfig<Supplement, SupplementDTO>.NewConfig()
                .Map(dest => dest.SupplementCategoryName, src => src.SupplementCategory.Name)
                .Map(dest => dest.SupplierName, src => src.Supplier.Name);

            // Order -> OrdersDTO
            TypeAdapterConfig<Order, OrdersDTO>.NewConfig()
                .Map(dest => dest.UserFullName, src => src.User.FirstName + " " + src.User.LastName)
                .Map(dest => dest.UserEmail, src => src.User.Email);

            // OrderItem -> OrderItemDTO
            TypeAdapterConfig<OrderItem, OrderItemDTO>.NewConfig()
                .Map(dest => dest.SupplementName, src => src.Supplement.Name);
            // OrderItem -> OrderItemDTO
            TypeAdapterConfig<Review, ReviewDTO>.NewConfig()
                .Map(dest => dest.UserName, src => src.User.FirstName + " " + src.User.LastName)
                .Map(dest => dest.SupplementName, src => src.Supplement.Name);
        }
    }
}
