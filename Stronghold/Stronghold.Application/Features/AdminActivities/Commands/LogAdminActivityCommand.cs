using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.AdminActivities.Commands;

public enum AdminActivityLogAction
{
    Add = 1,
    Delete = 2,
}

public class LogAdminActivityCommand : IRequest<Unit>
{
    public AdminActivityLogAction Action { get; set; }
    public string EntityType { get; set; } = string.Empty;
    public int EntityId { get; set; }
}

public class LogAdminActivityCommandHandler : IRequestHandler<LogAdminActivityCommand, Unit>
{
    private readonly IAdminActivityService _adminActivityService;
    private readonly ICurrentUserService _currentUserService;

    public LogAdminActivityCommandHandler(
        IAdminActivityService adminActivityService,
        ICurrentUserService currentUserService)
    {
        _adminActivityService = adminActivityService;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(LogAdminActivityCommand request, CancellationToken cancellationToken)
    {
        if (!_currentUserService.UserId.HasValue || !_currentUserService.IsInRole("Admin"))
        {
            return Unit.Value;
        }

        var adminUserId = _currentUserService.UserId.Value;
        var adminUsername = _currentUserService.Username ?? "admin";

        switch (request.Action)
        {
            case AdminActivityLogAction.Add:
                await _adminActivityService.LogAddAsync(adminUserId, adminUsername, request.EntityType, request.EntityId);
                break;

            case AdminActivityLogAction.Delete:
                await _adminActivityService.LogDeleteAsync(adminUserId, adminUsername, request.EntityType, request.EntityId);
                break;
        }

        return Unit.Value;
    }
}

public class LogAdminActivityCommandValidator : AbstractValidator<LogAdminActivityCommand>
{
    public LogAdminActivityCommandValidator()
    {
        RuleFor(x => x.Action)
            .IsInEnum().WithMessage("{PropertyName} mora imati dozvoljenu vrijednost.");

        RuleFor(x => x.EntityType)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.");

        RuleFor(x => x.EntityId)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
}
