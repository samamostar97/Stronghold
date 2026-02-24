using Stronghold.Application.Features.MembershipPackages.DTOs;
using Stronghold.Application.Features.MembershipPackages.Queries;

namespace Stronghold.Application.Tests;

public class MembershipPackageQueryValidatorTests
{
    [Fact]
    public void GetPagedMembershipPackagesValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetPagedMembershipPackagesQueryValidator();

        var result = validator.Validate(new GetPagedMembershipPackagesQuery
        {
            Filter = new MembershipPackageFilter
            {
                OrderBy = "legacy"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetPagedMembershipPackagesValidator_ShouldPass_WhenOrderByIsValid()
    {
        var validator = new GetPagedMembershipPackagesQueryValidator();

        var result = validator.Validate(new GetPagedMembershipPackagesQuery
        {
            Filter = new MembershipPackageFilter
            {
                OrderBy = "packagenamedesc"
            }
        });

        Assert.True(result.IsValid);
    }

    [Fact]
    public void GetMembershipPackagesValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetMembershipPackagesQueryValidator();

        var result = validator.Validate(new GetMembershipPackagesQuery
        {
            Filter = new MembershipPackageFilter
            {
                OrderBy = "naziv"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetMembershipPackagesValidator_ShouldPass_WhenOrderByIsValid()
    {
        var validator = new GetMembershipPackagesQueryValidator();

        var result = validator.Validate(new GetMembershipPackagesQuery
        {
            Filter = new MembershipPackageFilter
            {
                OrderBy = "createdatdesc"
            }
        });

        Assert.True(result.IsValid);
    }
}
