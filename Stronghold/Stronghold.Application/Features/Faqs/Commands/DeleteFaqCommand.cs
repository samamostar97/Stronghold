using FluentValidation;
using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Faqs.Commands;

public class DeleteFaqCommand : IRequest<Unit>, IAuthorizeAdminRequest
{
    public int Id { get; set; }
}

public class DeleteFaqCommandHandler : IRequestHandler<DeleteFaqCommand, Unit>
{
    private readonly IFaqRepository _faqRepository;

    public DeleteFaqCommandHandler(IFaqRepository faqRepository)
    {
        _faqRepository = faqRepository;
    }

public async Task<Unit> Handle(DeleteFaqCommand request, CancellationToken cancellationToken)
    {
        var faq = await _faqRepository.GetByIdAsync(request.Id, cancellationToken);
        if (faq is null)
        {
            throw new KeyNotFoundException($"FAQ sa id '{request.Id}' ne postoji.");
        }

        await _faqRepository.DeleteAsync(faq, cancellationToken);
        return Unit.Value;
    }
    }

public class DeleteFaqCommandValidator : AbstractValidator<DeleteFaqCommand>
{
    public DeleteFaqCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }