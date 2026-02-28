using Stronghold.Application.Features.Orders.DTOs;
using Stronghold.Application.Features.Orders.Queries;
using Stronghold.Core.Enums;

namespace Stronghold.Application.Tests;

public class OrderQueryValidatorTests
{
    [Fact]
    public void GetPagedOrdersValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetPagedOrdersQueryValidator();

        var result = validator.Validate(new GetPagedOrdersQuery
        {
            Filter = new OrderFilter
            {
                OrderBy = "legacy"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetPagedOrdersValidator_ShouldFail_WhenStatusIsInvalid()
    {
        var validator = new GetPagedOrdersQueryValidator();

        var result = validator.Validate(new GetPagedOrdersQuery
        {
            Filter = new OrderFilter
            {
                Status = (OrderStatus)999
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetPagedOrdersValidator_ShouldPass_WhenFilterIsValid()
    {
        var validator = new GetPagedOrdersQueryValidator();

        var result = validator.Validate(new GetPagedOrdersQuery
        {
            Filter = new OrderFilter
            {
                OrderBy = "amount",
                Descending = true,
                Status = OrderStatus.Processing
            }
        });

        Assert.True(result.IsValid);
    }

    [Fact]
    public void GetOrdersValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetOrdersQueryValidator();

        var result = validator.Validate(new GetOrdersQuery
        {
            Filter = new OrderFilter
            {
                OrderBy = "kupac"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetOrdersValidator_ShouldPass_WhenFilterIsValid()
    {
        var validator = new GetOrdersQueryValidator();

        var result = validator.Validate(new GetOrdersQuery
        {
            Filter = new OrderFilter
            {
                OrderBy = "user",
                Status = OrderStatus.Delivered
            }
        });

        Assert.True(result.IsValid);
    }

    [Fact]
    public void GetMyOrdersValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetMyOrdersQueryValidator();

        var result = validator.Validate(new GetMyOrdersQuery
        {
            Filter = new OrderFilter
            {
                OrderBy = "user"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetMyOrdersValidator_ShouldPass_WhenFilterIsValid()
    {
        var validator = new GetMyOrdersQueryValidator();

        var result = validator.Validate(new GetMyOrdersQuery
        {
            Filter = new OrderFilter
            {
                Search = "protein",
                OrderBy = "date",
                Status = OrderStatus.Cancelled
            }
        });

        Assert.True(result.IsValid);
    }
}
