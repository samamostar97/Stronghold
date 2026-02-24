using Stronghold.Application.Features.Reviews.DTOs;
using Stronghold.Application.Features.Reviews.Queries;

namespace Stronghold.Application.Tests;

public class ReviewQueryValidatorTests
{
    [Fact]
    public void GetPagedReviewsValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetPagedReviewsQueryValidator();

        var result = validator.Validate(new GetPagedReviewsQuery
        {
            Filter = new ReviewFilter
            {
                OrderBy = "legacy"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetPagedReviewsValidator_ShouldPass_WhenOrderByIsValid()
    {
        var validator = new GetPagedReviewsQueryValidator();

        var result = validator.Validate(new GetPagedReviewsQuery
        {
            Filter = new ReviewFilter
            {
                OrderBy = "ratingdesc"
            }
        });

        Assert.True(result.IsValid);
    }

    [Fact]
    public void GetReviewsValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetReviewsQueryValidator();

        var result = validator.Validate(new GetReviewsQuery
        {
            Filter = new ReviewFilter
            {
                OrderBy = "ime"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetMyReviewsValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetMyReviewsQueryValidator();

        var result = validator.Validate(new GetMyReviewsQuery
        {
            Filter = new ReviewFilter
            {
                OrderBy = "firstname"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetMyReviewsValidator_ShouldPass_WhenOrderByIsValid()
    {
        var validator = new GetMyReviewsQueryValidator();

        var result = validator.Validate(new GetMyReviewsQuery
        {
            Filter = new ReviewFilter
            {
                OrderBy = "supplementdesc"
            }
        });

        Assert.True(result.IsValid);
    }

    [Fact]
    public void GetAvailableSupplementsForReviewValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetAvailableSupplementsForReviewQueryValidator();

        var result = validator.Validate(new GetAvailableSupplementsForReviewQuery
        {
            Filter = new ReviewFilter
            {
                OrderBy = "rating"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetAvailableSupplementsForReviewValidator_ShouldPass_WhenOrderByIsValid()
    {
        var validator = new GetAvailableSupplementsForReviewQueryValidator();

        var result = validator.Validate(new GetAvailableSupplementsForReviewQuery
        {
            Filter = new ReviewFilter
            {
                OrderBy = "namedesc"
            }
        });

        Assert.True(result.IsValid);
    }
}
