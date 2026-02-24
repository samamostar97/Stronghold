using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Seminars.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Seminars.Queries;

public class GetSeminarByIdQuery : IRequest<SeminarResponse>
{
    public int Id { get; set; }
}

public class GetSeminarByIdQueryHandler : IRequestHandler<GetSeminarByIdQuery, SeminarResponse>
{
    private const string StatusActive = "active";
    private const string StatusCancelled = "cancelled";
    private const string StatusFinished = "finished";

    private readonly ISeminarRepository _seminarRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetSeminarByIdQueryHandler(ISeminarRepository seminarRepository, ICurrentUserService currentUserService)
    {
        _seminarRepository = seminarRepository;
        _currentUserService = currentUserService;
    }

    public async Task<SeminarResponse> Handle(GetSeminarByIdQuery request, CancellationToken cancellationToken)
    {
        EnsureReadAccess();

        var seminar = await _seminarRepository.GetByIdAsync(request.Id, cancellationToken);
        if (seminar is null)
        {
            throw new KeyNotFoundException($"Seminar sa id '{request.Id}' ne postoji.");
        }

        var attendeeCount = await _seminarRepository.CountAttendeesAsync(seminar.Id, cancellationToken);
        return MapToResponse(seminar, attendeeCount, StrongholdTimeUtils.UtcNow);
    }

    private void EnsureReadAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("Admin") && !_currentUserService.IsInRole("GymMember"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }
    }

    private static SeminarResponse MapToResponse(Core.Entities.Seminar seminar, int attendeeCount, DateTime nowUtc)
    {
        return new SeminarResponse
        {
            Id = seminar.Id,
            Topic = seminar.Topic,
            SpeakerName = seminar.SpeakerName,
            EventDate = seminar.EventDate,
            MaxCapacity = seminar.MaxCapacity,
            CurrentAttendees = attendeeCount,
            IsCancelled = seminar.IsCancelled,
            Status = ResolveStatus(seminar.EventDate, seminar.IsCancelled, nowUtc)
        };
    }

    private static string ResolveStatus(DateTime eventDate, bool isCancelled, DateTime nowUtc)
    {
        if (isCancelled)
        {
            return StatusCancelled;
        }

        return eventDate <= nowUtc ? StatusFinished : StatusActive;
    }
}

public class GetSeminarByIdQueryValidator : AbstractValidator<GetSeminarByIdQuery>
{
    public GetSeminarByIdQueryValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
    }
}
