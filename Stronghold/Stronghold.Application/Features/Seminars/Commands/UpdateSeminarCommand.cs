using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.Seminars.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Seminars.Commands;

public class UpdateSeminarCommand : IRequest<SeminarResponse>
{
    public int Id { get; set; }
    public string? Topic { get; set; }
    public string? SpeakerName { get; set; }
    public DateTime? EventDate { get; set; }
    public int? MaxCapacity { get; set; }
}

public class UpdateSeminarCommandHandler : IRequestHandler<UpdateSeminarCommand, SeminarResponse>
{
    private const string StatusActive = "active";
    private const string StatusCancelled = "cancelled";
    private const string StatusFinished = "finished";

    private readonly ISeminarRepository _seminarRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateSeminarCommandHandler(ISeminarRepository seminarRepository, ICurrentUserService currentUserService)
    {
        _seminarRepository = seminarRepository;
        _currentUserService = currentUserService;
    }

    public async Task<SeminarResponse> Handle(UpdateSeminarCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var seminar = await _seminarRepository.GetByIdAsync(request.Id, cancellationToken);
        if (seminar is null)
        {
            throw new KeyNotFoundException($"Seminar sa id '{request.Id}' ne postoji.");
        }

        var now = StrongholdTimeUtils.UtcNow;

        if (seminar.IsCancelled)
        {
            throw new InvalidOperationException("Nije moguce izmijeniti otkazan seminar.");
        }

        if (seminar.EventDate < now)
        {
            throw new InvalidOperationException("Nije moguce izmijeniti zavrsen seminar.");
        }

        var eventDate = request.EventDate.HasValue
            ? StrongholdTimeUtils.ToUtc(request.EventDate.Value)
            : seminar.EventDate;

        var topic = !string.IsNullOrWhiteSpace(request.Topic)
            ? request.Topic.Trim()
            : seminar.Topic;

        if (request.EventDate.HasValue && eventDate < now)
        {
            throw new ArgumentException("Nemoguce unijeti datum u proslosti.");
        }

        if (request.Topic is not null || request.EventDate.HasValue)
        {
            var exists = await _seminarRepository.ExistsByTopicAndDateAsync(
                topic,
                eventDate,
                seminar.Id,
                cancellationToken);

            if (exists)
            {
                throw new ConflictException("Seminar sa ovom temom vec postoji na odabranom datumu.");
            }
        }

        if (request.Topic is not null)
        {
            seminar.Topic = request.Topic.Trim();
        }

        if (request.SpeakerName is not null)
        {
            seminar.SpeakerName = request.SpeakerName.Trim();
        }

        if (request.EventDate.HasValue)
        {
            seminar.EventDate = eventDate;
        }

        if (request.MaxCapacity.HasValue)
        {
            var currentAttendees = await _seminarRepository.CountAttendeesAsync(seminar.Id, cancellationToken);
            if (request.MaxCapacity.Value < currentAttendees)
            {
                throw new ArgumentException(
                    $"Kapacitet ne moze biti manji od broja prijavljenih ucesnika ({currentAttendees}).");
            }

            seminar.MaxCapacity = request.MaxCapacity.Value;
        }

        await _seminarRepository.UpdateAsync(seminar, cancellationToken);

        var attendeeCount = await _seminarRepository.CountAttendeesAsync(seminar.Id, cancellationToken);
        return MapToResponse(seminar, attendeeCount, now);
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

public class UpdateSeminarCommandValidator : AbstractValidator<UpdateSeminarCommand>
{
    public UpdateSeminarCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);

        RuleFor(x => x.Topic)
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(100)
            .When(x => x.Topic is not null);

        RuleFor(x => x.SpeakerName)
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(100)
            .When(x => x.SpeakerName is not null);

        RuleFor(x => x.MaxCapacity)
            .InclusiveBetween(1, 10000)
            .When(x => x.MaxCapacity.HasValue);
    }
}
