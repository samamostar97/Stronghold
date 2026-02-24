using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.Trainers.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Trainers.Commands;

public class CreateTrainerCommand : IRequest<TrainerResponse>
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
}

public class CreateTrainerCommandHandler : IRequestHandler<CreateTrainerCommand, TrainerResponse>
{
    private readonly ITrainerRepository _trainerRepository;
    private readonly ICurrentUserService _currentUserService;

    public CreateTrainerCommandHandler(ITrainerRepository trainerRepository, ICurrentUserService currentUserService)
    {
        _trainerRepository = trainerRepository;
        _currentUserService = currentUserService;
    }

    public async Task<TrainerResponse> Handle(CreateTrainerCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var emailExists = await _trainerRepository.ExistsByEmailAsync(request.Email, cancellationToken: cancellationToken);
        if (emailExists)
        {
            throw new ConflictException("Email je vec zauzet.");
        }

        var phoneExists = await _trainerRepository.ExistsByPhoneAsync(request.PhoneNumber, cancellationToken: cancellationToken);
        if (phoneExists)
        {
            throw new ConflictException("Trener sa ovim brojem telefona vec postoji.");
        }

        var entity = new Trainer
        {
            FirstName = request.FirstName.Trim(),
            LastName = request.LastName.Trim(),
            Email = request.Email.Trim(),
            PhoneNumber = request.PhoneNumber.Trim()
        };

        await _trainerRepository.AddAsync(entity, cancellationToken);

        return new TrainerResponse
        {
            Id = entity.Id,
            FirstName = entity.FirstName,
            LastName = entity.LastName,
            Email = entity.Email,
            PhoneNumber = entity.PhoneNumber,
            CreatedAt = entity.CreatedAt
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

public class CreateTrainerCommandValidator : AbstractValidator<CreateTrainerCommand>
{
    public CreateTrainerCommandValidator()
    {
        RuleFor(x => x.FirstName)
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(100);

        RuleFor(x => x.LastName)
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(100);

        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress()
            .MinimumLength(5)
            .MaximumLength(255);

        RuleFor(x => x.PhoneNumber)
            .NotEmpty()
            .MinimumLength(9)
            .MaximumLength(20)
            .Matches(@"^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$")
            .WithMessage("Broj telefona mora biti u formatu 061 123 456 ili +387 61 123 456.");
    }
}
