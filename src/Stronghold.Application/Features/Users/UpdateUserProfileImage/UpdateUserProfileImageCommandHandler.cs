using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Users.UpdateUserProfileImage;

public class UpdateUserProfileImageCommandHandler : IRequestHandler<UpdateUserProfileImageCommand, UserResponse>
{
    private readonly IUserRepository _userRepository;
    private readonly IFileService _fileService;

    public UpdateUserProfileImageCommandHandler(IUserRepository userRepository, IFileService fileService)
    {
        _userRepository = userRepository;
        _fileService = fileService;
    }

    public async Task<UserResponse> Handle(UpdateUserProfileImageCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Korisnik", request.Id);

        if (!string.IsNullOrEmpty(user.ProfileImageUrl))
            _fileService.Delete(user.ProfileImageUrl);

        user.ProfileImageUrl = await _fileService.UploadAsync(request.FileStream, request.FileName, "profile-images");

        _userRepository.Update(user);
        await _userRepository.SaveChangesAsync();

        return UserMappings.ToResponse(user);
    }
}
