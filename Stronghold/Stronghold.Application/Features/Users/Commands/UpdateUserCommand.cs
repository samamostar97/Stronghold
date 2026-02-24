using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.Users.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Users.Commands;

public class UpdateUserCommand : IRequest<UserResponse>
{
    public int Id { get; set; }
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
    public string? Username { get; set; }
    public string? Email { get; set; }
    public string? PhoneNumber { get; set; }
    public string? Password { get; set; }
}

public class UpdateUserCommandHandler : IRequestHandler<UpdateUserCommand, UserResponse>
{
    private readonly IUserRepository _userRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateUserCommandHandler(IUserRepository userRepository, ICurrentUserService currentUserService)
    {
        _userRepository = userRepository;
        _currentUserService = currentUserService;
    }

    public async Task<UserResponse> Handle(UpdateUserCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var user = await _userRepository.GetByIdAsync(request.Id, cancellationToken);
        if (user is null)
        {
            throw new KeyNotFoundException("Korisnik nije pronadjen.");
        }

        if (!string.IsNullOrWhiteSpace(request.Username))
        {
            var normalizedUsername = request.Username.Trim();
            if (await _userRepository.ExistsByUsernameAsync(normalizedUsername, user.Id, cancellationToken))
            {
                throw new ConflictException("Korisnicko ime je vec zauzeto.");
            }

            user.Username = normalizedUsername;
        }

        if (!string.IsNullOrWhiteSpace(request.Email))
        {
            var normalizedEmail = request.Email.Trim();
            if (await _userRepository.ExistsByEmailAsync(normalizedEmail, user.Id, cancellationToken))
            {
                throw new ConflictException("Email je vec zauzet.");
            }

            user.Email = normalizedEmail;
        }

        if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
        {
            var normalizedPhoneNumber = request.PhoneNumber.Trim();
            if (await _userRepository.ExistsByPhoneAsync(normalizedPhoneNumber, user.Id, cancellationToken))
            {
                throw new ConflictException("Korisnik sa ovim brojem telefona vec postoji.");
            }

            user.PhoneNumber = normalizedPhoneNumber;
        }

        if (request.FirstName is not null)
        {
            user.FirstName = request.FirstName.Trim();
        }

        if (request.LastName is not null)
        {
            user.LastName = request.LastName.Trim();
        }

        if (!string.IsNullOrWhiteSpace(request.Password))
        {
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);
        }

        await _userRepository.UpdateAsync(user, cancellationToken);
        return MapToResponse(user);
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

    private static UserResponse MapToResponse(Core.Entities.User user)
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

public class UpdateUserCommandValidator : AbstractValidator<UpdateUserCommand>
{
    public UpdateUserCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);

        RuleFor(x => x.FirstName)
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(100)
            .When(x => x.FirstName is not null);

        RuleFor(x => x.LastName)
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(100)
            .When(x => x.LastName is not null);

        RuleFor(x => x.Username)
            .NotEmpty()
            .MinimumLength(3)
            .MaximumLength(50)
            .When(x => x.Username is not null);

        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress()
            .MinimumLength(5)
            .MaximumLength(255)
            .When(x => x.Email is not null);

        RuleFor(x => x.PhoneNumber)
            .NotEmpty()
            .MinimumLength(9)
            .MaximumLength(20)
            .Matches(@"^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$")
            .When(x => x.PhoneNumber is not null)
            .WithMessage("Broj telefona mora biti u formatu 061 123 456 ili +387 61 123 456.");

        RuleFor(x => x.Password)
            .NotEmpty()
            .MinimumLength(6)
            .MaximumLength(100)
            .When(x => x.Password is not null);
    }
}
