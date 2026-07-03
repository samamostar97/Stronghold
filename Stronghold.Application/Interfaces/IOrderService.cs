using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Orders;

namespace Stronghold.Application.Interfaces;

public interface IOrderService : IService<OrderResponse, OrderSearch>
{
    /// <summary>
    /// Server sam racuna iznos iz kataloga i kreira Stripe PaymentIntent.
    /// Narudzba se NE kreira ovdje - tek nakon potvrde placanja.
    /// </summary>
    Task<PaymentIntentResponse> CreatePaymentIntentAsync(CreatePaymentIntentRequest request);

    /// <summary>
    /// Server-side verifikacija: backend provjerava status PaymentIntenta kod Stripe-a
    /// pa tek onda kreira narudzbu. Idempotentno - ponovni poziv ne duplira efekte.
    /// </summary>
    Task<OrderResponse> ConfirmAsync(ConfirmOrderRequest request);

    /// <summary>Historija narudzbi trenutno prijavljenog clana.</summary>
    Task<PagedResult<OrderResponse>> GetMineAsync(BaseSearchObject search);

    Task<OrderResponse> DeliverAsync(int id);

    /// <summary>Otkazivanje pokrece stvarni Stripe refund na osnovu naplacenog iznosa.</summary>
    Task<OrderResponse> CancelAsync(int id, OrderCancelRequest request);
}
