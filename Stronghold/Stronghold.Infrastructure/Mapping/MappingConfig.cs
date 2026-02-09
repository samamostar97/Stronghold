using Mapster;
using Stronghold.Application.DTOs.Response;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Mapping
{
    public static class MappingConfig
    {
        public static void Configure()
        {
            // Supplement -> SupplementResponse
            TypeAdapterConfig<Supplement, SupplementResponse>.NewConfig()
                .Map(dest => dest.ImageUrl, src => src.SupplementImageUrl)
                .Map(dest => dest.SupplementCategoryName, src => src.SupplementCategory != null ? src.SupplementCategory.Name : string.Empty)
                .Map(dest => dest.SupplierName, src => src.Supplier != null ? src.Supplier.Name : string.Empty);

            // Order -> OrderResponse
            TypeAdapterConfig<Order, OrderResponse>.NewConfig()
                .Map(dest => dest.UserFullName, src => src.User != null ? src.User.FirstName + " " + src.User.LastName : string.Empty)
                .Map(dest => dest.UserEmail, src => src.User != null ? src.User.Email : string.Empty);

            // OrderItem -> OrderItemResponse
            TypeAdapterConfig<OrderItem, OrderItemResponse>.NewConfig()
                .Map(dest => dest.SupplementName, src => src.Supplement != null ? src.Supplement.Name : string.Empty);

            // Review -> ReviewResponse
            TypeAdapterConfig<Review, ReviewResponse>.NewConfig()
                .Map(dest => dest.UserName, src => src.User != null ? src.User.FirstName + " " + src.User.LastName : string.Empty)
                .Map(dest => dest.SupplementName, src => src.Supplement != null ? src.Supplement.Name : string.Empty);
        }
    }
}
