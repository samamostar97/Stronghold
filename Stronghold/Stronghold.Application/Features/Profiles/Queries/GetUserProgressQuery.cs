using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Profiles.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Profiles.Queries;

public class GetUserProgressQuery : IRequest<UserProgressResponse>, IAuthorizeAdminRequest
{
    public int UserId { get; set; }
}

public class GetUserProgressQueryHandler : IRequestHandler<GetUserProgressQuery, UserProgressResponse>
{
    private readonly IUserProfileService _userProfileService;

    public GetUserProgressQueryHandler(
        IUserProfileService userProfileService)
    {
        _userProfileService = userProfileService;
    }

public async Task<UserProgressResponse> Handle(GetUserProgressQuery request, CancellationToken cancellationToken)
    {
        return await _userProfileService.GetProgressAsync(request.UserId);
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