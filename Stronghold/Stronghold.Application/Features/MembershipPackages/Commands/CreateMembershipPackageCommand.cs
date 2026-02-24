using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.MembershipPackages.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.MembershipPackages.Commands;

public class CreateMembershipPackageCommand : IRequest<MembershipPackageResponse>
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
        EnsureAdminAccess();

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

    private void EnsureAdminAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("Admin"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }
    }
}

public class CreateMembershipPackageCommandValidator : AbstractValidator<CreateMembershipPackageCommand>
{
    public CreateMembershipPackageCommandValidator()
    {
        RuleFor(x => x.PackageName)
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(50);

        RuleFor(x => x.PackagePrice)
            .GreaterThan(0)
            .LessThanOrEqualTo(10000);

        RuleFor(x => x.Description)
            .MaximumLength(500)
            .When(x => x.Description is not null);
    }
}
