using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Addresses.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Addresses.Commands;

public class UpsertMyAddressCommand : IRequest<AddressResponse>, IAuthorizeAuthenticatedRequest
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
        var userId = _currentUserService.UserId!.Value;
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
    }

public class UpsertMyAddressCommandValidator : AbstractValidator<UpsertMyAddressCommand>
{
    public UpsertMyAddressCommandValidator()
    {
        RuleFor(x => x.Street)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MaximumLength(200).WithMessage("{PropertyName} ne smije imati vise od 200 karaktera.");

        RuleFor(x => x.City)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.");

        RuleFor(x => x.PostalCode)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MaximumLength(20).WithMessage("{PropertyName} ne smije imati vise od 20 karaktera.");

        RuleFor(x => x.Country)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.");
    }
    }