using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.MembershipPackages.Commands;

public class DeleteMembershipPackageCommand : IRequest<Unit>, IAuthorizeAdminRequest
{
    public int Id { get; set; }
}

public class DeleteMembershipPackageCommandHandler : IRequestHandler<DeleteMembershipPackageCommand, Unit>
{
    private readonly IMembershipPackageRepository _membershipPackageRepository;
    private readonly ICurrentUserService _currentUserService;

    public DeleteMembershipPackageCommandHandler(
        IMembershipPackageRepository membershipPackageRepository,
        ICurrentUserService currentUserService)
    {
        _membershipPackageRepository = membershipPackageRepository;
        _currentUserService = currentUserService;
    }

public async Task<Unit> Handle(DeleteMembershipPackageCommand request, CancellationToken cancellationToken)
    {
        var membershipPackage = await _membershipPackageRepository.GetByIdAsync(request.Id, cancellationToken);
        if (membershipPackage is null)
        {
            throw new KeyNotFoundException($"Paket sa id '{request.Id}' ne postoji.");
        }

        var hasActiveMemberships = await _membershipPackageRepository.HasActiveMembershipsAsync(
            membershipPackage.Id,
            cancellationToken);
        if (hasActiveMemberships)
        {
            throw new EntityHasDependentsException("paket clanarine", "aktivne clanove");
        }

        await _membershipPackageRepository.DeleteAsync(membershipPackage, cancellationToken);
        return Unit.Value;
    }
    }

public class DeleteMembershipPackageCommandValidator : AbstractValidator<DeleteMembershipPackageCommand>
{
    public DeleteMembershipPackageCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }