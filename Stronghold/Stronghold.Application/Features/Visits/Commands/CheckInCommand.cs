using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Visits.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Visits.Commands;

public class CheckInCommand : IRequest<VisitResponse>
{
    public int UserId { get; set; }
}

public class CheckInCommandHandler : IRequestHandler<CheckInCommand, VisitResponse>
{
    private readonly IVisitRepository _visitRepository;
    private readonly ICurrentUserService _currentUserService;

    public CheckInCommandHandler(IVisitRepository visitRepository, ICurrentUserService currentUserService)
    {
        _visitRepository = visitRepository;
        _currentUserService = currentUserService;
    }

    public async Task<VisitResponse> Handle(CheckInCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var user = await _visitRepository.GetUserByIdAsync(request.UserId, cancellationToken);
        if (user is null)
        {
            throw new KeyNotFoundException($"Korisnik sa id '{request.UserId}' ne postoji.");
        }

        var nowUtc = StrongholdTimeUtils.UtcNow;
        var hasActiveMembership = await _visitRepository.HasActiveMembershipAsync(request.UserId, nowUtc, cancellationToken);
        if (!hasActiveMembership)
        {
            throw new InvalidOperationException($"Korisnik '{user.FirstName} {user.LastName}' nema aktivnu clanarinu.");
        }

        var hasActiveVisit = await _visitRepository.HasActiveVisitAsync(request.UserId, cancellationToken);
        if (hasActiveVisit)
        {
            throw new InvalidOperationException($"Korisnik '{user.FirstName} {user.LastName}' je vec prijavljen u teretanu.");
        }

        var visit = new GymVisit
        {
            UserId = request.UserId,
            CheckInTime = nowUtc
        };

        await _visitRepository.AddAsync(visit, cancellationToken);

        return new VisitResponse
        {
            Id = visit.Id,
            UserId = user.Id,
            Username = user.Username,
            FirstName = user.FirstName,
            LastName = user.LastName,
            CheckInTime = visit.CheckInTime
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

public class CheckInCommandValidator : AbstractValidator<CheckInCommand>
{
    public CheckInCommandValidator()
    {
        RuleFor(x => x.UserId).GreaterThan(0);
    }
}
