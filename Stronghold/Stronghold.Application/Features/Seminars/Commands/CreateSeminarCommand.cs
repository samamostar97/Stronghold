using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.Seminars.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Seminars.Commands;

public class CreateSeminarCommand : IRequest<SeminarResponse>
{
    public string Topic { get; set; } = string.Empty;
    public string SpeakerName { get; set; } = string.Empty;
    public DateTime EventDate { get; set; }
    public int MaxCapacity { get; set; }
}

public class CreateSeminarCommandHandler : IRequestHandler<CreateSeminarCommand, SeminarResponse>
{
    private const string StatusActive = "active";

    private readonly ISeminarRepository _seminarRepository;
    private readonly ICurrentUserService _currentUserService;

    public CreateSeminarCommandHandler(ISeminarRepository seminarRepository, ICurrentUserService currentUserService)
    {
        _seminarRepository = seminarRepository;
        _currentUserService = currentUserService;
    }

    public async Task<SeminarResponse> Handle(CreateSeminarCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var topic = request.Topic.Trim();
        var speakerName = request.SpeakerName.Trim();
        var normalizedEventDate = StrongholdTimeUtils.ToUtc(request.EventDate);

        var exists = await _seminarRepository.ExistsByTopicAndDateAsync(
            topic,
            normalizedEventDate,
            cancellationToken: cancellationToken);

        if (exists)
        {
            throw new ConflictException("Seminar sa ovom temom na odabrani datum vec postoji.");
        }

        if (normalizedEventDate < StrongholdTimeUtils.UtcNow)
        {
            throw new ArgumentException("Nemoguce unijeti datum u proslosti.");
        }

        var entity = new Seminar
        {
            Topic = topic,
            SpeakerName = speakerName,
            EventDate = normalizedEventDate,
            MaxCapacity = request.MaxCapacity
        };

        await _seminarRepository.AddAsync(entity, cancellationToken);

        return new SeminarResponse
        {
            Id = entity.Id,
            Topic = entity.Topic,
            SpeakerName = entity.SpeakerName,
            EventDate = entity.EventDate,
            MaxCapacity = entity.MaxCapacity,
            CurrentAttendees = 0,
            IsCancelled = entity.IsCancelled,
            Status = StatusActive
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

public class CreateSeminarCommandValidator : AbstractValidator<CreateSeminarCommand>
{
    public CreateSeminarCommandValidator()
    {
        RuleFor(x => x.Topic)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.");

        RuleFor(x => x.SpeakerName)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.");

        RuleFor(x => x.EventDate)
            .Must(x => x != default)
            .WithMessage("Datum seminara je obavezan.");

        RuleFor(x => x.MaxCapacity)
            .InclusiveBetween(1, 10000).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");
    }
}

