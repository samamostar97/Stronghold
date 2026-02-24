using FluentValidation;
using MediatR;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.AdminActivities.Queries;

public class GetRecentAdminActivitiesQuery : IRequest<IReadOnlyList<AdminActivityResponse>>
{
    public int Count { get; set; } = 20;
}

public class GetRecentAdminActivitiesQueryHandler : IRequestHandler<GetRecentAdminActivitiesQuery, IReadOnlyList<AdminActivityResponse>>
{
    private readonly IAdminActivityService _adminActivityService;
    private readonly ICurrentUserService _currentUserService;

    public GetRecentAdminActivitiesQueryHandler(
        IAdminActivityService adminActivityService,
        ICurrentUserService currentUserService)
    {
        _adminActivityService = adminActivityService;
        _currentUserService = currentUserService;
    }

    public async Task<IReadOnlyList<AdminActivityResponse>> Handle(
        GetRecentAdminActivitiesQuery request,
        CancellationToken cancellationToken)
    {
        EnsureAdminAccess();
        var activities = await _adminActivityService.GetRecentAsync(request.Count);
        return activities;
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

public class GetRecentAdminActivitiesQueryValidator : AbstractValidator<GetRecentAdminActivitiesQuery>
{
    public GetRecentAdminActivitiesQueryValidator()
    {
        RuleFor(x => x.Count)
            .InclusiveBetween(1, 100);
    }
}
