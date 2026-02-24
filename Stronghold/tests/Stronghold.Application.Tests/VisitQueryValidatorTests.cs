using Stronghold.Application.Features.Visits.DTOs;
using Stronghold.Application.Features.Visits.Queries;

namespace Stronghold.Application.Tests;

public class VisitQueryValidatorTests
{
    [Fact]
    public void GetCurrentVisitorsValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetCurrentVisitorsQueryValidator();

        var result = validator.Validate(new GetCurrentVisitorsQuery
        {
            Filter = new VisitFilter
            {
                OrderBy = "legacy"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetCurrentVisitorsValidator_ShouldPass_WhenOrderByIsValid()
    {
        var validator = new GetCurrentVisitorsQueryValidator();

        var result = validator.Validate(new GetCurrentVisitorsQuery
        {
            Filter = new VisitFilter
            {
                OrderBy = "checkindesc",
                PageNumber = 1,
                PageSize = 10
            }
        });

        Assert.True(result.IsValid);
    }

    [Fact]
    public void GetCurrentVisitorsValidator_ShouldFail_WhenPageSizeIsTooLarge()
    {
        var validator = new GetCurrentVisitorsQueryValidator();

        var result = validator.Validate(new GetCurrentVisitorsQuery
        {
            Filter = new VisitFilter
            {
                PageSize = 101
            }
        });

        Assert.False(result.IsValid);
    }
}
