using Stronghold.Application.Features.SupplementCategories.DTOs;
using Stronghold.Application.Features.SupplementCategories.Queries;

namespace Stronghold.Application.Tests;

public class SupplementCategoryQueryValidatorTests
{
    [Fact]
    public void GetPagedSupplementCategoriesValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetPagedSupplementCategoriesQueryValidator();

        var result = validator.Validate(new GetPagedSupplementCategoriesQuery
        {
            Filter = new SupplementCategoryFilter
            {
                OrderBy = "legacy"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetPagedSupplementCategoriesValidator_ShouldPass_WhenOrderByIsValid()
    {
        var validator = new GetPagedSupplementCategoriesQueryValidator();

        var result = validator.Validate(new GetPagedSupplementCategoriesQuery
        {
            Filter = new SupplementCategoryFilter
            {
                OrderBy = "name"
            }
        });

        Assert.True(result.IsValid);
    }

    [Fact]
    public void GetSupplementCategoriesValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetSupplementCategoriesQueryValidator();

        var result = validator.Validate(new GetSupplementCategoriesQuery
        {
            Filter = new SupplementCategoryFilter
            {
                OrderBy = "naziv"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetSupplementCategoriesValidator_ShouldPass_WhenOrderByIsValid()
    {
        var validator = new GetSupplementCategoriesQueryValidator();

        var result = validator.Validate(new GetSupplementCategoriesQuery
        {
            Filter = new SupplementCategoryFilter
            {
                OrderBy = "createdatdesc"
            }
        });

        Assert.True(result.IsValid);
    }
}
