using Stronghold.Application.DTOs.Supplements;

namespace Stronghold.Application.Interfaces;

public interface ISupplementService : ICrudService<SupplementResponse, SupplementSearch,
    SupplementUpsertRequest, SupplementUpsertRequest>
{
    Task<(byte[] Data, string ContentType)> GetImageAsync(int id);
}
