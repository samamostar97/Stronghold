using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Addresses.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Addresses.Queries;

public class GetMyAddressQuery : IRequest<AddressResponse?>
{
}

public class GetMyAddressQueryHandler : IRequestHandler<GetMyAddressQuery, AddressResponse?>
{
    private readonly IAddressRepository _addressRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetMyAddressQueryHandler(IAddressRepository addressRepository, ICurrentUserService currentUserService)
    {
        _addressRepository = addressRepository;
        _currentUserService = currentUserService;
    }

    public async Task<AddressResponse?> Handle(GetMyAddressQuery request, CancellationToken cancellationToken)
    {
        var userId = EnsureAuthenticatedAccess();

        var address = await _addressRepository.GetByUserIdAsync(userId, cancellationToken);
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

    private int EnsureAuthenticatedAccess()
    {
        if (!_currentUserService.IsAuthenticated || !_currentUserService.UserId.HasValue)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        return _currentUserService.UserId.Value;
    }
}

public class GetMyAddressQueryValidator : AbstractValidator<GetMyAddressQuery>
{
}
