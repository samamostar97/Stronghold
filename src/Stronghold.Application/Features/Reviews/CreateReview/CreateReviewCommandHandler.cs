using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Domain.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Reviews.CreateReview;

public class CreateReviewCommandHandler : IRequestHandler<CreateReviewCommand, ReviewResponse>
{
    private readonly IReviewRepository _reviewRepository;
    private readonly IOrderItemRepository _orderItemRepository;
    private readonly IAppointmentRepository _appointmentRepository;
    private readonly IUserRepository _userRepository;
    private readonly ICurrentUserService _currentUserService;

    public CreateReviewCommandHandler(
        IReviewRepository reviewRepository,
        IOrderItemRepository orderItemRepository,
        IAppointmentRepository appointmentRepository,
        IUserRepository userRepository,
        ICurrentUserService currentUserService)
    {
        _reviewRepository = reviewRepository;
        _orderItemRepository = orderItemRepository;
        _appointmentRepository = appointmentRepository;
        _userRepository = userRepository;
        _currentUserService = currentUserService;
    }

    public async Task<ReviewResponse> Handle(CreateReviewCommand request, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId;
        var reviewType = Enum.Parse<ReviewType>(request.ReviewType);

        if (reviewType == ReviewType.Product)
        {
            var hasPurchased = await _orderItemRepository.Query()
                .AnyAsync(oi => oi.Order!.UserId == userId
                    && oi.ProductId == request.ProductId!.Value
                    && oi.Order.Status == OrderStatus.Confirmed,
                    cancellationToken);

            if (!hasPurchased)
                throw new InvalidOperationException("Možete recenzirati samo proizvode koje ste kupili.");

            if (await _reviewRepository.UserHasReviewedProductAsync(userId, request.ProductId!.Value))
                throw new ConflictException("Već ste ostavili recenziju za ovaj proizvod.");
        }
        else
        {
            var appointment = await _appointmentRepository.GetByIdAsync(request.AppointmentId!.Value)
                ?? throw new NotFoundException("Termin nije pronađen.");

            if (appointment.UserId != userId)
                throw new InvalidOperationException("Možete recenzirati samo vlastite termine.");

            if (appointment.Status != AppointmentStatus.Completed)
                throw new InvalidOperationException("Možete recenzirati samo završene termine.");

            if (await _reviewRepository.UserHasReviewedAppointmentAsync(userId, request.AppointmentId!.Value))
                throw new ConflictException("Već ste ostavili recenziju za ovaj termin.");
        }

        var user = await _userRepository.GetByIdAsync(userId)
            ?? throw new NotFoundException("Korisnik", userId);

        var review = new Review
        {
            UserId = userId,
            UserFullName = $"{user.FirstName} {user.LastName}",
            Rating = request.Rating,
            Comment = request.Comment,
            ReviewType = reviewType,
            ProductId = reviewType == ReviewType.Product ? request.ProductId : null,
            AppointmentId = reviewType == ReviewType.Appointment ? request.AppointmentId : null
        };

        await _reviewRepository.AddAsync(review);
        await _reviewRepository.SaveChangesAsync();

        var created = await _reviewRepository.GetByIdWithDetailsAsync(review.Id);
        return ReviewMappings.ToResponse(created!);
    }
}
