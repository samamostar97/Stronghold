using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Seminars.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Seminars.Queries;

public class GetSeminarAttendeesQuery : IRequest<IReadOnlyList<SeminarAttendeeResponse>>
{
    public int SeminarId { get; set; }
}

public class GetSeminarAttendeesQueryHandler : IRequestHandler<GetSeminarAttendeesQuery, IReadOnlyList<SeminarAttendeeResponse>>
{
    private readonly ISeminarRepository _seminarRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetSeminarAttendeesQueryHandler(ISeminarRepository seminarRepository, ICurrentUserService currentUserService)
    {
        _seminarRepository = seminarRepository;
        _currentUserService = currentUserService;
    }

    public async Task<IReadOnlyList<SeminarAttendeeResponse>> Handle(GetSeminarAttendeesQuery request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var seminarExists = await _seminarRepository.ExistsAsync(request.SeminarId, cancellationToken);
        if (!seminarExists)
        {
            throw new KeyNotFoundException("Seminar ne postoji.");
        }

        var attendees = await _seminarRepository.GetAttendeesBySeminarIdAsync(
            request.SeminarId,
            includeUser: true,
            cancellationToken: cancellationToken);

        return attendees.Select(x => new SeminarAttendeeResponse
        {
            UserId = x.UserId,
            UserName = $"{x.User.FirstName} {x.User.LastName}",
            RegisteredAt = x.RegisteredAt
        }).ToList();
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

public class GetSeminarAttendeesQueryValidator : AbstractValidator<GetSeminarAttendeesQuery>
{
    public GetSeminarAttendeesQueryValidator()
    {
        RuleFor(x => x.SeminarId).GreaterThan(0);
    }
}
