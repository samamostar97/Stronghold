using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Users.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Users.Commands;

public class UploadUserImageCommand : IRequest<UserResponse>
{
    public int Id { get; set; }
    public FileUploadRequest FileRequest { get; set; } = null!;
}

public class UploadUserImageCommandHandler : IRequestHandler<UploadUserImageCommand, UserResponse>
{
    private readonly IUserRepository _userRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly IFileStorageService _fileStorageService;

    public UploadUserImageCommandHandler(
        IUserRepository userRepository,
        ICurrentUserService currentUserService,
        IFileStorageService fileStorageService)
    {
        _userRepository = userRepository;
        _currentUserService = currentUserService;
        _fileStorageService = fileStorageService;
    }

    public async Task<UserResponse> Handle(UploadUserImageCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var user = await _userRepository.GetByIdAsync(request.Id, cancellationToken);
        if (user is null)
        {
            throw new KeyNotFoundException("Korisnik nije pronadjen.");
        }

        if (!string.IsNullOrWhiteSpace(user.ProfileImageUrl))
        {
            await _fileStorageService.DeleteAsync(user.ProfileImageUrl);
        }

        var uploadResult = await _fileStorageService.UploadAsync(request.FileRequest, "users", user.Id.ToString());
        if (!uploadResult.Success)
        {
            throw new InvalidOperationException(uploadResult.ErrorMessage ?? "Neuspjesan upload slike.");
        }

        user.ProfileImageUrl = uploadResult.FileUrl;
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

public class UploadUserImageCommandValidator : AbstractValidator<UploadUserImageCommand>
{
    public UploadUserImageCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);

        RuleFor(x => x.FileRequest)
            .NotNull();

        RuleFor(x => x.FileRequest.FileName)
            .NotEmpty();

        RuleFor(x => x.FileRequest.ContentType)
            .NotEmpty();

        RuleFor(x => x.FileRequest.FileSize)
            .GreaterThan(0);
    }
}
