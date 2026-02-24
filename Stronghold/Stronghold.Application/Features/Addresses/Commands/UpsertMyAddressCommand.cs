using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Addresses.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Addresses.Commands;

public class UpsertMyAddressCommand : IRequest<AddressResponse>
{
    public string Street { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string PostalCode { get; set; } = string.Empty;
    public string Country { get; set; } = "Bosna i Hercegovina";
}

public class UpsertMyAddressCommandHandler : IRequestHandler<UpsertMyAddressCommand, AddressResponse>
{
    private readonly IAddressRepository _addressRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpsertMyAddressCommandHandler(IAddressRepository addressRepository, ICurrentUserService currentUserService)
    {
        _addressRepository = addressRepository;
        _currentUserService = currentUserService;
    }

    public async Task<AddressResponse> Handle(UpsertMyAddressCommand request, CancellationToken cancellationToken)
    {
        var userId = EnsureAuthenticatedAccess();

        var address = await _addressRepository.UpsertAsync(
            userId,
            request.Street.Trim(),
            request.City.Trim(),
            request.PostalCode.Trim(),
            string.IsNullOrWhiteSpace(request.Country) ? "Bosna i Hercegovina" : request.Country.Trim(),
            cancellationToken);

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

public class UpsertMyAddressCommandValidator : AbstractValidator<UpsertMyAddressCommand>
{
    public UpsertMyAddressCommandValidator()
    {
        RuleFor(x => x.Street)
            .NotEmpty()
            .MaximumLength(200);

        RuleFor(x => x.City)
            .NotEmpty()
            .MaximumLength(100);

        RuleFor(x => x.PostalCode)
            .NotEmpty()
            .MaximumLength(20);

        RuleFor(x => x.Country)
            .NotEmpty()
            .MaximumLength(100);
    }
}
