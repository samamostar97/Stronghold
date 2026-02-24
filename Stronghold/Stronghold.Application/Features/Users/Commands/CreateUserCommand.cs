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
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(100);

        RuleFor(x => x.LastName)
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(100);

        RuleFor(x => x.Username)
            .NotEmpty()
            .MinimumLength(3)
            .MaximumLength(50);

        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress()
            .MinimumLength(5)
            .MaximumLength(255);

        RuleFor(x => x.PhoneNumber)
            .NotEmpty()
            .MinimumLength(9)
            .MaximumLength(20)
            .Matches(@"^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$")
            .WithMessage("Broj telefona mora biti u formatu 061 123 456 ili +387 61 123 456.");

        RuleFor(x => x.Gender)
            .IsInEnum();

        RuleFor(x => x.Password)
            .NotEmpty()
            .MinimumLength(6)
            .MaximumLength(100);
    }
}
