using Stronghold.Application.Features.Seminars.DTOs;
using Stronghold.Application.Features.Seminars.Queries;

namespace Stronghold.Application.Tests;

public class SeminarQueryValidatorTests
{
    [Fact]
    public void GetPagedSeminarsValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetPagedSeminarsQueryValidator();

        var result = validator.Validate(new GetPagedSeminarsQuery
        {
            Filter = new SeminarFilter
            {
                OrderBy = "invalid-sort"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetPagedSeminarsValidator_ShouldPass_WhenOrderByAndStatusAreValid()
    {
        var validator = new GetPagedSeminarsQueryValidator();

        var result = validator.Validate(new GetPagedSeminarsQuery
        {
            Filter = new SeminarFilter
            {
                OrderBy = "maxcapacitydesc",
                Status = "active"
            }
        });

        Assert.True(result.IsValid);
    }

    [Fact]
    public void GetPagedSeminarsValidator_ShouldFail_WhenStatusIsInvalid()
    {
        var validator = new GetPagedSeminarsQueryValidator();

        var result = validator.Validate(new GetPagedSeminarsQuery
        {
            Filter = new SeminarFilter
            {
                Status = "archived"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetSeminarsValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetSeminarsQueryValidator();

        var result = validator.Validate(new GetSeminarsQuery
        {
            Filter = new SeminarFilter
            {
                OrderBy = "legacy"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetSeminarsValidator_ShouldPass_WhenOrderByAndStatusAreValid()
    {
        var validator = new GetSeminarsQueryValidator();

        var result = validator.Validate(new GetSeminarsQuery
        {
            Filter = new SeminarFilter
            {
                OrderBy = "topicdesc",
                Status = "finished"
            }
        });

        Assert.True(result.IsValid);
    }
}
