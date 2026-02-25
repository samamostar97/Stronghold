using FluentValidation;
using MediatR;
using Stronghold.Application.Features.AdminActivities.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.AdminActivities.Commands;

public class UndoAdminActivityCommand : IRequest<AdminActivityResponse>, IAuthorizeAdminRequest
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
        var adminUserId = _currentUserService.UserId!.Value;
        return await _adminActivityService.UndoAsync(request.Id, adminUserId);
    }
    }

public class UndoAdminActivityCommandValidator : AbstractValidator<UndoAdminActivityCommand>
{
    public UndoAdminActivityCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }