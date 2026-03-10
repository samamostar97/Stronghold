using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Users.UpdateMyProfile;

public class UpdateMyProfileCommandHandler : IRequestHandler<UpdateMyProfileCommand, UserResponse>
{
    private readonly IUserRepository _userRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateMyProfileCommandHandler(IUserRepository userRepository, ICurrentUserService currentUserService)
    {
        _userRepository = userRepository;
        _currentUserService = currentUserService;
    }

    public async Task<UserResponse> Handle(UpdateMyProfileCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(_currentUserService.UserId)
            ?? throw new NotFoundException("Korisnik", _currentUserService.UserId);

        user.FirstName = request.FirstName;
        user.LastName = request.LastName;
        user.Phone = request.Phone;
        user.Address = request.Address;

        _userRepository.Update(user);
        await _userRepository.SaveChangesAsync();

        return UserMappings.ToResponse(user);
    }
}
