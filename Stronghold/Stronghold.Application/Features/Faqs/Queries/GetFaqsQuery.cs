using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Faqs.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Faqs.Queries;

public class GetFaqsQuery : IRequest<IReadOnlyList<FaqResponse>>
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
        EnsureReadAccess();

        var filter = request.Filter ?? new FaqFilter();
        filter.PageNumber = 1;
        filter.PageSize = int.MaxValue;
        var page = await _faqRepository.GetPagedAsync(filter, cancellationToken);
        return page.Items.Select(MapToResponse).ToList();
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

public class GetFaqsQueryValidator : AbstractValidator<GetFaqsQuery>
{
    public GetFaqsQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull();

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
