using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.Trainers.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Trainers.Commands;

public class UpdateTrainerCommand : IRequest<TrainerResponse>
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
        EnsureAdminAccess();

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

public class UpdateTrainerCommandValidator : AbstractValidator<UpdateTrainerCommand>
{
    public UpdateTrainerCommandValidator()
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
