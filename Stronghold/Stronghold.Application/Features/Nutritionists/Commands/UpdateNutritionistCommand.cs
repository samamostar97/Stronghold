using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.Nutritionists.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Nutritionists.Commands;

public class UpdateNutritionistCommand : IRequest<NutritionistResponse>
{
    public int Id { get; set; }
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
    public string? Email { get; set; }
    public string? PhoneNumber { get; set; }
}

public class UpdateNutritionistCommandHandler : IRequestHandler<UpdateNutritionistCommand, NutritionistResponse>
{
    private readonly INutritionistRepository _nutritionistRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateNutritionistCommandHandler(
        INutritionistRepository nutritionistRepository,
        ICurrentUserService currentUserService)
    {
        _nutritionistRepository = nutritionistRepository;
        _currentUserService = currentUserService;
    }

    public async Task<NutritionistResponse> Handle(UpdateNutritionistCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var nutritionist = await _nutritionistRepository.GetByIdAsync(request.Id, cancellationToken);
        if (nutritionist is null)
        {
            throw new KeyNotFoundException($"Nutricionista sa id '{request.Id}' ne postoji.");
        }

        if (!string.IsNullOrWhiteSpace(request.FirstName))
        {
            nutritionist.FirstName = request.FirstName.Trim();
        }

        if (!string.IsNullOrWhiteSpace(request.LastName))
        {
            nutritionist.LastName = request.LastName.Trim();
        }

        if (!string.IsNullOrWhiteSpace(request.Email))
        {
            var emailExists = await _nutritionistRepository.ExistsByEmailAsync(
                request.Email,
                nutritionist.Id,
                cancellationToken);
            if (emailExists)
            {
                throw new ConflictException("Email je vec zauzet.");
            }

            nutritionist.Email = request.Email.Trim();
        }

        if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
        {
            var phoneExists = await _nutritionistRepository.ExistsByPhoneAsync(
                request.PhoneNumber,
                nutritionist.Id,
                cancellationToken);
            if (phoneExists)
            {
                throw new ConflictException("Nutricionista sa ovim brojem telefona vec postoji.");
            }

            nutritionist.PhoneNumber = request.PhoneNumber.Trim();
        }

        await _nutritionistRepository.UpdateAsync(nutritionist, cancellationToken);

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

    private void EnsureAdminAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("Admin"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }
    }
}

public class UpdateNutritionistCommandValidator : AbstractValidator<UpdateNutritionistCommand>
{
    public UpdateNutritionistCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0);

        RuleFor(x => x.FirstName)
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(100)
            .When(x => x.FirstName is not null);

        RuleFor(x => x.LastName)
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(100)
            .When(x => x.LastName is not null);

        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress()
            .MinimumLength(5)
            .MaximumLength(255)
            .When(x => x.Email is not null);

        RuleFor(x => x.PhoneNumber)
            .NotEmpty()
            .MinimumLength(9)
            .MaximumLength(20)
            .Matches(@"^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$")
            .When(x => x.PhoneNumber is not null)
            .WithMessage("Broj telefona mora biti u formatu 061 123 456 ili +387 61 123 456.");
    }
}
