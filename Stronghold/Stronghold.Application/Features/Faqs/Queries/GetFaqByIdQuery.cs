using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Faqs.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Faqs.Queries;

public class GetFaqByIdQuery : IRequest<FaqResponse>
{
    public int Id { get; set; }
}

public class GetFaqByIdQueryHandler : IRequestHandler<GetFaqByIdQuery, FaqResponse>
{
    private readonly IFaqRepository _faqRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetFaqByIdQueryHandler(IFaqRepository faqRepository, ICurrentUserService currentUserService)
    {
        _faqRepository = faqRepository;
        _currentUserService = currentUserService;
    }

    public async Task<FaqResponse> Handle(GetFaqByIdQuery request, CancellationToken cancellationToken)
    {
        EnsureReadAccess();

        var faq = await _faqRepository.GetByIdAsync(request.Id, cancellationToken);
        if (faq is null)
        {
            throw new KeyNotFoundException($"FAQ sa id '{request.Id}' ne postoji.");
        }

        return MapToResponse(faq);
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

public class GetFaqByIdQueryValidator : AbstractValidator<GetFaqByIdQuery>
{
    public GetFaqByIdQueryValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
    }
}
