using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Enums;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Users.CreateUser;

public class CreateUserCommandHandler : IRequestHandler<CreateUserCommand, UserResponse>
{
    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;

    public CreateUserCommandHandler(IUserRepository userRepository, IPasswordHasher passwordHasher)
    {
        _userRepository = userRepository;
        _passwordHasher = passwordHasher;
    }

    public async Task<UserResponse> Handle(CreateUserCommand request, CancellationToken cancellationToken)
    {
        var fieldErrors = new Dictionary<string, string>();

        var existingByUsername = await _userRepository.GetByUsernameAsync(request.Username);
        if (existingByUsername != null)
            fieldErrors["username"] = "Korisničko ime je već zauzeto.";

        var existingByEmail = await _userRepository.GetByEmailAsync(request.Email);
        if (existingByEmail != null)
            fieldErrors["email"] = "Email je već registrovan.";

        if (!string.IsNullOrWhiteSpace(request.Phone))
        {
            var existingByPhone = await _userRepository.GetByPhoneAsync(request.Phone);
            if (existingByPhone != null)
                fieldErrors["phone"] = "Broj telefona je već registrovan.";
        }

        if (fieldErrors.Count > 0)
            throw new ConflictException(fieldErrors);

        var user = new User
        {
            Username = request.Username,
            Email = request.Email,
            FirstName = request.FirstName,
            LastName = request.LastName,
            Phone = request.Phone,
            Address = request.Address,
            PasswordHash = _passwordHasher.Hash(request.Password),
            Role = Role.User
        };

        await _userRepository.AddAsync(user);
        await _userRepository.SaveChangesAsync();

        return UserMappings.ToResponse(user);
    }
}
