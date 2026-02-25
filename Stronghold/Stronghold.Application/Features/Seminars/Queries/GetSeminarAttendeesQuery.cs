using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Seminars.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Seminars.Queries;

public class GetSeminarAttendeesQuery : IRequest<IReadOnlyList<SeminarAttendeeResponse>>, IAuthorizeAdminRequest
{
    public int SeminarId { get; set; }
}

public class GetSeminarAttendeesQueryHandler : IRequestHandler<GetSeminarAttendeesQuery, IReadOnlyList<SeminarAttendeeResponse>>
{
    private readonly ISeminarRepository _seminarRepository;

    public GetSeminarAttendeesQueryHandler(ISeminarRepository seminarRepository)
    {
        _seminarRepository = seminarRepository;
    }

public async Task<IReadOnlyList<SeminarAttendeeResponse>> Handle(GetSeminarAttendeesQuery request, CancellationToken cancellationToken)
    {
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
    }

public class GetSeminarAttendeesQueryValidator : AbstractValidator<GetSeminarAttendeesQuery>
{
    public GetSeminarAttendeesQueryValidator()
    {
        RuleFor(x => x.SeminarId).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }