using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Seminars.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Seminars.Queries;

public class GetUpcomingSeminarsQuery : IRequest<IReadOnlyList<UserSeminarResponse>>
{
}

public class GetUpcomingSeminarsQueryHandler : IRequestHandler<GetUpcomingSeminarsQuery, IReadOnlyList<UserSeminarResponse>>
{
    private const string StatusActive = "active";

    private readonly ISeminarRepository _seminarRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetUpcomingSeminarsQueryHandler(ISeminarRepository seminarRepository, ICurrentUserService currentUserService)
    {
        _seminarRepository = seminarRepository;
        _currentUserService = currentUserService;
    }

    public async Task<IReadOnlyList<UserSeminarResponse>> Handle(GetUpcomingSeminarsQuery request, CancellationToken cancellationToken)
    {
        var userId = EnsureGymMemberAccess();
        var now = StrongholdTimeUtils.UtcNow;

        var seminars = await _seminarRepository.GetUpcomingSeminarsAsync(now, cancellationToken);
        if (!seminars.Any())
        {
            return Array.Empty<UserSeminarResponse>();
        }

        var seminarIds = seminars.Select(x => x.Id).ToList();
        var attendeeCounts = await _seminarRepository.GetAttendeeCountsAsync(seminarIds, cancellationToken);
        var attendingIds = await _seminarRepository.GetUserAttendingSeminarIdsAsync(userId, seminarIds, cancellationToken);
        var attendingSet = attendingIds.ToHashSet();

        return seminars.Select(x =>
        {
            var currentAttendees = attendeeCounts.GetValueOrDefault(x.Id, 0);
            return new UserSeminarResponse
            {
                Id = x.Id,
                Topic = x.Topic,
                SpeakerName = x.SpeakerName,
                EventDate = x.EventDate,
                IsAttending = attendingSet.Contains(x.Id),
                MaxCapacity = x.MaxCapacity,
                CurrentAttendees = currentAttendees,
                IsFull = currentAttendees >= x.MaxCapacity,
                IsCancelled = x.IsCancelled,
                Status = StatusActive
            };
        }).ToList();
    }

    private int EnsureGymMemberAccess()
    {
        if (!_currentUserService.IsAuthenticated || !_currentUserService.UserId.HasValue)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("GymMember"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }

        return _currentUserService.UserId.Value;
    }
}

public class GetUpcomingSeminarsQueryValidator : AbstractValidator<GetUpcomingSeminarsQuery>
{
}
