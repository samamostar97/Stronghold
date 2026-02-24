using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Supplements.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Supplements.Commands;

public class UploadSupplementImageCommand : IRequest<SupplementResponse>
{
    public int Id { get; set; }
    public FileUploadRequest FileRequest { get; set; } = null!;
}

public class UploadSupplementImageCommandHandler : IRequestHandler<UploadSupplementImageCommand, SupplementResponse>
{
    private readonly ISupplementRepository _supplementRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly IFileStorageService _fileStorageService;

    public UploadSupplementImageCommandHandler(
        ISupplementRepository supplementRepository,
        ICurrentUserService currentUserService,
        IFileStorageService fileStorageService)
    {
        _supplementRepository = supplementRepository;
        _currentUserService = currentUserService;
        _fileStorageService = fileStorageService;
    }

    public async Task<SupplementResponse> Handle(UploadSupplementImageCommand request, CancellationToken cancellationToken)
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
        }

        var uploadResult = await _fileStorageService.UploadAsync(request.FileRequest, "supplements", supplement.Id.ToString());
        if (!uploadResult.Success)
        {
            throw new InvalidOperationException(uploadResult.ErrorMessage ?? "Neuspjesan upload slike.");
        }

        supplement.SupplementImageUrl = uploadResult.FileUrl;
        await _supplementRepository.UpdateAsync(supplement, cancellationToken);

        var updated = await _supplementRepository.GetByIdAsync(supplement.Id, cancellationToken) ?? supplement;
        return MapToResponse(updated);
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

    private static SupplementResponse MapToResponse(Supplement supplement)
    {
        return new SupplementResponse
        {
            Id = supplement.Id,
            Name = supplement.Name,
            Price = supplement.Price,
            Description = supplement.Description,
            SupplementCategoryId = supplement.SupplementCategoryId,
            SupplementCategoryName = supplement.SupplementCategory?.Name ?? string.Empty,
            SupplierId = supplement.SupplierId,
            SupplierName = supplement.Supplier?.Name ?? string.Empty,
            ImageUrl = supplement.SupplementImageUrl,
            CreatedAt = supplement.CreatedAt
        };
    }
}

public class UploadSupplementImageCommandValidator : AbstractValidator<UploadSupplementImageCommand>
{
    public UploadSupplementImageCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");

        RuleFor(x => x.FileRequest)
            .NotNull().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.FileRequest.FileName)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.FileRequest.ContentType)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.FileRequest.FileSize)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
}

