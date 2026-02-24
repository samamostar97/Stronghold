using Stronghold.Application.Features.Faqs.DTOs;
using Stronghold.Application.Features.Faqs.Queries;

namespace Stronghold.Application.Tests;

public class FaqQueryValidatorTests
{
    [Fact]
    public void GetPagedFaqsValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetPagedFaqsQueryValidator();

        var result = validator.Validate(new GetPagedFaqsQuery
        {
            Filter = new FaqFilter
            {
                OrderBy = "legacy"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetPagedFaqsValidator_ShouldPass_WhenFilterIsValid()
    {
        var validator = new GetPagedFaqsQueryValidator();

        var result = validator.Validate(new GetPagedFaqsQuery
        {
            Filter = new FaqFilter
            {
                Search = "protein",
                OrderBy = "createdatdesc"
            }
        });

        Assert.True(result.IsValid);
    }

    [Fact]
    public void GetFaqsValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetFaqsQueryValidator();

        var result = validator.Validate(new GetFaqsQuery
        {
            Filter = new FaqFilter
            {
                OrderBy = "date"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetFaqsValidator_ShouldPass_WhenFilterIsValid()
    {
        var validator = new GetFaqsQueryValidator();

        var result = validator.Validate(new GetFaqsQuery
        {
            Filter = new FaqFilter
            {
                Search = "faq",
                OrderBy = "question"
            }
        });

        Assert.True(result.IsValid);
    }
}
