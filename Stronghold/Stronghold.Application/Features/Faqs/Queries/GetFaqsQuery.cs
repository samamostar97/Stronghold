using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Faqs.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Faqs.Queries;

public class GetFaqsQuery : IRequest<IReadOnlyList<FaqResponse>>, IAuthorizeAdminOrGymMemberRequest
{
    public FaqFilter Filter { get; set; } = new();
}

public class GetFaqsQueryHandler : IRequestHandler<GetFaqsQuery, IReadOnlyList<FaqResponse>>
{
    private readonly IFaqRepository _faqRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetFaqsQueryHandler(IFaqRepository faqRepository, ICurrentUserService currentUserService)
    {
        _faqRepository = faqRepository;
        _currentUserService = currentUserService;
    }

public async Task<IReadOnlyList<FaqResponse>> Handle(GetFaqsQuery request, CancellationToken cancellationToken)
    {
        var filter = request.Filter ?? new FaqFilter();
        filter.PageNumber = 1;
        filter.PageSize = int.MaxValue;
        var page = await _faqRepository.GetPagedAsync(filter, cancellationToken);
        return page.Items.Select(MapToResponse).ToList();
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

public class GetFaqsQueryValidator : AbstractValidator<GetFaqsQuery>
{
    public GetFaqsQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull().WithMessage("{PropertyName} je obavezno.");

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