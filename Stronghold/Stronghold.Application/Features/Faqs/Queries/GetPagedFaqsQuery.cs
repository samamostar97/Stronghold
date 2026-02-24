using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Faqs.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Faqs.Queries;

public class GetPagedFaqsQuery : IRequest<PagedResult<FaqResponse>>
{
    public FaqFilter Filter { get; set; } = new();
}

public class GetPagedFaqsQueryHandler : IRequestHandler<GetPagedFaqsQuery, PagedResult<FaqResponse>>
{
    private readonly IFaqRepository _faqRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetPagedFaqsQueryHandler(IFaqRepository faqRepository, ICurrentUserService currentUserService)
    {
        _faqRepository = faqRepository;
        _currentUserService = currentUserService;
    }

    public async Task<PagedResult<FaqResponse>> Handle(GetPagedFaqsQuery request, CancellationToken cancellationToken)
    {
        EnsureReadAccess();

        var filter = request.Filter ?? new FaqFilter();
        var page = await _faqRepository.GetPagedAsync(filter, cancellationToken);

        return new PagedResult<FaqResponse>
        {
            Items = page.Items.Select(MapToResponse).ToList(),
            TotalCount = page.TotalCount,
            PageNumber = page.PageNumber
        };
    }

    private void EnsureReadAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("Admin") && !_currentUserService.IsInRole("GymMember"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }
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
        RuleFor(x => x.Filter).NotNull();

        RuleFor(x => x.Filter.PageNumber)
            .GreaterThanOrEqualTo(1);

        RuleFor(x => x.Filter.PageSize)
            .GreaterThanOrEqualTo(1)
            .LessThanOrEqualTo(100);

        RuleFor(x => x.Filter.Search)
            .MaximumLength(200)
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.Search));

        RuleFor(x => x.Filter.OrderBy)
            .MaximumLength(30)
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
