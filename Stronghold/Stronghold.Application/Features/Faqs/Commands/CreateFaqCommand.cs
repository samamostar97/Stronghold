using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Faqs.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Faqs.Commands;

public class CreateFaqCommand : IRequest<FaqResponse>, IAuthorizeAdminRequest
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
    }

public class CreateFaqCommandValidator : AbstractValidator<CreateFaqCommand>
{
    public CreateFaqCommandValidator()
    {
        RuleFor(x => x.Question)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(500).WithMessage("{PropertyName} ne smije imati vise od 500 karaktera.");

        RuleFor(x => x.Answer)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(2000).WithMessage("{PropertyName} ne smije imati vise od 2000 karaktera.");
    }
    }