using FluentValidation;

namespace Stronghold.Application.Features.Users.GetUsers;

public class GetUsersQueryValidator : AbstractValidator<GetUsersQuery>
{
    public GetUsersQueryValidator()
    {
        RuleFor(x => x.PageNumber).GreaterThan(0).WithMessage("Broj stranice mora biti veći od 0.");
        RuleFor(x => x.PageSize).InclusiveBetween(1, 100).WithMessage("Veličina stranice mora biti između 1 i 100.");
    }
}
