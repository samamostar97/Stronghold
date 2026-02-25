using FluentValidation;
using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Supplements.Commands;

public class DeleteSupplementImageCommand : IRequest<Unit>, IAuthorizeAdminRequest
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
    }

public class DeleteSupplementImageCommandValidator : AbstractValidator<DeleteSupplementImageCommand>
{
    public DeleteSupplementImageCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }