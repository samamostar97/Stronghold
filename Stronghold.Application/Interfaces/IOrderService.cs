using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Orders;

namespace Stronghold.Application.Interfaces;

public interface IOrderService : IService<OrderResponse, OrderSearch>
{
    // Server sam racuna iznos iz kataloga i kreira Stripe PaymentIntent.
    // Narudzba se NE kreira ovdje - tek nakon potvrde placanja.
    Task<PaymentIntentResponse> CreatePaymentIntentAsync(CreatePaymentIntentRequest request);

    // Server-side verifikacija: backend provjerava status PaymentIntenta kod Stripe-a
    // pa tek onda kreira narudzbu. Idempotentno - ponovni poziv ne duplira efekte.
    Task<OrderResponse> ConfirmAsync(ConfirmOrderRequest request);

    // Historija narudzbi trenutno prijavljenog clana.
    Task<PagedResult<OrderResponse>> GetMineAsync(BaseSearchObject search);

    Task<OrderResponse> DeliverAsync(int id);

    // Otkazivanje pokrece stvarni Stripe refund na osnovu naplacenog iznosa.
    Task<OrderResponse> CancelAsync(int id, OrderCancelRequest request);
}
