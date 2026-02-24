using Stronghold.Application.Features.Suppliers.DTOs;
using Stronghold.Application.Features.Suppliers.Queries;

namespace Stronghold.Application.Tests;

public class SupplierQueryValidatorTests
{
    [Fact]
    public void GetPagedSuppliersValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetPagedSuppliersQueryValidator();

        var result = validator.Validate(new GetPagedSuppliersQuery
        {
            Filter = new SupplierFilter
            {
                OrderBy = "legacy"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetPagedSuppliersValidator_ShouldPass_WhenOrderByIsValid()
    {
        var validator = new GetPagedSuppliersQueryValidator();

        var result = validator.Validate(new GetPagedSuppliersQuery
        {
            Filter = new SupplierFilter
            {
                OrderBy = "namedesc"
            }
        });

        Assert.True(result.IsValid);
    }

    [Fact]
    public void GetSuppliersValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetSuppliersQueryValidator();

        var result = validator.Validate(new GetSuppliersQuery
        {
            Filter = new SupplierFilter
            {
                OrderBy = "naziv"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetSuppliersValidator_ShouldPass_WhenOrderByIsValid()
    {
        var validator = new GetSuppliersQueryValidator();

        var result = validator.Validate(new GetSuppliersQuery
        {
            Filter = new SupplierFilter
            {
                OrderBy = "createdatdesc"
            }
        });

        Assert.True(result.IsValid);
    }
}
