using System.Net;
using System.Net.Http.Json;
using Stronghold.API.Tests.Infrastructure;

namespace Stronghold.API.Tests;

public class AuthSmokeTests : IClassFixture<StrongholdApiFactory>, IAsyncLifetime
{
    private readonly StrongholdApiFactory _factory;

    public AuthSmokeTests(StrongholdApiFactory factory)
    {
        _factory = factory;
    }

    public async Task InitializeAsync()
    {
        await _factory.ResetDatabaseAsync();
    }

    public Task DisposeAsync()
    {
        return Task.CompletedTask;
    }

    [Fact]
    public async Task Login_ShouldReturnToken_ForValidCredentials()
    {
        var client = _factory.CreateApiClient();

        var response = await client.PostAsJsonAsync("/api/Auth/login", new
        {
            username = StrongholdApiFactory.MemberUsername,
            password = StrongholdApiFactory.Password
        });

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var payload = await response.Content.ReadAsStringAsync();
        Assert.Contains("token", payload, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task Login_ShouldReturnUnauthorized_ForInvalidPassword()
    {
        var client = _factory.CreateApiClient();

        var response = await client.PostAsJsonAsync("/api/Auth/login", new
        {
            username = StrongholdApiFactory.MemberUsername,
            password = "wrong-password"
        });

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }
}
