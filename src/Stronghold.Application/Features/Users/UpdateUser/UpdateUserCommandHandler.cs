using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Users.UpdateUser;

public class UpdateUserCommandHandler : IRequestHandler<UpdateUserCommand, UserResponse>
{
    private readonly IUserRepository _userRepository;

    public UpdateUserCommandHandler(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }

    public async Task<UserResponse> Handle(UpdateUserCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Korisnik", request.Id);

        var fieldErrors = new Dictionary<string, string>();

        if (user.Username != request.Username)
        {
            var existingByUsername = await _userRepository.GetByUsernameAsync(request.Username);
            if (existingByUsername != null)
                fieldErrors["username"] = "Korisničko ime je već zauzeto.";
        }

        if (user.Email != request.Email)
        {
            var existingByEmail = await _userRepository.GetByEmailAsync(request.Email);
            if (existingByEmail != null)
                fieldErrors["email"] = "Email je već registrovan.";
        }

        if (!string.IsNullOrWhiteSpace(request.Phone) && user.Phone != request.Phone)
        {
            var existingByPhone = await _userRepository.GetByPhoneAsync(request.Phone);
            if (existingByPhone != null)
                fieldErrors["phone"] = "Broj telefona je već registrovan.";
        }

        if (fieldErrors.Count > 0)
            throw new ConflictException(fieldErrors);

        user.FirstName = request.FirstName;
        user.LastName = request.LastName;
        user.Username = request.Username;
        user.Email = request.Email;
        user.Phone = request.Phone;
        user.Address = request.Address;

        _userRepository.Update(user);
        await _userRepository.SaveChangesAsync();

        return UserMappings.ToResponse(user);
    }
}
