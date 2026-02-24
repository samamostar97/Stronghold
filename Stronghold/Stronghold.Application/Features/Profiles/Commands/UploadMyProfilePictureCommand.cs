using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Profiles.Commands;

public class UploadMyProfilePictureCommand : IRequest<string>
{
    public FileUploadRequest FileRequest { get; set; } = null!;
}

public class UploadMyProfilePictureCommandHandler : IRequestHandler<UploadMyProfilePictureCommand, string>
{
    private readonly IUserProfileService _userProfileService;
    private readonly ICurrentUserService _currentUserService;

    public UploadMyProfilePictureCommandHandler(
        IUserProfileService userProfileService,
        ICurrentUserService currentUserService)
    {
        _userProfileService = userProfileService;
        _currentUserService = currentUserService;
    }

    public async Task<string> Handle(UploadMyProfilePictureCommand request, CancellationToken cancellationToken)
    {
        var userId = EnsureAuthenticatedAccess();
        return await _userProfileService.UploadProfilePictureAsync(userId, request.FileRequest);
    }

    private int EnsureAuthenticatedAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        return _currentUserService.UserId.Value;
    }
}

public class UploadMyProfilePictureCommandValidator : AbstractValidator<UploadMyProfilePictureCommand>
{
    public UploadMyProfilePictureCommandValidator()
    {
        RuleFor(x => x.FileRequest)
            .NotNull().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.FileRequest.FileName)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MaximumLength(260).WithMessage("{PropertyName} ne smije imati vise od 260 karaktera.");

        RuleFor(x => x.FileRequest.FileSize)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
}

