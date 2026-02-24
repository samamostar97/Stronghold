using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.Supplements.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Supplements.Commands;

public class UpdateSupplementCommand : IRequest<SupplementResponse>
{
    public int Id { get; set; }
    public string? Name { get; set; }
    public decimal? Price { get; set; }
    public string? Description { get; set; }
    public int? SupplementCategoryId { get; set; }
    public int? SupplierId { get; set; }
}

public class UpdateSupplementCommandHandler : IRequestHandler<UpdateSupplementCommand, SupplementResponse>
{
    private readonly ISupplementRepository _supplementRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateSupplementCommandHandler(
        ISupplementRepository supplementRepository,
        ICurrentUserService currentUserService)
    {
        _supplementRepository = supplementRepository;
        _currentUserService = currentUserService;
    }

    public async Task<SupplementResponse> Handle(UpdateSupplementCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var supplement = await _supplementRepository.GetByIdAsync(request.Id, cancellationToken);
        if (supplement is null)
        {
            throw new KeyNotFoundException($"Suplement sa id '{request.Id}' ne postoji.");
        }

        if (!string.IsNullOrWhiteSpace(request.Name))
        {
            var exists = await _supplementRepository.ExistsByNameAsync(request.Name, supplement.Id, cancellationToken);
            if (exists)
            {
                throw new ConflictException("Suplement sa ovim nazivom vec postoji.");
            }

            supplement.Name = request.Name.Trim();
        }

        if (request.Price.HasValue)
        {
            supplement.Price = request.Price.Value;
        }

        if (request.Description is not null)
        {
            supplement.Description = string.IsNullOrWhiteSpace(request.Description) ? null : request.Description.Trim();
        }

        if (request.SupplementCategoryId.HasValue)
        {
            var categoryExists = await _supplementRepository.SupplementCategoryExistsAsync(
                request.SupplementCategoryId.Value,
                cancellationToken);
            if (!categoryExists)
            {
                throw new KeyNotFoundException(
                    $"Kategorija suplementa sa id '{request.SupplementCategoryId.Value}' ne postoji.");
            }

            supplement.SupplementCategoryId = request.SupplementCategoryId.Value;
        }

        if (request.SupplierId.HasValue)
        {
            var supplierExists = await _supplementRepository.SupplierExistsAsync(request.SupplierId.Value, cancellationToken);
            if (!supplierExists)
            {
                throw new KeyNotFoundException($"Dobavljac sa id '{request.SupplierId.Value}' ne postoji.");
            }

            supplement.SupplierId = request.SupplierId.Value;
        }

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

public class UpdateSupplementCommandValidator : AbstractValidator<UpdateSupplementCommand>
{
    public UpdateSupplementCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0);

        RuleFor(x => x.Name)
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(100)
            .When(x => x.Name is not null);

        RuleFor(x => x.Price)
            .GreaterThan(0)
            .LessThanOrEqualTo(10000)
            .When(x => x.Price.HasValue);

        RuleFor(x => x.Description)
            .MinimumLength(2)
            .MaximumLength(1000)
            .When(x => !string.IsNullOrWhiteSpace(x.Description));

        RuleFor(x => x.SupplementCategoryId)
            .GreaterThan(0)
            .When(x => x.SupplementCategoryId.HasValue);

        RuleFor(x => x.SupplierId)
            .GreaterThan(0)
            .When(x => x.SupplierId.HasValue);
    }
}
