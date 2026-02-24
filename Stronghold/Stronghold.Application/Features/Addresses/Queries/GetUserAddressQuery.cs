using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Addresses.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Addresses.Queries;

public class GetUserAddressQuery : IRequest<AddressResponse?>
{
    public int UserId { get; set; }
}

public class GetUserAddressQueryHandler : IRequestHandler<GetUserAddressQuery, AddressResponse?>
{
    private readonly IAddressRepository _addressRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetUserAddressQueryHandler(IAddressRepository addressRepository, ICurrentUserService currentUserService)
    {
        _addressRepository = addressRepository;
        _currentUserService = currentUserService;
    }

    public async Task<AddressResponse?> Handle(GetUserAddressQuery request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var address = await _addressRepository.GetByUserIdAsync(request.UserId, cancellationToken);
        if (address is null)
        {
            return null;
        }

        return new AddressResponse
        {
            Id = address.Id,
            Street = address.Street,
            City = address.City,
            PostalCode = address.PostalCode,
            Country = address.Country
        };
    }

    private void EnsureAdminAccess()
    {
        if (!_currentUserService.IsAuthenticated || !_currentUserService.UserId.HasValue)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("Admin"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }
    }
}

public class GetUserAddressQueryValidator : AbstractValidator<GetUserAddressQuery>
{
    public GetUserAddressQueryValidator()
    {
        RuleFor(x => x.UserId).GreaterThan(0);
    }
}
