using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Seminars.DeleteSeminar;

public class DeleteSeminarCommandHandler : IRequestHandler<DeleteSeminarCommand, Unit>
{
    private readonly ISeminarRepository _seminarRepository;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;

    public DeleteSeminarCommandHandler(
        ISeminarRepository seminarRepository,
        IAuditService auditService,
        ICurrentUserService currentUserService)
    {
        _seminarRepository = seminarRepository;
        _auditService = auditService;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteSeminarCommand request, CancellationToken cancellationToken)
    {
        var seminar = await _seminarRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Seminar", request.Id);

        await _auditService.LogDeleteAsync(_currentUserService.UserId, "Seminar", seminar.Id, seminar);

        seminar.IsDeleted = true;
        seminar.DeletedAt = DateTime.UtcNow;

        await _seminarRepository.SaveChangesAsync();

        return Unit.Value;
    }
}
