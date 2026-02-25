using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Seminars.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Seminars.Queries;

public class GetSeminarsQuery : IRequest<IReadOnlyList<SeminarResponse>>, IAuthorizeAdminOrGymMemberRequest
{
    public SeminarFilter Filter { get; set; } = new();
}

public class GetSeminarsQueryHandler : IRequestHandler<GetSeminarsQuery, IReadOnlyList<SeminarResponse>>
{
    private const string StatusActive = "active";
    private const string StatusCancelled = "cancelled";
    private const string StatusFinished = "finished";

    private readonly ISeminarRepository _seminarRepository;

    public GetSeminarsQueryHandler(ISeminarRepository seminarRepository)
    {
        _seminarRepository = seminarRepository;
    }

public async Task<IReadOnlyList<SeminarResponse>> Handle(GetSeminarsQuery request, CancellationToken cancellationToken)
    {
        var filter = request.Filter ?? new SeminarFilter();
        filter.PageNumber = 1;
        filter.PageSize = int.MaxValue;

        var page = await _seminarRepository.GetPagedAsync(filter, cancellationToken);
        var ids = page.Items.Select(x => x.Id).ToList();
        var attendeeCounts = await _seminarRepository.GetAttendeeCountsAsync(ids, cancellationToken);
        var now = StrongholdTimeUtils.UtcNow;

        return page.Items.Select(x => MapToResponse(x, attendeeCounts.GetValueOrDefault(x.Id, 0), now)).ToList();
    }

private static SeminarResponse MapToResponse(Seminar seminar, int attendeeCount, DateTime nowUtc)
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

public class GetSeminarsQueryValidator : AbstractValidator<GetSeminarsQuery>
{
    public GetSeminarsQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.Filter.Search)
            .MaximumLength(200).WithMessage("{PropertyName} ne smije imati vise od 200 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.Search));

        RuleFor(x => x.Filter.OrderBy)
            .MaximumLength(30).WithMessage("{PropertyName} ne smije imati vise od 30 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.OrderBy));

        RuleFor(x => x.Filter.OrderBy)
            .Must(BeValidOrderBy)
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.OrderBy))
            .WithMessage("Neispravna vrijednost za sortiranje.");

        RuleFor(x => x.Filter.Status)
            .Must(BeValidStatus)
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.Status))
            .WithMessage("Status mora biti active, cancelled ili finished.");
    }

private static bool BeValidStatus(string? status)
    {
        if (string.IsNullOrWhiteSpace(status))
        {
            return true;
        }

        var value = status.Trim().ToLowerInvariant();
        return value is "active" or "cancelled" or "finished";
    }

private static bool BeValidOrderBy(string? orderBy)
    {
        var value = orderBy?.Trim().ToLowerInvariant();
        return value is
            "topic" or
            "topicdesc" or
            "speakername" or
            "speakernamedesc" or
            "eventdate" or
            "eventdatedesc" or
            "maxcapacity" or
            "maxcapacitydesc";
    }
    }