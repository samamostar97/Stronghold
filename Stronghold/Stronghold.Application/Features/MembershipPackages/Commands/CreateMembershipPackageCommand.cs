using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.MembershipPackages.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.MembershipPackages.Commands;

public class CreateMembershipPackageCommand : IRequest<MembershipPackageResponse>, IAuthorizeAdminRequest
{
    public string PackageName { get; set; } = string.Empty;
    public decimal PackagePrice { get; set; }

public string? Description { get; set; }
}

public class CreateMembershipPackageCommandHandler
    : IRequestHandler<CreateMembershipPackageCommand, MembershipPackageResponse>
{
    private readonly IMembershipPackageRepository _membershipPackageRepository;
    private readonly ICurrentUserService _currentUserService;

    public CreateMembershipPackageCommandHandler(
        IMembershipPackageRepository membershipPackageRepository,
        ICurrentUserService currentUserService)
    {
        _membershipPackageRepository = membershipPackageRepository;
        _currentUserService = currentUserService;
    }

public async Task<MembershipPackageResponse> Handle(
        CreateMembershipPackageCommand request,
        CancellationToken cancellationToken)
    {
        var exists = await _membershipPackageRepository.ExistsByNameAsync(
            request.PackageName,
            cancellationToken: cancellationToken);
        if (exists)
        {
            throw new ConflictException("Paket sa ovim nazivom vec postoji.");
        }

        var entity = new MembershipPackage
        {
            PackageName = request.PackageName.Trim(),
            PackagePrice = request.PackagePrice,
            Description = string.IsNullOrWhiteSpace(request.Description) ? string.Empty : request.Description.Trim()
        };

        await _membershipPackageRepository.AddAsync(entity, cancellationToken);

        return new MembershipPackageResponse
        {
            Id = entity.Id,
            PackageName = entity.PackageName,
            PackagePrice = entity.PackagePrice,
            Description = entity.Description,
            CreatedAt = entity.CreatedAt
        };
    }
    }

public class CreateMembershipPackageCommandValidator : AbstractValidator<CreateMembershipPackageCommand>
{
    public CreateMembershipPackageCommandValidator()
    {
        RuleFor(x => x.PackageName)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(50).WithMessage("{PropertyName} ne smije imati vise od 50 karaktera.");

        RuleFor(x => x.PackagePrice)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.")
            .LessThanOrEqualTo(10000).WithMessage("{PropertyName} mora biti manje ili jednako dozvoljenoj vrijednosti.");

        RuleFor(x => x.Description)
            .MaximumLength(500).WithMessage("{PropertyName} ne smije imati vise od 500 karaktera.")
            .When(x => x.Description is not null);
    }
    }