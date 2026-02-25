using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.Suppliers.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Suppliers.Commands;

public class UpdateSupplierCommand : IRequest<SupplierResponse>, IAuthorizeAdminRequest
{
    public int Id { get; set; }

public string? Name { get; set; }

public string? Website { get; set; }
}

public class UpdateSupplierCommandHandler : IRequestHandler<UpdateSupplierCommand, SupplierResponse>
{
    private readonly ISupplierRepository _supplierRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateSupplierCommandHandler(ISupplierRepository supplierRepository, ICurrentUserService currentUserService)
    {
        _supplierRepository = supplierRepository;
        _currentUserService = currentUserService;
    }

public async Task<SupplierResponse> Handle(UpdateSupplierCommand request, CancellationToken cancellationToken)
    {
        var supplier = await _supplierRepository.GetByIdAsync(request.Id, cancellationToken);
        if (supplier is null)
        {
            throw new KeyNotFoundException($"Dobavljac sa id '{request.Id}' ne postoji.");
        }

        if (!string.IsNullOrWhiteSpace(request.Name))
        {
            var exists = await _supplierRepository.ExistsByNameAsync(request.Name, supplier.Id, cancellationToken);
            if (exists)
            {
                throw new ConflictException("Dobavljac sa ovim nazivom vec postoji.");
            }

            supplier.Name = request.Name.Trim();
        }

        if (request.Website is not null)
        {
            supplier.Website = string.IsNullOrWhiteSpace(request.Website) ? null : request.Website.Trim();
        }

        await _supplierRepository.UpdateAsync(supplier, cancellationToken);

        return new SupplierResponse
        {
            Id = supplier.Id,
            Name = supplier.Name,
            Website = supplier.Website,
            CreatedAt = supplier.CreatedAt
        };
    }
    }

public class UpdateSupplierCommandValidator : AbstractValidator<UpdateSupplierCommand>
{
    public UpdateSupplierCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");

        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(50).WithMessage("{PropertyName} ne smije imati vise od 50 karaktera.")
            .When(x => x.Name is not null);

        RuleFor(x => x.Website)
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.")
            .When(x => x.Website is not null && x.Website.Length > 0);

        RuleFor(x => x.Website)
            .Matches(@"^(https?://)?(www\.)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(/.*)?$")
            .When(x => !string.IsNullOrWhiteSpace(x.Website))
            .WithMessage("Unesite ispravnu web adresu.");
    }
    }