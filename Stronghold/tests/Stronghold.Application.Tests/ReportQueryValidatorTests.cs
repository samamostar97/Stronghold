using Stronghold.Application.Features.Reports.Queries;
using Stronghold.Application.Features.Reports.DTOs;

namespace Stronghold.Application.Tests;

public class ReportQueryValidatorTests
{
    [Fact]
    public void GetSlowMovingProductsValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetSlowMovingProductsQueryValidator();

        var result = validator.Validate(new GetSlowMovingProductsQuery
        {
            Filter = new SlowMovingProductQueryFilter
            {
                OrderBy = "legacy"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetSlowMovingProductsValidator_ShouldPass_WhenFilterIsValid()
    {
        var validator = new GetSlowMovingProductsQueryValidator();

        var result = validator.Validate(new GetSlowMovingProductsQuery
        {
            Filter = new SlowMovingProductQueryFilter
            {
                DaysToAnalyze = 30,
                PageNumber = 1,
                PageSize = 10,
                Search = "whey",
                OrderBy = "quantitysold"
            }
        });

        Assert.True(result.IsValid);
    }

    [Fact]
    public void GetInventoryReportValidator_ShouldFail_WhenDaysOutOfRange()
    {
        var validator = new GetInventoryReportQueryValidator();

        var result = validator.Validate(new GetInventoryReportQuery
        {
            DaysToAnalyze = 0
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetInventorySummaryValidator_ShouldFail_WhenDaysOutOfRange()
    {
        var validator = new GetInventorySummaryQueryValidator();

        var result = validator.Validate(new GetInventorySummaryQuery
        {
            DaysToAnalyze = 500
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetActivityFeedValidator_ShouldFail_WhenCountOutOfRange()
    {
        var validator = new GetActivityFeedQueryValidator();

        var result = validator.Validate(new GetActivityFeedQuery
        {
            Count = 0
        });

        Assert.False(result.IsValid);
    }

}
