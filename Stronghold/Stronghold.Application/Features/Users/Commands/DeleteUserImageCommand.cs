using FluentValidation;
using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Users.Commands;

public class DeleteUserImageCommand : IRequest<Unit>, IAuthorizeAdminRequest
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
    }

public class DeleteUserImageCommandValidator : AbstractValidator<DeleteUserImageCommand>
{
    public DeleteUserImageCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }