using MediatR;
using Stronghold.Application.Common.Authorization;
using Stronghold.Application.Exceptions;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Common.Behaviors;

public class AuthorizationBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    private readonly ICurrentUserService _currentUserService;

    public AuthorizationBehavior(ICurrentUserService currentUserService)
    {
        _currentUserService = currentUserService;
    }

    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        switch (request)
        {
            case IAuthorizeAdminOrGymMemberRequest:
                EnsureAuthenticated();
                EnsureAnyRole(AuthorizationRoles.Admin, AuthorizationRoles.GymMember);
                break;
            case IAuthorizeAdminRequest:
                EnsureAuthenticated();
                EnsureAnyRole(AuthorizationRoles.Admin);
                break;
            case IAuthorizeGymMemberRequest:
                EnsureAuthenticated();
                EnsureAnyRole(AuthorizationRoles.GymMember);
                break;
            case IAuthorizeAuthenticatedRequest:
                EnsureAuthenticated();
                break;
        }

        return await next();
    }

    private void EnsureAuthenticated()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }
    }

    private void EnsureAnyRole(params string[] roles)
    {
        if (!roles.Any(_currentUserService.IsInRole))
        {
            throw new ForbiddenException("Nemate dozvolu za ovu akciju.");
        }
    }
}
