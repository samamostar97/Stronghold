using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.Supplements.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Supplements.Commands;

public class CreateSupplementCommand : IRequest<SupplementResponse>, IAuthorizeAdminRequest
{
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }

public string? Description { get; set; }

public int SupplementCategoryId { get; set; }

public int SupplierId { get; set; }
}

public class CreateSupplementCommandHandler : IRequestHandler<CreateSupplementCommand, SupplementResponse>
{
    private readonly ISupplementRepository _supplementRepository;

    public CreateSupplementCommandHandler(
        ISupplementRepository supplementRepository)
    {
        _supplementRepository = supplementRepository;
    }

public async Task<SupplementResponse> Handle(CreateSupplementCommand request, CancellationToken cancellationToken)
    {
        var exists = await _supplementRepository.ExistsByNameAsync(request.Name, cancellationToken: cancellationToken);
        if (exists)
        {
            throw new ConflictException("Suplement sa ovim nazivom vec postoji.");
        }

        var categoryExists = await _supplementRepository.SupplementCategoryExistsAsync(
            request.SupplementCategoryId,
            cancellationToken);
        if (!categoryExists)
        {
            throw new KeyNotFoundException($"Kategorija suplementa sa id '{request.SupplementCategoryId}' ne postoji.");
        }

        var supplierExists = await _supplementRepository.SupplierExistsAsync(request.SupplierId, cancellationToken);
        if (!supplierExists)
        {
            throw new KeyNotFoundException($"Dobavljac sa id '{request.SupplierId}' ne postoji.");
        }

        var entity = new Supplement
        {
            Name = request.Name.Trim(),
            Price = request.Price,
            Description = string.IsNullOrWhiteSpace(request.Description) ? null : request.Description.Trim(),
            SupplementCategoryId = request.SupplementCategoryId,
            SupplierId = request.SupplierId
        };

        await _supplementRepository.AddAsync(entity, cancellationToken);

        var created = await _supplementRepository.GetByIdAsync(entity.Id, cancellationToken) ?? entity;
        return MapToResponse(created);
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

public class CreateSupplementCommandValidator : AbstractValidator<CreateSupplementCommand>
{
    public CreateSupplementCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.");

        RuleFor(x => x.Price)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.")
            .LessThanOrEqualTo(10000).WithMessage("{PropertyName} mora biti manje ili jednako dozvoljenoj vrijednosti.");

        RuleFor(x => x.Description)
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(1000).WithMessage("{PropertyName} ne smije imati vise od 1000 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Description));

        RuleFor(x => x.SupplementCategoryId)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");

        RuleFor(x => x.SupplierId)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }