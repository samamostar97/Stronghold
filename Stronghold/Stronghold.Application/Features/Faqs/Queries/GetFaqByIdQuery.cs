using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Faqs.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Faqs.Queries;

public class GetFaqByIdQuery : IRequest<FaqResponse>, IAuthorizeAdminOrGymMemberRequest
{
    public int Id { get; set; }
}

public class GetFaqByIdQueryHandler : IRequestHandler<GetFaqByIdQuery, FaqResponse>
{
    private readonly IFaqRepository _faqRepository;

    public GetFaqByIdQueryHandler(IFaqRepository faqRepository)
    {
        _faqRepository = faqRepository;
    }

public async Task<FaqResponse> Handle(GetFaqByIdQuery request, CancellationToken cancellationToken)
    {
        var faq = await _faqRepository.GetByIdAsync(request.Id, cancellationToken);
        if (faq is null)
        {
            throw new KeyNotFoundException($"FAQ sa id '{request.Id}' ne postoji.");
        }

        return MapToResponse(faq);
    }

private static FaqResponse MapToResponse(FAQ faq)
    {
        return new FaqResponse
        {
            Id = faq.Id,
            Question = faq.Question,
            Answer = faq.Answer,
            CreatedAt = faq.CreatedAt
        };
    }
    }

public class GetFaqByIdQueryValidator : AbstractValidator<GetFaqByIdQuery>
{
    public GetFaqByIdQueryValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }