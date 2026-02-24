using Stronghold.Application.Features.Users.DTOs;
using Stronghold.Application.Features.Users.Queries;

namespace Stronghold.Application.Tests;

public class UserQueryValidatorTests
{
    [Fact]
    public void GetPagedUsersValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetPagedUsersQueryValidator();

        var result = validator.Validate(new GetPagedUsersQuery
        {
            Filter = new UserFilter
            {
                OrderBy = "username"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetPagedUsersValidator_ShouldPass_WhenFilterIsValid()
    {
        var validator = new GetPagedUsersQueryValidator();

        var result = validator.Validate(new GetPagedUsersQuery
        {
            Filter = new UserFilter
            {
                Name = "samir",
                OrderBy = "datedesc"
            }
        });

        Assert.True(result.IsValid);
    }

    [Fact]
    public void GetUsersValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetUsersQueryValidator();

        var result = validator.Validate(new GetUsersQuery
        {
            Filter = new UserFilter
            {
                OrderBy = "createdatdesc"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetUsersValidator_ShouldPass_WhenFilterIsValid()
    {
        var validator = new GetUsersQueryValidator();

        var result = validator.Validate(new GetUsersQuery
        {
            Filter = new UserFilter
            {
                Name = "ana",
                OrderBy = "firstname"
            }
        });

        Assert.True(result.IsValid);
    }
}
