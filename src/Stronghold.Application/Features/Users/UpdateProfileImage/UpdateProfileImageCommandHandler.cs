using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Users.UpdateProfileImage;

public class UpdateProfileImageCommandHandler : IRequestHandler<UpdateProfileImageCommand, UserResponse>
{
    private readonly IUserRepository _userRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly IFileService _fileService;

    public UpdateProfileImageCommandHandler(
        IUserRepository userRepository,
        ICurrentUserService currentUserService,
        IFileService fileService)
    {
        _userRepository = userRepository;
        _currentUserService = currentUserService;
        _fileService = fileService;
    }

    public async Task<UserResponse> Handle(UpdateProfileImageCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(_currentUserService.UserId)
            ?? throw new NotFoundException("Korisnik", _currentUserService.UserId);

        if (!string.IsNullOrEmpty(user.ProfileImageUrl))
            _fileService.Delete(user.ProfileImageUrl);

        user.ProfileImageUrl = await _fileService.UploadAsync(request.FileStream, request.FileName, "profile-images");

        _userRepository.Update(user);
        await _userRepository.SaveChangesAsync();

        return UserMappings.ToResponse(user);
    }
}
