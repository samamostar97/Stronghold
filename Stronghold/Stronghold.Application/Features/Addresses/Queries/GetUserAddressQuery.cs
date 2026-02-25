using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Addresses.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Addresses.Queries;

public class GetUserAddressQuery : IRequest<AddressResponse?>, IAuthorizeAdminRequest
{
    public int UserId { get; set; }
}

public class GetUserAddressQueryHandler : IRequestHandler<GetUserAddressQuery, AddressResponse?>
{
    private readonly IAddressRepository _addressRepository;

    public GetUserAddressQueryHandler(IAddressRepository addressRepository)
    {
        _addressRepository = addressRepository;
    }

public async Task<AddressResponse?> Handle(GetUserAddressQuery request, CancellationToken cancellationToken)
    {
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
    }

public class GetUserAddressQueryValidator : AbstractValidator<GetUserAddressQuery>
{
    public GetUserAddressQueryValidator()
    {
        RuleFor(x => x.UserId).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }