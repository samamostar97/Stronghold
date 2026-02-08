using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IServices
{
    public interface IFaqService : IService<FAQ, FaqResponse, CreateFaqRequest, UpdateFaqRequest, FaqQueryFilter, int>
    {
    }
}
