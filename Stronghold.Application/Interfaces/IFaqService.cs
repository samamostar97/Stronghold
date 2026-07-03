using Stronghold.Application.DTOs.Faqs;

namespace Stronghold.Application.Interfaces;

public interface IFaqService : ICrudService<FaqResponse, FaqSearch, FaqUpsertRequest, FaqUpsertRequest>
{
}
