using System.Reflection;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Behaviors;

public class AuthorizationBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : notnull
{
    private readonly ICurrentUserService _currentUserService;

    public AuthorizationBehavior(ICurrentUserService currentUserService)
    {
        _currentUserService = currentUserService;
    }

    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
    {
        var authorizeAttributes = request.GetType().GetCustomAttributes<AuthorizeRoleAttribute>().ToList();

        if (!authorizeAttributes.Any())
            return await next();

        if (!_currentUserService.IsAuthenticated)
            throw new UnauthorizedAccessException("Morate biti prijavljeni.");

        var userRole = _currentUserService.Role;
        var authorized = authorizeAttributes.Any(a => a.Role == userRole);

        if (!authorized)
            throw new ForbiddenException();

        return await next();
    }
}
