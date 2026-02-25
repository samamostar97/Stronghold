using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Visits.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Visits.Queries;

public class GetCurrentVisitorsQuery : IRequest<PagedResult<VisitResponse>>, IAuthorizeAdminRequest
{
    public VisitFilter Filter { get; set; } = new();
}

public class GetCurrentVisitorsQueryHandler : IRequestHandler<GetCurrentVisitorsQuery, PagedResult<VisitResponse>>
{
    private readonly IVisitRepository _visitRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetCurrentVisitorsQueryHandler(IVisitRepository visitRepository, ICurrentUserService currentUserService)
    {
        _visitRepository = visitRepository;
        _currentUserService = currentUserService;
    }

public async Task<PagedResult<VisitResponse>> Handle(GetCurrentVisitorsQuery request, CancellationToken cancellationToken)
    {
        var filter = request.Filter ?? new VisitFilter();
        var page = await _visitRepository.GetCurrentPagedAsync(filter, cancellationToken);

        return new PagedResult<VisitResponse>
        {
            Items = page.Items.Select(x => new VisitResponse
            {
                Id = x.Id,
                UserId = x.UserId,
                Username = x.User?.Username ?? string.Empty,
                FirstName = x.User?.FirstName ?? string.Empty,
                LastName = x.User?.LastName ?? string.Empty,
                CheckInTime = x.CheckInTime,
                CheckOutTime = x.CheckOutTime
            }).ToList(),
            TotalCount = page.TotalCount,
            PageNumber = page.PageNumber
        };
    }
    }

public class GetCurrentVisitorsQueryValidator : AbstractValidator<GetCurrentVisitorsQuery>
{
    public GetCurrentVisitorsQueryValidator()
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
        var normalized = orderBy?.Trim().ToLowerInvariant();
        return normalized is "firstname" or "lastname" or "username" or "checkin" or "checkindesc";
    }
    }