using FluentValidation;

namespace Stronghold.Application.Features.Gamification.GetLeaderboard;

public class GetLeaderboardQueryValidator : AbstractValidator<GetLeaderboardQuery>
{
    public GetLeaderboardQueryValidator()
    {
        RuleFor(x => x.PageNumber)
            .GreaterThanOrEqualTo(1).WithMessage("Broj stranice mora biti najmanje 1.");

        RuleFor(x => x.PageSize)
            .InclusiveBetween(1, 100).WithMessage("Veličina stranice mora biti između 1 i 100.");
    }
}
