using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.Suppliers.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Suppliers.Commands;

public class CreateSupplierCommand : IRequest<SupplierResponse>, IAuthorizeAdminRequest
{
    public string Name { get; set; } = string.Empty;
    public string? Website { get; set; }
}

public class CreateSupplierCommandHandler : IRequestHandler<CreateSupplierCommand, SupplierResponse>
{
    private readonly ISupplierRepository _supplierRepository;
    private readonly ICurrentUserService _currentUserService;

    public CreateSupplierCommandHandler(ISupplierRepository supplierRepository, ICurrentUserService currentUserService)
    {
        _supplierRepository = supplierRepository;
        _currentUserService = currentUserService;
    }

public async Task<SupplierResponse> Handle(CreateSupplierCommand request, CancellationToken cancellationToken)
    {
        var exists = await _supplierRepository.ExistsByNameAsync(request.Name, cancellationToken: cancellationToken);
        if (exists)
        {
            throw new ConflictException("Dobavljac sa ovim nazivom vec postoji.");
        }

        var entity = new Supplier
        {
            Name = request.Name.Trim(),
            Website = string.IsNullOrWhiteSpace(request.Website) ? null : request.Website.Trim()
        };

        await _supplierRepository.AddAsync(entity, cancellationToken);

        return new SupplierResponse
        {
            Id = entity.Id,
            Name = entity.Name,
            Website = entity.Website,
            CreatedAt = entity.CreatedAt
        };
    }
    }

public class CreateSupplierCommandValidator : AbstractValidator<CreateSupplierCommand>
{
    public CreateSupplierCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(50).WithMessage("{PropertyName} ne smije imati vise od 50 karaktera.");

        RuleFor(x => x.Website)
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Website));

        RuleFor(x => x.Website)
            .Matches(@"^(https?://)?(www\.)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(/.*)?$")
            .When(x => !string.IsNullOrWhiteSpace(x.Website))
            .WithMessage("Unesite ispravnu web adresu.");
    }
    }