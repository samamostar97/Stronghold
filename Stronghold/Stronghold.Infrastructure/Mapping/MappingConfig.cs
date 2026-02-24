using Mapster;
using Stronghold.Application.DTOs.Response;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Mapping
{
    public static class MappingConfig
    {
        public static void Configure()
        {
            // Order -> OrderResponse
            TypeAdapterConfig<Order, OrderResponse>.NewConfig()
                .Map(dest => dest.UserFullName, src => src.User != null ? src.User.FirstName + " " + src.User.LastName : string.Empty)
                .Map(dest => dest.UserEmail, src => src.User != null ? src.User.Email : string.Empty);

            // OrderItem -> OrderItemResponse
            TypeAdapterConfig<OrderItem, OrderItemResponse>.NewConfig()
                .Map(dest => dest.SupplementName, src => src.Supplement != null ? src.Supplement.Name : string.Empty);
        }
    }
}
