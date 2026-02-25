using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Visits.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Visits.Commands;

public class CheckOutCommand : IRequest<VisitResponse>, IAuthorizeAdminRequest
{
    public int VisitId { get; set; }
}

public class CheckOutCommandHandler : IRequestHandler<CheckOutCommand, VisitResponse>
{
    private readonly IVisitRepository _visitRepository;

    public CheckOutCommandHandler(IVisitRepository visitRepository)
    {
        _visitRepository = visitRepository;
    }

public async Task<VisitResponse> Handle(CheckOutCommand request, CancellationToken cancellationToken)
    {
        var visit = await _visitRepository.GetByIdAsync(request.VisitId, cancellationToken);
        if (visit is null)
        {
            throw new KeyNotFoundException($"Posjeta sa id '{request.VisitId}' ne postoji.");
        }

        var user = await _visitRepository.GetUserByIdAsync(visit.UserId, cancellationToken);
        if (user is null)
        {
            throw new KeyNotFoundException($"Korisnik sa id '{visit.UserId}' ne postoji.");
        }

        if (visit.CheckOutTime.HasValue)
        {
            throw new InvalidOperationException("Korisnik je vec odjavljen iz teretane.");
        }

        visit.CheckOutTime = StrongholdTimeUtils.UtcNow;
        await _visitRepository.UpdateAsync(visit, cancellationToken);

        return new VisitResponse
        {
            Id = visit.Id,
            UserId = user.Id,
            Username = user.Username,
            FirstName = user.FirstName,
            LastName = user.LastName,
            CheckInTime = visit.CheckInTime,
            CheckOutTime = visit.CheckOutTime
        };
    }
    }

public class CheckOutCommandValidator : AbstractValidator<CheckOutCommand>
{
    public CheckOutCommandValidator()
    {
        RuleFor(x => x.VisitId).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }