using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Users.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Users.Queries;

public class GetUsersQuery : IRequest<IReadOnlyList<UserResponse>>
{
    public UserFilter Filter { get; set; } = new();
}

public class GetUsersQueryHandler : IRequestHandler<GetUsersQuery, IReadOnlyList<UserResponse>>
{
    private readonly IUserRepository _userRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetUsersQueryHandler(IUserRepository userRepository, ICurrentUserService currentUserService)
    {
        _userRepository = userRepository;
        _currentUserService = currentUserService;
    }

    public async Task<IReadOnlyList<UserResponse>> Handle(GetUsersQuery request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var filter = request.Filter ?? new UserFilter();
        filter.PageNumber = 1;
        filter.PageSize = int.MaxValue;

        var page = await _userRepository.GetPagedAsync(filter, cancellationToken);
        return page.Items.Select(MapToResponse).ToList();
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

public class GetUsersQueryValidator : AbstractValidator<GetUsersQuery>
{
    public GetUsersQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull().WithMessage("{PropertyName} je obavezno.");

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
        return normalized is "firstname" or "lastname" or "date" or "datedesc";
    }
}

