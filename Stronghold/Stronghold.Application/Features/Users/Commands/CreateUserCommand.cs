using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.Users.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;

namespace Stronghold.Application.Features.Users.Commands;

public class CreateUserCommand : IRequest<UserResponse>
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public Gender Gender { get; set; }
    public string Password { get; set; } = string.Empty;
}

public class CreateUserCommandHandler : IRequestHandler<CreateUserCommand, UserResponse>
{
    private readonly IUserRepository _userRepository;
    private readonly ICurrentUserService _currentUserService;

    public CreateUserCommandHandler(IUserRepository userRepository, ICurrentUserService currentUserService)
    {
        _userRepository = userRepository;
        _currentUserService = currentUserService;
    }

    public async Task<UserResponse> Handle(CreateUserCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var username = request.Username.Trim();
        var email = request.Email.Trim();
        var phoneNumber = request.PhoneNumber.Trim();

        if (await _userRepository.ExistsByUsernameAsync(username, cancellationToken: cancellationToken))
        {
            throw new ConflictException("Korisnicko ime je vec zauzeto.");
        }

        if (await _userRepository.ExistsByEmailAsync(email, cancellationToken: cancellationToken))
        {
            throw new ConflictException("Email je vec zauzet.");
        }

        if (await _userRepository.ExistsByPhoneAsync(phoneNumber, cancellationToken: cancellationToken))
        {
            throw new ConflictException("Korisnik sa ovim brojem telefona vec postoji.");
        }

        var entity = new User
        {
            FirstName = request.FirstName.Trim(),
            LastName = request.LastName.Trim(),
            Username = username,
            Email = email,
            PhoneNumber = phoneNumber,
            Gender = request.Gender,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            Role = Role.GymMember
        };

        await _userRepository.AddAsync(entity, cancellationToken);
        return MapToResponse(entity);
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

public class CreateUserCommandValidator : AbstractValidator<CreateUserCommand>
{
    public CreateUserCommandValidator()
    {
        RuleFor(x => x.FirstName)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.");

        RuleFor(x => x.LastName)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.");

        RuleFor(x => x.Username)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(3).WithMessage("{PropertyName} mora imati najmanje 3 karaktera.")
            .MaximumLength(50).WithMessage("{PropertyName} ne smije imati vise od 50 karaktera.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .EmailAddress().WithMessage("Unesite ispravnu email adresu.")
            .MinimumLength(5).WithMessage("{PropertyName} mora imati najmanje 5 karaktera.")
            .MaximumLength(255).WithMessage("{PropertyName} ne smije imati vise od 255 karaktera.");

        RuleFor(x => x.PhoneNumber)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(9).WithMessage("{PropertyName} mora imati najmanje 9 karaktera.")
            .MaximumLength(20).WithMessage("{PropertyName} ne smije imati vise od 20 karaktera.")
            .Matches(@"^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$")
            .WithMessage("Broj telefona mora biti u formatu 061 123 456 ili +387 61 123 456.");

        RuleFor(x => x.Gender)
            .IsInEnum().WithMessage("{PropertyName} ima neispravnu vrijednost.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(6).WithMessage("{PropertyName} mora imati najmanje 6 karaktera.")
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.");
    }
}


