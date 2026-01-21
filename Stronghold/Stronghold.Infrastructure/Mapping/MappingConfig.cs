using Mapster;
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

            // new mapping
        }
    }
}
