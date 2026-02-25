using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Nutritionists.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Nutritionists.Queries;

public class GetNutritionistByIdQuery : IRequest<NutritionistResponse>, IAuthorizeAdminOrGymMemberRequest
{
    public int Id { get; set; }
}

public class GetNutritionistByIdQueryHandler : IRequestHandler<GetNutritionistByIdQuery, NutritionistResponse>
{
    private readonly INutritionistRepository _nutritionistRepository;

    public GetNutritionistByIdQueryHandler(
        INutritionistRepository nutritionistRepository)
    {
        _nutritionistRepository = nutritionistRepository;
    }

public async Task<NutritionistResponse> Handle(GetNutritionistByIdQuery request, CancellationToken cancellationToken)
    {
        var nutritionist = await _nutritionistRepository.GetByIdAsync(request.Id, cancellationToken);
        if (nutritionist is null)
        {
            throw new KeyNotFoundException($"Nutricionista sa id '{request.Id}' ne postoji.");
        }

        return MapToResponse(nutritionist);
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
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }