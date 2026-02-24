using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Nutritionists.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Nutritionists.Queries;

public class GetNutritionistByIdQuery : IRequest<NutritionistResponse>
{
    public int Id { get; set; }
}

public class GetNutritionistByIdQueryHandler : IRequestHandler<GetNutritionistByIdQuery, NutritionistResponse>
{
    private readonly INutritionistRepository _nutritionistRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetNutritionistByIdQueryHandler(
        INutritionistRepository nutritionistRepository,
        ICurrentUserService currentUserService)
    {
        _nutritionistRepository = nutritionistRepository;
        _currentUserService = currentUserService;
    }

    public async Task<NutritionistResponse> Handle(GetNutritionistByIdQuery request, CancellationToken cancellationToken)
    {
        EnsureReadAccess();

        var nutritionist = await _nutritionistRepository.GetByIdAsync(request.Id, cancellationToken);
        if (nutritionist is null)
        {
            throw new KeyNotFoundException($"Nutricionista sa id '{request.Id}' ne postoji.");
        }

        return MapToResponse(nutritionist);
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

    private static NutritionistResponse MapToResponse(Nutritionist nutritionist)
    {
        return new NutritionistResponse
        {
            Id = nutritionist.Id,
            FirstName = nutritionist.FirstName,
            LastName = nutritionist.LastName,
            Email = nutritionist.Email,
            PhoneNumber = nutritionist.PhoneNumber,
            CreatedAt = nutritionist.CreatedAt
        };
    }
}

public class GetNutritionistByIdQueryValidator : AbstractValidator<GetNutritionistByIdQuery>
{
    public GetNutritionistByIdQueryValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0);
    }
}
