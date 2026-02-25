using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Users.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Users.Queries;

public class GetPagedUsersQuery : IRequest<PagedResult<UserResponse>>, IAuthorizeAdminRequest
{
    public UserFilter Filter { get; set; } = new();
}

public class GetPagedUsersQueryHandler : IRequestHandler<GetPagedUsersQuery, PagedResult<UserResponse>>
{
    private readonly IUserRepository _userRepository;

    public GetPagedUsersQueryHandler(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }

public async Task<PagedResult<UserResponse>> Handle(GetPagedUsersQuery request, CancellationToken cancellationToken)
    {
        var filter = request.Filter ?? new UserFilter();
        var page = await _userRepository.GetPagedAsync(filter, cancellationToken);

        return new PagedResult<UserResponse>
        {
            Items = page.Items.Select(MapToResponse).ToList(),
            TotalCount = page.TotalCount,
            PageNumber = page.PageNumber
        };
    }

private static UserResponse MapToResponse(User user)
    {
        return new UserResponse
        {
            Id = user.Id,
            FirstName = user.FirstName,
            LastName = user.LastName,
            Username = user.Username,
            Email = user.Email,
            PhoneNumber = user.PhoneNumber,
            Gender = user.Gender,
            ProfileImageUrl = user.ProfileImageUrl
        };
    }
    }

public class GetPagedUsersQueryValidator : AbstractValidator<GetPagedUsersQuery>
{
    public GetPagedUsersQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.Filter.PageNumber)
            .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.");

        RuleFor(x => x.Filter.PageSize)
            .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.")
            .LessThanOrEqualTo(100).WithMessage("{PropertyName} mora biti manje ili jednako dozvoljenoj vrijednosti.");

        RuleFor(x => x.Filter.Name)
            .MaximumLength(200).WithMessage("{PropertyName} ne smije imati vise od 200 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.Name));

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
        return normalized is "firstname" or "lastname" or "date" or "datedesc"
            or "membershipstatus" or "membershipstatusdesc" or "expirydate" or "expirydatedesc";
    }
    }