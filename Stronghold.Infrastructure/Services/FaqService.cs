using Stronghold.Application.DTOs.Faqs;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class FaqService : BaseCrudService<Faq, FaqResponse, FaqSearch, FaqUpsertRequest, FaqUpsertRequest>,
    IFaqService
{
    public FaqService(StrongholdDbContext db) : base(db)
    {
    }

    protected override IQueryable<Faq> ApplyFilter(IQueryable<Faq> query, FaqSearch search)
    {
        if (!string.IsNullOrWhiteSpace(search.Text))
        {
            var text = search.Text.Trim();
            query = query.Where(f => f.Question.Contains(text) || f.Answer.Contains(text));
        }
        return query.OrderBy(f => f.Id);
    }
}
