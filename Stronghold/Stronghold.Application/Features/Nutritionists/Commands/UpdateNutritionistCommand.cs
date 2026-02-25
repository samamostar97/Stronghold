using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.Nutritionists.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Nutritionists.Commands;

public class UpdateNutritionistCommand : IRequest<NutritionistResponse>, IAuthorizeAdminRequest
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

    public UpdateNutritionistCommandHandler(
        INutritionistRepository nutritionistRepository)
    {
        _nutritionistRepository = nutritionistRepository;
    }

public async Task<NutritionistResponse> Handle(UpdateNutritionistCommand request, CancellationToken cancellationToken)
    {
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
    }

public class UpdateNutritionistCommandValidator : AbstractValidator<UpdateNutritionistCommand>
{
    public UpdateNutritionistCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");

        RuleFor(x => x.FirstName)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.")
            .When(x => x.FirstName is not null);

        RuleFor(x => x.LastName)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.")
            .When(x => x.LastName is not null);

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .EmailAddress().WithMessage("Unesite ispravnu email adresu.")
            .MinimumLength(5).WithMessage("{PropertyName} mora imati najmanje 5 karaktera.")
            .MaximumLength(255).WithMessage("{PropertyName} ne smije imati vise od 255 karaktera.")
            .When(x => x.Email is not null);

        RuleFor(x => x.PhoneNumber)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(9).WithMessage("{PropertyName} mora imati najmanje 9 karaktera.")
            .MaximumLength(20).WithMessage("{PropertyName} ne smije imati vise od 20 karaktera.")
            .Matches(@"^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$")
            .When(x => x.PhoneNumber is not null)
            .WithMessage("Broj telefona mora biti u formatu 061 123 456 ili +387 61 123 456.");
    }
    }