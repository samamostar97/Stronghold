using Stronghold.Application.Features.Memberships.DTOs;
using Stronghold.Application.Features.Memberships.Queries;

namespace Stronghold.Application.Tests;

public class MembershipQueryValidatorTests
{
    [Fact]
    public void GetMembershipPaymentsValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetMembershipPaymentsQueryValidator();

        var result = validator.Validate(new GetMembershipPaymentsQuery
        {
            UserId = 1,
            Filter = new MembershipPaymentFilter
            {
                OrderBy = "legacy"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetMembershipPaymentsValidator_ShouldPass_WhenOrderByIsValid()
    {
        var validator = new GetMembershipPaymentsQueryValidator();

        var result = validator.Validate(new GetMembershipPaymentsQuery
        {
            UserId = 1,
            Filter = new MembershipPaymentFilter
            {
                OrderBy = "datedesc",
                PageNumber = 1,
                PageSize = 10
            }
        });

        Assert.True(result.IsValid);
    }

    [Fact]
    public void GetMembershipPaymentsValidator_ShouldFail_WhenPageSizeIsTooLarge()
    {
        var validator = new GetMembershipPaymentsQueryValidator();

        var result = validator.Validate(new GetMembershipPaymentsQuery
        {
            UserId = 1,
            Filter = new MembershipPaymentFilter
            {
                PageSize = 101
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetActiveMembersValidator_ShouldFail_WhenPageNumberIsInvalid()
    {
        var validator = new GetActiveMembersQueryValidator();

        var result = validator.Validate(new GetActiveMembersQuery
        {
            Filter = new ActiveMemberFilter
            {
                PageNumber = 0
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetActiveMembersValidator_ShouldPass_WhenFilterIsValid()
    {
        var validator = new GetActiveMembersQueryValidator();

        var result = validator.Validate(new GetActiveMembersQuery
        {
            Filter = new ActiveMemberFilter
            {
                Name = "john",
                PageNumber = 1,
                PageSize = 10
            }
        });

        Assert.True(result.IsValid);
    }
}
