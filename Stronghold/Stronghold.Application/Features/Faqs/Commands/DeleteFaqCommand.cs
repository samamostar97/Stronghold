using FluentValidation;
using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Faqs.Commands;

public class DeleteFaqCommand : IRequest<Unit>
{
    public int Id { get; set; }
}

public class DeleteFaqCommandHandler : IRequestHandler<DeleteFaqCommand, Unit>
{
    private readonly IFaqRepository _faqRepository;
    private readonly ICurrentUserService _currentUserService;

    public DeleteFaqCommandHandler(IFaqRepository faqRepository, ICurrentUserService currentUserService)
    {
        _faqRepository = faqRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteFaqCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var faq = await _faqRepository.GetByIdAsync(request.Id, cancellationToken);
        if (faq is null)
        {
            throw new KeyNotFoundException($"FAQ sa id '{request.Id}' ne postoji.");
        }

        await _faqRepository.DeleteAsync(faq, cancellationToken);
        return Unit.Value;
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

public class DeleteFaqCommandValidator : AbstractValidator<DeleteFaqCommand>
{
    public DeleteFaqCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
    }
}
