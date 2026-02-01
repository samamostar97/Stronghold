using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.AdminOrderDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;

namespace Stronghold.Infrastructure.Services
{
    public class AdminOrderService : IAdminOrderService
    {
        private readonly IRepository<Order, int> _repository;
        private readonly IMapper _mapper;
        private readonly IEmailService _emailService;

        public AdminOrderService(IRepository<Order, int> repository, IMapper mapper, IEmailService emailService)
        {
            _repository = repository;
            _mapper = mapper;
            _emailService = emailService;
        }

        public async Task<IEnumerable<OrdersDTO>> GetAllAsync(OrderQueryFilter? filter)
        {
            var query = _repository.AsQueryable();
            query = ApplyFilter(query, filter);
            var entities = await query.ToListAsync();
            return _mapper.Map<IEnumerable<OrdersDTO>>(entities);
        }

        public async Task<PagedResult<OrdersDTO>> GetPagedAsync(PaginationRequest pagination, OrderQueryFilter? filter)
        {
            var query = _repository.AsQueryable();
            query = ApplyFilter(query, filter);

            var pagedEntities = await _repository.GetPagedAsync(query, pagination);

            return new PagedResult<OrdersDTO>
            {
                Items = _mapper.Map<List<OrdersDTO>>(pagedEntities.Items),
                TotalCount = pagedEntities.TotalCount,
                PageNumber = pagedEntities.PageNumber,
            };
        }

        public async Task<OrdersDTO> GetByIdAsync(int id)
        {
            var query = _repository.AsQueryable()
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Supplement);

            var entity = await query.FirstOrDefaultAsync(o => o.Id == id);
            if (entity == null)
                throw new KeyNotFoundException($"Narudžba sa id '{id}' nije pronađena.");

            return _mapper.Map<OrdersDTO>(entity);
        }

        public async Task<OrdersDTO> MarkAsDeliveredAsync(int orderId)
        {
            var query = _repository.AsQueryable()
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Supplement);

            var order = await query.FirstOrDefaultAsync(o => o.Id == orderId);
            if (order == null)
                throw new KeyNotFoundException($"Narudžba sa id '{orderId}' nije pronađena.");

            if (order.Status == OrderStatus.Delivered)
                throw new InvalidOperationException("Narudžba je već označena kao isporučena.");

            order.Status = OrderStatus.Delivered;
            await _repository.UpdateAsync(order);

            // Send delivery notification email
            await SendDeliveryEmailAsync(order);

            return _mapper.Map<OrdersDTO>(order);
        }

        private async Task SendDeliveryEmailAsync(Order order)
        {
            var itemsList = string.Join("", order.OrderItems.Select(oi =>
                $"<li>{oi.Supplement.Name} x{oi.Quantity} — {oi.UnitPrice:F2} KM</li>"));

            var emailBody = $@"
                <html>
                <body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
                    <h2 style='color: #2ECC71;'>🚚 Vaša narudžba #{order.Id} je na putu!</h2>
                    <p>Poštovani/a {order.User.FirstName},</p>
                    
                    <div style='background-color: #d4edda; padding: 15px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #2ECC71;'>
                        <p style='margin: 0; font-size: 16px;'>
                            <strong>✅ Vaša dostava je krenula!</strong><br/>
                            Sve je prošlo u redu i Vaš paket je na putu do Vas.
                        </p>
                    </div>
                    
                    <h3>Sadržaj pošiljke:</h3>
                    <ul>{itemsList}</ul>
                    <p><strong>Ukupan iznos: {order.TotalAmount:F2} KM</strong></p>
                    
                    <hr style='border: none; border-top: 1px solid #ddd; margin: 20px 0;'/>
                    <p style='color: #666; font-size: 14px;'>
                        Očekujte dostavu u narednim danima. Hvala Vam što kupujete kod nas!
                    </p>
                    <p>Srdačan pozdrav,<br/><strong>Stronghold Tim</strong></p>
                </body>
                </html>";

            await _emailService.SendEmailAsync(
                order.User.Email,
                $"Narudžba #{order.Id} — Vaša dostava je na putu! 🚚",
                emailBody);
        }

        private IQueryable<Order> ApplyFilter(IQueryable<Order> query, OrderQueryFilter? filter)
        {
            query = query
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Supplement);

            if (filter == null)
                return query.OrderByDescending(o => o.PurchaseDate);

            if (!string.IsNullOrEmpty(filter.Search))
            {
                var search = filter.Search.ToLower();
                query = query.Where(o =>
                    o.User.FirstName.ToLower().Contains(search) ||
                    o.User.LastName.ToLower().Contains(search) ||
                    o.User.Email.ToLower().Contains(search) ||
                    o.Id.ToString().Contains(search));
            }

            if (filter.Status.HasValue)
            {
                query = query.Where(o => o.Status == filter.Status.Value);
            }

            if (filter.DateFrom.HasValue)
            {
                query = query.Where(o => o.PurchaseDate >= filter.DateFrom.Value);
            }

            if (filter.DateTo.HasValue)
            {
                query = query.Where(o => o.PurchaseDate <= filter.DateTo.Value);
            }

            if (!string.IsNullOrEmpty(filter.OrderBy))
            {
                query = filter.OrderBy.ToLower() switch
                {
                    "date" => filter.Descending
                        ? query.OrderByDescending(o => o.PurchaseDate)
                        : query.OrderBy(o => o.PurchaseDate),
                    "amount" => filter.Descending
                        ? query.OrderByDescending(o => o.TotalAmount)
                        : query.OrderBy(o => o.TotalAmount),
                    "status" => filter.Descending
                        ? query.OrderByDescending(o => o.Status)
                        : query.OrderBy(o => o.Status),
                    "user" => filter.Descending
                        ? query.OrderByDescending(o => o.User.LastName)
                        : query.OrderBy(o => o.User.LastName),
                    _ => filter.Descending
                        ? query.OrderByDescending(o => o.PurchaseDate)
                        : query.OrderBy(o => o.PurchaseDate)
                };
            }
            else
            {
                query = filter.Descending
                    ? query.OrderByDescending(o => o.PurchaseDate)
                    : query.OrderBy(o => o.PurchaseDate);
            }

            return query;
        }
    }
}
