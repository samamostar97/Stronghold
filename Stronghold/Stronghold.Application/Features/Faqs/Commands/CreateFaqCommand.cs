using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Faqs.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Faqs.Commands;

public class CreateFaqCommand : IRequest<FaqResponse>
{
    public string Question { get; set; } = string.Empty;
    public string Answer { get; set; } = string.Empty;
}

public class CreateFaqCommandHandler : IRequestHandler<CreateFaqCommand, FaqResponse>
{
    private readonly IFaqRepository _faqRepository;
    private readonly ICurrentUserService _currentUserService;

    public CreateFaqCommandHandler(IFaqRepository faqRepository, ICurrentUserService currentUserService)
    {
        _faqRepository = faqRepository;
        _currentUserService = currentUserService;
    }

    public async Task<FaqResponse> Handle(CreateFaqCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var entity = new FAQ
        {
            Question = request.Question.Trim(),
            Answer = request.Answer.Trim()
        };

        await _faqRepository.AddAsync(entity, cancellationToken);

        return new FaqResponse
        {
            Id = entity.Id,
            Question = entity.Question,
            Answer = entity.Answer,
            CreatedAt = entity.CreatedAt
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

public class CreateFaqCommandValidator : AbstractValidator<CreateFaqCommand>
{
    public CreateFaqCommandValidator()
    {
        RuleFor(x => x.Question)
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(500);

        RuleFor(x => x.Answer)
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(2000);
    }
}
