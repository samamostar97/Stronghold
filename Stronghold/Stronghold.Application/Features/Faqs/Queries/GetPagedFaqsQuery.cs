using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Faqs.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Faqs.Queries;

public class GetPagedFaqsQuery : IRequest<PagedResult<FaqResponse>>, IAuthorizeAdminOrGymMemberRequest
{
    public FaqFilter Filter { get; set; } = new();
}

public class GetPagedFaqsQueryHandler : IRequestHandler<GetPagedFaqsQuery, PagedResult<FaqResponse>>
{
    private readonly IFaqRepository _faqRepository;

    public GetPagedFaqsQueryHandler(IFaqRepository faqRepository)
    {
        _faqRepository = faqRepository;
    }

public async Task<PagedResult<FaqResponse>> Handle(GetPagedFaqsQuery request, CancellationToken cancellationToken)
    {
        var filter = request.Filter ?? new FaqFilter();
        var page = await _faqRepository.GetPagedAsync(filter, cancellationToken);

        return new PagedResult<FaqResponse>
        {
            Items = page.Items.Select(MapToResponse).ToList(),
            TotalCount = page.TotalCount,
            PageNumber = page.PageNumber
        };
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

public class GetPagedFaqsQueryValidator : AbstractValidator<GetPagedFaqsQuery>
{
    public GetPagedFaqsQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.Filter.PageNumber)
            .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.");

        RuleFor(x => x.Filter.PageSize)
            .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.")
            .LessThanOrEqualTo(100).WithMessage("{PropertyName} mora biti manje ili jednako dozvoljenoj vrijednosti.");

        RuleFor(x => x.Filter.Search)
            .MaximumLength(200).WithMessage("{PropertyName} ne smije imati vise od 200 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.Search));

        RuleFor(x => x.Filter.OrderBy)
            .MaximumLength(30).WithMessage("{PropertyName} ne smije imati vise od 30 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.OrderBy));

        RuleFor(x => x.Filter.OrderBy)
            .Must(BeValidOrderBy)
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.OrderBy))
            .WithMessage("Neispravna vrijednost za sortiranje.");
    }

private static bool BeValidOrderBy(string? orderBy)
    {
        var normalized = orderBy?.Trim().ToLowerInvariant();
        return normalized is "question" or "questiondesc" or "createdat" or "createdatdesc";
    }
    }