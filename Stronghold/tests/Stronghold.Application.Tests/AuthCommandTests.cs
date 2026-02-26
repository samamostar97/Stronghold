using MediatR;
using Stronghold.Application.Common.Behaviors;
using Stronghold.Application.Features.Auth.Commands;
using Stronghold.Application.Tests.TestDoubles;

namespace Stronghold.Application.Tests;

public class AuthCommandTests
{
    [Fact]
    public async Task AdminLogin_ShouldThrowUnauthorized_WhenUserIsNotAdmin()
    {
        var jwtService = new FakeJwtService
        {
            LoginResponse = new()
            {
                UserId = 5,
                Username = "member",
                Role = "GymMember",
                Token = "token"
            }
        };
        var handler = new AdminLoginCommandHandler(jwtService);

        var act = () => handler.Handle(new AdminLoginCommand
        {
            Username = "member",
            Password = "secret123"
        }, CancellationToken.None);

        await Assert.ThrowsAsync<UnauthorizedAccessException>(act);
    }

    [Fact]
    public async Task MemberLogin_ShouldThrowUnauthorized_WhenUserIsAdmin()
    {
        var jwtService = new FakeJwtService
        {
            LoginResponse = new()
            {
                UserId = 1,
                Username = "admin",
                Role = "Admin",
                Token = "token"
            }
        };
        var handler = new MemberLoginCommandHandler(jwtService);

        var act = () => handler.Handle(new MemberLoginCommand
        {
            Username = "admin",
            Password = "secret123"
        }, CancellationToken.None);

        await Assert.ThrowsAsync<UnauthorizedAccessException>(act);
    }

    [Fact]
    public async Task ChangePassword_ShouldThrowUnauthorized_WhenUserIsNotAuthenticated()
    {
        var jwtService = new FakeJwtService();
        var currentUser = new FakeCurrentUserService(
            userId: null,
            username: null,
            isAuthenticated: false);
        var command = new ChangePasswordCommand
        {
            CurrentPassword = "oldpass123",
            NewPassword = "newpass123"
        };
        var handler = new ChangePasswordCommandHandler(jwtService, currentUser);
        var behavior = new AuthorizationBehavior<ChangePasswordCommand, Unit>(currentUser);

        var act = () => behavior.Handle(
            command,
            () => handler.Handle(command, CancellationToken.None),
            CancellationToken.None);

        await Assert.ThrowsAsync<UnauthorizedAccessException>(act);
        Assert.Null(jwtService.LastChangePasswordUserId);
    }

    [Fact]
    public async Task ChangePassword_ShouldUseCurrentUserId_WhenAuthenticated()
    {
        var jwtService = new FakeJwtService();
        var currentUser = new FakeCurrentUserService(
            userId: 42,
            username: "member",
            isAuthenticated: true,
            "GymMember");
        var handler = new ChangePasswordCommandHandler(jwtService, currentUser);

        await handler.Handle(new ChangePasswordCommand
        {
            CurrentPassword = "oldpass123",
            NewPassword = "newpass123"
        }, CancellationToken.None);

        Assert.Equal(42, jwtService.LastChangePasswordUserId);
        Assert.NotNull(jwtService.LastChangePasswordRequest);
        Assert.Equal("oldpass123", jwtService.LastChangePasswordRequest!.CurrentPassword);
        Assert.Equal("newpass123", jwtService.LastChangePasswordRequest.NewPassword);
    }

    [Fact]
    public async Task Register_ShouldThrowInvalidOperation_WhenJwtServiceReturnsNull()
    {
        var jwtService = new FakeJwtService
        {
            RegisterResponse = null
        };
        var handler = new RegisterCommandHandler(jwtService);

        var act = () => handler.Handle(new RegisterCommand
        {
            FirstName = "Test",
            LastName = "User",
            Username = "testuser",
            Email = "test@example.com",
            PhoneNumber = "+38761111222",
            Password = "secret123"
        }, CancellationToken.None);

        await Assert.ThrowsAsync<InvalidOperationException>(act);
    }

    [Fact]
    public void ChangePasswordValidator_ShouldFail_WhenNewPasswordEqualsCurrentPassword()
    {
        var validator = new ChangePasswordCommandValidator();

        var result = validator.Validate(new ChangePasswordCommand
        {
            CurrentPassword = "same-pass-123",
            NewPassword = "same-pass-123"
        });

        Assert.False(result.IsValid);
        Assert.Contains(result.Errors, e => e.PropertyName == string.Empty);
    }
}
