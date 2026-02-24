using Stronghold.Application.Features.Nutritionists.DTOs;
using Stronghold.Application.Features.Nutritionists.Queries;

namespace Stronghold.Application.Tests;

public class NutritionistQueryValidatorTests
{
    [Fact]
    public void GetPagedNutritionistsValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetPagedNutritionistsQueryValidator();

        var result = validator.Validate(new GetPagedNutritionistsQuery
        {
            Filter = new NutritionistFilter
            {
                OrderBy = "legacy"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetPagedNutritionistsValidator_ShouldPass_WhenOrderByIsValid()
    {
        var validator = new GetPagedNutritionistsQueryValidator();

        var result = validator.Validate(new GetPagedNutritionistsQuery
        {
            Filter = new NutritionistFilter
            {
                OrderBy = "lastnamedesc"
            }
        });

        Assert.True(result.IsValid);
    }

    [Fact]
    public void GetNutritionistsValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetNutritionistsQueryValidator();

        var result = validator.Validate(new GetNutritionistsQuery
        {
            Filter = new NutritionistFilter
            {
                OrderBy = "prezime"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetNutritionistsValidator_ShouldPass_WhenOrderByIsValid()
    {
        var validator = new GetNutritionistsQueryValidator();

        var result = validator.Validate(new GetNutritionistsQuery
        {
            Filter = new NutritionistFilter
            {
                OrderBy = "createdatdesc"
            }
        });

        Assert.True(result.IsValid);
    }
}
