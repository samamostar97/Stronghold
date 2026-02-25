using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Faqs.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Faqs.Commands;

public class UpdateFaqCommand : IRequest<FaqResponse>, IAuthorizeAdminRequest
{
    public int Id { get; set; }

public string? Question { get; set; }

public string? Answer { get; set; }
}

public class UpdateFaqCommandHandler : IRequestHandler<UpdateFaqCommand, FaqResponse>
{
    private readonly IFaqRepository _faqRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateFaqCommandHandler(IFaqRepository faqRepository, ICurrentUserService currentUserService)
    {
        _faqRepository = faqRepository;
        _currentUserService = currentUserService;
    }

public async Task<FaqResponse> Handle(UpdateFaqCommand request, CancellationToken cancellationToken)
    {
        var faq = await _faqRepository.GetByIdAsync(request.Id, cancellationToken);
        if (faq is null)
        {
            throw new KeyNotFoundException($"FAQ sa id '{request.Id}' ne postoji.");
        }

        if (!string.IsNullOrWhiteSpace(request.Question))
        {
            faq.Question = request.Question.Trim();
        }

        if (!string.IsNullOrWhiteSpace(request.Answer))
        {
            faq.Answer = request.Answer.Trim();
        }

        await _faqRepository.UpdateAsync(faq, cancellationToken);

        return new FaqResponse
        {
            Id = faq.Id,
            Question = faq.Question,
            Answer = faq.Answer,
            CreatedAt = faq.CreatedAt
        };
    }
    }

public class UpdateFaqCommandValidator : AbstractValidator<UpdateFaqCommand>
{
    public UpdateFaqCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");

        RuleFor(x => x.Question)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(500).WithMessage("{PropertyName} ne smije imati vise od 500 karaktera.")
            .When(x => x.Question is not null);

        RuleFor(x => x.Answer)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(2000).WithMessage("{PropertyName} ne smije imati vise od 2000 karaktera.")
            .When(x => x.Answer is not null);
    }
    }