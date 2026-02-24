using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Visits.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Visits.Queries;

public class GetCurrentVisitorsQuery : IRequest<PagedResult<VisitResponse>>
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
        EnsureAdminAccess();

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

    private void EnsureAdminAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("Admin"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }
    }
}

public class GetCurrentVisitorsQueryValidator : AbstractValidator<GetCurrentVisitorsQuery>
{
    public GetCurrentVisitorsQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull();

        RuleFor(x => x.Filter.PageNumber)
            .GreaterThanOrEqualTo(1);

        RuleFor(x => x.Filter.PageSize)
            .GreaterThanOrEqualTo(1)
            .LessThanOrEqualTo(100);

        RuleFor(x => x.Filter.Search)
            .MaximumLength(200)
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.Search));

        RuleFor(x => x.Filter.OrderBy)
            .MaximumLength(30)
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
