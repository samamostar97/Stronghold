using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.MembershipPackages.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.MembershipPackages.Commands;

public class UpdateMembershipPackageCommand : IRequest<MembershipPackageResponse>
{
    public int Id { get; set; }
    public string? PackageName { get; set; }
    public decimal? PackagePrice { get; set; }
    public string? Description { get; set; }
}

public class UpdateMembershipPackageCommandHandler
    : IRequestHandler<UpdateMembershipPackageCommand, MembershipPackageResponse>
{
    private readonly IMembershipPackageRepository _membershipPackageRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateMembershipPackageCommandHandler(
        IMembershipPackageRepository membershipPackageRepository,
        ICurrentUserService currentUserService)
    {
        _membershipPackageRepository = membershipPackageRepository;
        _currentUserService = currentUserService;
    }

    public async Task<MembershipPackageResponse> Handle(
        UpdateMembershipPackageCommand request,
        CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var membershipPackage = await _membershipPackageRepository.GetByIdAsync(request.Id, cancellationToken);
        if (membershipPackage is null)
        {
            throw new KeyNotFoundException($"Paket sa id '{request.Id}' ne postoji.");
        }

        if (!string.IsNullOrWhiteSpace(request.PackageName))
        {
            var exists = await _membershipPackageRepository.ExistsByNameAsync(
                request.PackageName,
                membershipPackage.Id,
                cancellationToken);
            if (exists)
            {
                throw new ConflictException("Paket sa ovim nazivom vec postoji.");
            }

            membershipPackage.PackageName = request.PackageName.Trim();
        }

        if (request.PackagePrice.HasValue)
        {
            membershipPackage.PackagePrice = request.PackagePrice.Value;
        }

        if (request.Description is not null)
        {
            membershipPackage.Description = string.IsNullOrWhiteSpace(request.Description)
                ? string.Empty
                : request.Description.Trim();
        }

        await _membershipPackageRepository.UpdateAsync(membershipPackage, cancellationToken);

        return new MembershipPackageResponse
        {
            Id = membershipPackage.Id,
            PackageName = membershipPackage.PackageName,
            PackagePrice = membershipPackage.PackagePrice,
            Description = membershipPackage.Description,
            CreatedAt = membershipPackage.CreatedAt
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

public class UpdateMembershipPackageCommandValidator : AbstractValidator<UpdateMembershipPackageCommand>
{
    public UpdateMembershipPackageCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0);

        RuleFor(x => x.PackageName)
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(50)
            .When(x => x.PackageName is not null);

        RuleFor(x => x.PackagePrice)
            .GreaterThan(0)
            .LessThanOrEqualTo(10000)
            .When(x => x.PackagePrice.HasValue);

        RuleFor(x => x.Description)
            .MaximumLength(500)
            .When(x => x.Description is not null);
    }
}
