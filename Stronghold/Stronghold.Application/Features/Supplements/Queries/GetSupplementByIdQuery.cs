using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Supplements.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Supplements.Queries;

public class GetSupplementByIdQuery : IRequest<SupplementResponse>
{
    public int Id { get; set; }
}

public class GetSupplementByIdQueryHandler : IRequestHandler<GetSupplementByIdQuery, SupplementResponse>
{
    private readonly ISupplementRepository _supplementRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetSupplementByIdQueryHandler(ISupplementRepository supplementRepository, ICurrentUserService currentUserService)
    {
        _supplementRepository = supplementRepository;
        _currentUserService = currentUserService;
    }

    public async Task<SupplementResponse> Handle(GetSupplementByIdQuery request, CancellationToken cancellationToken)
    {
        EnsureReadAccess();

        var supplement = await _supplementRepository.GetByIdAsync(request.Id, cancellationToken);
        if (supplement is null)
        {
            throw new KeyNotFoundException($"Suplement sa id '{request.Id}' ne postoji.");
        }

        return MapToResponse(supplement);
    }

    private void EnsureReadAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("Admin") && !_currentUserService.IsInRole("GymMember"))
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

public class GetSupplementByIdQueryValidator : AbstractValidator<GetSupplementByIdQuery>
{
    public GetSupplementByIdQueryValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0);
    }
}
