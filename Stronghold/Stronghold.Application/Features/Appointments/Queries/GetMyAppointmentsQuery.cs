using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Appointments.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Appointments.Queries;

public class GetMyAppointmentsQuery : IRequest<PagedResult<AppointmentResponse>>, IAuthorizeAuthenticatedRequest
{
    public AppointmentFilter Filter { get; set; } = new();
}

public class GetMyAppointmentsQueryHandler : IRequestHandler<GetMyAppointmentsQuery, PagedResult<AppointmentResponse>>
{
    private readonly IAppointmentRepository _appointmentRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetMyAppointmentsQueryHandler(
        IAppointmentRepository appointmentRepository,
        ICurrentUserService currentUserService)
    {
        _appointmentRepository = appointmentRepository;
        _currentUserService = currentUserService;
    }

public async Task<PagedResult<AppointmentResponse>> Handle(GetMyAppointmentsQuery request, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId!.Value;
        var filter = request.Filter ?? new AppointmentFilter();

        var page = await _appointmentRepository.GetUserUpcomingPagedAsync(userId, filter, cancellationToken);

        return new PagedResult<AppointmentResponse>
        {
            Items = page.Items.Select(x => new AppointmentResponse
            {
                Id = x.Id,
                TrainerName = x.Trainer is null ? null : $"{x.Trainer.FirstName} {x.Trainer.LastName}",
                NutritionistName = x.Nutritionist is null ? null : $"{x.Nutritionist.FirstName} {x.Nutritionist.LastName}",
                AppointmentDate = x.AppointmentDate
            }).ToList(),
            TotalCount = page.TotalCount,
            PageNumber = page.PageNumber
        };
    }
    }

public class GetMyAppointmentsQueryValidator : AbstractValidator<GetMyAppointmentsQuery>
{
    public GetMyAppointmentsQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.Filter.PageNumber)
            .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.");

        RuleFor(x => x.Filter.PageSize)
            .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.")
            .LessThanOrEqualTo(100).WithMessage("{PropertyName} mora biti manje ili jednako dozvoljenoj vrijednosti.");

        RuleFor(x => x.Filter.Search)
            .MaximumLength(200).WithMessage("{PropertyName} ne smije imati vise od 200 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.Search));

        RuleFor(x => x.Filter.OrderBy)
            .MaximumLength(30).WithMessage("{PropertyName} ne smije imati vise od 30 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.OrderBy));

        RuleFor(x => x.Filter.OrderBy)
            .Must(BeValidOrderBy)
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.OrderBy))
            .WithMessage("Neispravna vrijednost za sortiranje.");
    }

private static bool BeValidOrderBy(string? orderBy)
    {
        var normalized = orderBy?.Trim().ToLower();
        return normalized is "date" or "datedesc";
    }
    }