using FluentValidation;
using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Users.Commands;

public class DeleteUserImageCommand : IRequest<Unit>
{
    public int Id { get; set; }
}

public class DeleteUserImageCommandHandler : IRequestHandler<DeleteUserImageCommand, Unit>
{
    private readonly IUserRepository _userRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly IFileStorageService _fileStorageService;

    public DeleteUserImageCommandHandler(
        IUserRepository userRepository,
        ICurrentUserService currentUserService,
        IFileStorageService fileStorageService)
    {
        _userRepository = userRepository;
        _currentUserService = currentUserService;
        _fileStorageService = fileStorageService;
    }

    public async Task<Unit> Handle(DeleteUserImageCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var user = await _userRepository.GetByIdAsync(request.Id, cancellationToken);
        if (user is null)
        {
            throw new KeyNotFoundException("Korisnik nije pronadjen.");
        }

        if (string.IsNullOrWhiteSpace(user.ProfileImageUrl))
        {
            return Unit.Value;
        }

        await _fileStorageService.DeleteAsync(user.ProfileImageUrl);
        user.ProfileImageUrl = null;
        await _userRepository.UpdateAsync(user, cancellationToken);

        return Unit.Value;
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
}

public class DeleteUserImageCommandValidator : AbstractValidator<DeleteUserImageCommand>
{
    public DeleteUserImageCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
}

