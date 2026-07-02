using Stronghold.Application.DTOs.Cities;

namespace Stronghold.Application.Interfaces;

public interface ICityService : ICrudService<CityResponse, CitySearch, CityUpsertRequest, CityUpsertRequest>
{
}
