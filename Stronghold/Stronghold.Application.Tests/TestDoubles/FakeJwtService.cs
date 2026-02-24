using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Tests.TestDoubles;

internal sealed class FakeJwtService : IJwtService
{
    public AuthResponse LoginResponse { get; set; } = new();
    public AuthResponse? RegisterResponse { get; set; } = new();

    public LoginRequest? LastLoginRequest { get; private set; }
    public RegisterRequest? LastRegisterRequest { get; private set; }
    public ChangePasswordRequest? LastChangePasswordRequest { get; private set; }
    public ForgotPasswordRequest? LastForgotPasswordRequest { get; private set; }
    public ResetPasswordRequest? LastResetPasswordRequest { get; private set; }
    public int? LastChangePasswordUserId { get; private set; }

    public Task<AuthResponse> LoginAsync(LoginRequest request)
    {
        LastLoginRequest = request;
        return Task.FromResult(LoginResponse);
    }

    public Task<AuthResponse?> RegisterAsync(RegisterRequest request)
    {
        LastRegisterRequest = request;
        return Task.FromResult(RegisterResponse);
    }

    public Task ChangePasswordAsync(int userId, ChangePasswordRequest request)
    {
        LastChangePasswordUserId = userId;
        LastChangePasswordRequest = request;
        return Task.CompletedTask;
    }

    public Task ForgotPasswordAsync(ForgotPasswordRequest request)
    {
        LastForgotPasswordRequest = request;
        return Task.CompletedTask;
    }

    public Task ResetPasswordAsync(ResetPasswordRequest request)
    {
        LastResetPasswordRequest = request;
        return Task.CompletedTask;
    }
}
