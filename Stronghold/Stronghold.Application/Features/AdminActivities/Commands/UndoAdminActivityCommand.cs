using FluentValidation;
using MediatR;
using Stronghold.Application.Features.AdminActivities.DTOs;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.AdminActivities.Commands;

public class UndoAdminActivityCommand : IRequest<AdminActivityResponse>
{
    public int Id { get; set; }
}

public class UndoAdminActivityCommandHandler : IRequestHandler<UndoAdminActivityCommand, AdminActivityResponse>
{
    private readonly IAdminActivityService _adminActivityService;
    private readonly ICurrentUserService _currentUserService;

    public UndoAdminActivityCommandHandler(
        IAdminActivityService adminActivityService,
        ICurrentUserService currentUserService)
    {
        _adminActivityService = adminActivityService;
        _currentUserService = currentUserService;
    }

    public async Task<AdminActivityResponse> Handle(UndoAdminActivityCommand request, CancellationToken cancellationToken)
    {
        var adminUserId = EnsureAdminAccess();
        return await _adminActivityService.UndoAsync(request.Id, adminUserId);
    }

    private int EnsureAdminAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("Admin"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }

        return _currentUserService.UserId.Value;
    }
}

public class UndoAdminActivityCommandValidator : AbstractValidator<UndoAdminActivityCommand>
{
    public UndoAdminActivityCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0);
    }
}
