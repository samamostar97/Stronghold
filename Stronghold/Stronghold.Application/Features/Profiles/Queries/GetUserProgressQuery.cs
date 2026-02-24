using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Profiles.DTOs;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Profiles.Queries;

public class GetUserProgressQuery : IRequest<UserProgressResponse>
{
    public int UserId { get; set; }
}

public class GetUserProgressQueryHandler : IRequestHandler<GetUserProgressQuery, UserProgressResponse>
{
    private readonly IUserProfileService _userProfileService;
    private readonly ICurrentUserService _currentUserService;

    public GetUserProgressQueryHandler(
        IUserProfileService userProfileService,
        ICurrentUserService currentUserService)
    {
        _userProfileService = userProfileService;
        _currentUserService = currentUserService;
    }

    public async Task<UserProgressResponse> Handle(GetUserProgressQuery request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();
        return await _userProfileService.GetProgressAsync(request.UserId);
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

public class GetUserProgressQueryValidator : AbstractValidator<GetUserProgressQuery>
{
    public GetUserProgressQueryValidator()
    {
        RuleFor(x => x.UserId)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
}

