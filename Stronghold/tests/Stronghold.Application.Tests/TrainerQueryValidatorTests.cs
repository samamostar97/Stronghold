using Stronghold.Application.Features.Trainers.DTOs;
using Stronghold.Application.Features.Trainers.Queries;

namespace Stronghold.Application.Tests;

public class TrainerQueryValidatorTests
{
    [Fact]
    public void GetPagedTrainersValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetPagedTrainersQueryValidator();

        var result = validator.Validate(new GetPagedTrainersQuery
        {
            Filter = new TrainerFilter
            {
                OrderBy = "legacy"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetPagedTrainersValidator_ShouldPass_WhenOrderByIsValid()
    {
        var validator = new GetPagedTrainersQueryValidator();

        var result = validator.Validate(new GetPagedTrainersQuery
        {
            Filter = new TrainerFilter
            {
                OrderBy = "lastnamedesc"
            }
        });

        Assert.True(result.IsValid);
    }

    [Fact]
    public void GetTrainersValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetTrainersQueryValidator();

        var result = validator.Validate(new GetTrainersQuery
        {
            Filter = new TrainerFilter
            {
                OrderBy = "ime"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetTrainersValidator_ShouldPass_WhenOrderByIsValid()
    {
        var validator = new GetTrainersQueryValidator();

        var result = validator.Validate(new GetTrainersQuery
        {
            Filter = new TrainerFilter
            {
                OrderBy = "createdatdesc"
            }
        });

        Assert.True(result.IsValid);
    }
}
