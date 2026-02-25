using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Appointments.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Appointments.Queries;

public class GetAdminAppointmentsQuery : IRequest<PagedResult<AdminAppointmentResponse>>, IAuthorizeAdminRequest
{
    public AppointmentFilter Filter { get; set; } = new();
}

public class GetAdminAppointmentsQueryHandler : IRequestHandler<GetAdminAppointmentsQuery, PagedResult<AdminAppointmentResponse>>
{
    private readonly IAppointmentRepository _appointmentRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetAdminAppointmentsQueryHandler(
        IAppointmentRepository appointmentRepository,
        ICurrentUserService currentUserService)
    {
        _appointmentRepository = appointmentRepository;
        _currentUserService = currentUserService;
    }

public async Task<PagedResult<AdminAppointmentResponse>> Handle(GetAdminAppointmentsQuery request, CancellationToken cancellationToken)
    {
        var filter = request.Filter ?? new AppointmentFilter();
        var page = await _appointmentRepository.GetAdminPagedAsync(filter, cancellationToken);

        return new PagedResult<AdminAppointmentResponse>
        {
            Items = page.Items.Select(x => new AdminAppointmentResponse
            {
                Id = x.Id,
                UserId = x.UserId,
                TrainerId = x.TrainerId,
                NutritionistId = x.NutritionistId,
                UserName = $"{x.User.FirstName} {x.User.LastName}",
                TrainerName = x.Trainer is null ? null : $"{x.Trainer.FirstName} {x.Trainer.LastName}",
                NutritionistName = x.Nutritionist is null ? null : $"{x.Nutritionist.FirstName} {x.Nutritionist.LastName}",
                AppointmentDate = x.AppointmentDate,
                Type = x.TrainerId.HasValue ? "Trener" : "Nutricionista"
            }).ToList(),
            TotalCount = page.TotalCount,
            PageNumber = page.PageNumber
        };
    }
    }

public class GetAdminAppointmentsQueryValidator : AbstractValidator<GetAdminAppointmentsQuery>
{
    public GetAdminAppointmentsQueryValidator()
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
        return normalized is "date" or "datedesc" or "user" or "userdesc";
    }
    }