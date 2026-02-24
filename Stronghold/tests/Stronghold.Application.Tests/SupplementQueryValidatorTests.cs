using Stronghold.Application.Features.Supplements.DTOs;
using Stronghold.Application.Features.Supplements.Queries;

namespace Stronghold.Application.Tests;

public class SupplementQueryValidatorTests
{
    [Fact]
    public void GetPagedSupplementsValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetPagedSupplementsQueryValidator();

        var result = validator.Validate(new GetPagedSupplementsQuery
        {
            Filter = new SupplementFilter
            {
                OrderBy = "legacy"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetPagedSupplementsValidator_ShouldPass_WhenOrderByIsValid()
    {
        var validator = new GetPagedSupplementsQueryValidator();

        var result = validator.Validate(new GetPagedSupplementsQuery
        {
            Filter = new SupplementFilter
            {
                OrderBy = "supplierdesc",
                SupplementCategoryId = 1
            }
        });

        Assert.True(result.IsValid);
    }

    [Fact]
    public void GetSupplementsValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetSupplementsQueryValidator();

        var result = validator.Validate(new GetSupplementsQuery
        {
            Filter = new SupplementFilter
            {
                OrderBy = "naziv"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetSupplementsValidator_ShouldPass_WhenOrderByIsValid()
    {
        var validator = new GetSupplementsQueryValidator();

        var result = validator.Validate(new GetSupplementsQuery
        {
            Filter = new SupplementFilter
            {
                OrderBy = "createdatdesc",
                SupplementCategoryId = 2
            }
        });

        Assert.True(result.IsValid);
    }
}
