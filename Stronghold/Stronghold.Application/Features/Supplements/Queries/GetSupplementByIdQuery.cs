using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Supplements.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Supplements.Queries;

public class GetSupplementByIdQuery : IRequest<SupplementResponse>, IAuthorizeAdminOrGymMemberRequest
{
    public int Id { get; set; }
}

public class GetSupplementByIdQueryHandler : IRequestHandler<GetSupplementByIdQuery, SupplementResponse>
{
    private readonly ISupplementRepository _supplementRepository;

    public GetSupplementByIdQueryHandler(ISupplementRepository supplementRepository)
    {
        _supplementRepository = supplementRepository;
    }

public async Task<SupplementResponse> Handle(GetSupplementByIdQuery request, CancellationToken cancellationToken)
    {
        var supplement = await _supplementRepository.GetByIdAsync(request.Id, cancellationToken);
        if (supplement is null)
        {
            throw new KeyNotFoundException($"Suplement sa id '{request.Id}' ne postoji.");
        }

        return MapToResponse(supplement);
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

public class GetSupplementByIdQueryValidator : AbstractValidator<GetSupplementByIdQuery>
{
    public GetSupplementByIdQueryValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }