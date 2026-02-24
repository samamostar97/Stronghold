using FluentValidation;
using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Supplements.Commands;

public class DeleteSupplementImageCommand : IRequest<Unit>
{
    public int Id { get; set; }
}

public class DeleteSupplementImageCommandHandler : IRequestHandler<DeleteSupplementImageCommand, Unit>
{
    private readonly ISupplementRepository _supplementRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly IFileStorageService _fileStorageService;

    public DeleteSupplementImageCommandHandler(
        ISupplementRepository supplementRepository,
        ICurrentUserService currentUserService,
        IFileStorageService fileStorageService)
    {
        _supplementRepository = supplementRepository;
        _currentUserService = currentUserService;
        _fileStorageService = fileStorageService;
    }

    public async Task<Unit> Handle(DeleteSupplementImageCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var supplement = await _supplementRepository.GetByIdAsync(request.Id, cancellationToken);
        if (supplement is null)
        {
            throw new KeyNotFoundException($"Suplement sa id '{request.Id}' ne postoji.");
        }

        if (!string.IsNullOrWhiteSpace(supplement.SupplementImageUrl))
        {
            await _fileStorageService.DeleteAsync(supplement.SupplementImageUrl);
            supplement.SupplementImageUrl = null;
            await _supplementRepository.UpdateAsync(supplement, cancellationToken);
        }

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

public class DeleteSupplementImageCommandValidator : AbstractValidator<DeleteSupplementImageCommand>
{
    public DeleteSupplementImageCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0);
    }
}
