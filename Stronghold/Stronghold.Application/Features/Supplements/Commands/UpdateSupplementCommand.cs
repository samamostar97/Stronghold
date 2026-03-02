using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.Supplements.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Supplements.Commands;

public class UpdateSupplementCommand : IRequest<SupplementResponse>, IAuthorizeAdminRequest
{
    public int Id { get; set; }

public string? Name { get; set; }

public decimal? Price { get; set; }

public string? Description { get; set; }

public int? SupplementCategoryId { get; set; }

public int? SupplierId { get; set; }

public int? StockQuantity { get; set; }
}

public class UpdateSupplementCommandHandler : IRequestHandler<UpdateSupplementCommand, SupplementResponse>
{
    private readonly ISupplementRepository _supplementRepository;

    public UpdateSupplementCommandHandler(
        ISupplementRepository supplementRepository)
    {
        _supplementRepository = supplementRepository;
    }

public async Task<SupplementResponse> Handle(UpdateSupplementCommand request, CancellationToken cancellationToken)
    {
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

        if (request.StockQuantity.HasValue && request.StockQuantity.Value != supplement.StockQuantity)
        {
            var stockLog = new StockLog
            {
                SupplementId = supplement.Id,
                QuantityChange = request.StockQuantity.Value - supplement.StockQuantity,
                QuantityBefore = supplement.StockQuantity,
                QuantityAfter = request.StockQuantity.Value,
                Reason = "manual_adjustment"
            };

            supplement.StockQuantity = request.StockQuantity.Value;
            await _supplementRepository.AddStockLogAsync(stockLog, cancellationToken);
        }

        await _supplementRepository.UpdateAsync(supplement, cancellationToken);

        var updated = await _supplementRepository.GetByIdAsync(supplement.Id, cancellationToken) ?? supplement;
        return MapToResponse(updated);
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
            StockQuantity = supplement.StockQuantity,
            CreatedAt = supplement.CreatedAt
        };
    }
    }

public class UpdateSupplementCommandValidator : AbstractValidator<UpdateSupplementCommand>
{
    public UpdateSupplementCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");

        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.")
            .When(x => x.Name is not null);

        RuleFor(x => x.Price)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.")
            .LessThanOrEqualTo(10000).WithMessage("{PropertyName} mora biti manje ili jednako dozvoljenoj vrijednosti.")
            .When(x => x.Price.HasValue);

        RuleFor(x => x.Description)
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(1000).WithMessage("{PropertyName} ne smije imati vise od 1000 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Description));

        RuleFor(x => x.SupplementCategoryId)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.")
            .When(x => x.SupplementCategoryId.HasValue);

        RuleFor(x => x.SupplierId)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.")
            .When(x => x.SupplierId.HasValue);

        RuleFor(x => x.StockQuantity)
            .GreaterThanOrEqualTo(0).WithMessage("{PropertyName} ne smije biti negativno.")
            .LessThanOrEqualTo(99999).WithMessage("{PropertyName} ne smije biti vece od 99999.")
            .When(x => x.StockQuantity.HasValue);
    }
    }