using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.Trainers.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Trainers.Commands;

public class UpdateTrainerCommand : IRequest<TrainerResponse>, IAuthorizeAdminRequest
{
    public int Id { get; set; }

public string? FirstName { get; set; }

public string? LastName { get; set; }

public string? Email { get; set; }

public string? PhoneNumber { get; set; }
}

public class UpdateTrainerCommandHandler : IRequestHandler<UpdateTrainerCommand, TrainerResponse>
{
    private readonly ITrainerRepository _trainerRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateTrainerCommandHandler(ITrainerRepository trainerRepository, ICurrentUserService currentUserService)
    {
        _trainerRepository = trainerRepository;
        _currentUserService = currentUserService;
    }

public async Task<TrainerResponse> Handle(UpdateTrainerCommand request, CancellationToken cancellationToken)
    {
        var trainer = await _trainerRepository.GetByIdAsync(request.Id, cancellationToken);
        if (trainer is null)
        {
            throw new KeyNotFoundException($"Trener sa id '{request.Id}' ne postoji.");
        }

        if (!string.IsNullOrWhiteSpace(request.FirstName))
        {
            trainer.FirstName = request.FirstName.Trim();
        }

        if (!string.IsNullOrWhiteSpace(request.LastName))
        {
            trainer.LastName = request.LastName.Trim();
        }

        if (!string.IsNullOrWhiteSpace(request.Email))
        {
            var emailExists = await _trainerRepository.ExistsByEmailAsync(request.Email, trainer.Id, cancellationToken);
            if (emailExists)
            {
                throw new ConflictException("Email je vec zauzet.");
            }

            trainer.Email = request.Email.Trim();
        }

        if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
        {
            var phoneExists = await _trainerRepository.ExistsByPhoneAsync(request.PhoneNumber, trainer.Id, cancellationToken);
            if (phoneExists)
            {
                throw new ConflictException("Trener sa ovim brojem telefona vec postoji.");
            }

            trainer.PhoneNumber = request.PhoneNumber.Trim();
        }

        await _trainerRepository.UpdateAsync(trainer, cancellationToken);

        return new TrainerResponse
        {
            Id = trainer.Id,
            FirstName = trainer.FirstName,
            LastName = trainer.LastName,
            Email = trainer.Email,
            PhoneNumber = trainer.PhoneNumber,
            CreatedAt = trainer.CreatedAt
        };
    }
    }

public class UpdateTrainerCommandValidator : AbstractValidator<UpdateTrainerCommand>
{
    public UpdateTrainerCommandValidator()
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