using Stronghold.Application.DTOs.Payments;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class PaymentService : BaseService<Payment, PaymentResponse, PaymentSearch>, IPaymentService
{
    public PaymentService(StrongholdDbContext db) : base(db)
    {
    }

    protected override IQueryable<Payment> ApplyFilter(IQueryable<Payment> query, PaymentSearch search)
    {
        if (search.UserId.HasValue)
        {
            query = query.Where(p => p.Membership.UserId == search.UserId);
        }
        if (search.From.HasValue)
        {
            query = query.Where(p => p.PaidAt >= search.From);
        }
        if (search.To.HasValue)
        {
            query = query.Where(p => p.PaidAt <= search.To);
        }
        return query.OrderByDescending(p => p.PaidAt);
    }
}
