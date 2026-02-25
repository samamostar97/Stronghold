using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Supplements.Commands;

public class DeleteSupplementCommand : IRequest<Unit>, IAuthorizeAdminRequest
{
    public int Id { get; set; }
}

public class DeleteSupplementCommandHandler : IRequestHandler<DeleteSupplementCommand, Unit>
{
    private readonly ISupplementRepository _supplementRepository;
    private readonly IFileStorageService _fileStorageService;

    public DeleteSupplementCommandHandler(
        ISupplementRepository supplementRepository,
        IFileStorageService fileStorageService)
    {
        _supplementRepository = supplementRepository;
        _fileStorageService = fileStorageService;
    }

public async Task<Unit> Handle(DeleteSupplementCommand request, CancellationToken cancellationToken)
    {
        var supplement = await _supplementRepository.GetByIdAsync(request.Id, cancellationToken);
        if (supplement is null)
        {
            throw new KeyNotFoundException($"Suplement sa id '{request.Id}' ne postoji.");
        }

        var hasReviews = await _supplementRepository.HasReviewsAsync(supplement.Id, cancellationToken);
        if (hasReviews)
        {
            throw new EntityHasDependentsException("suplement", "recenzije");
        }

        if (!string.IsNullOrWhiteSpace(supplement.SupplementImageUrl))
        {
            await _fileStorageService.DeleteAsync(supplement.SupplementImageUrl);
        }

        await _supplementRepository.DeleteAsync(supplement, cancellationToken);
        return Unit.Value;
    }
    }

public class DeleteSupplementCommandValidator : AbstractValidator<DeleteSupplementCommand>
{
    public DeleteSupplementCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }