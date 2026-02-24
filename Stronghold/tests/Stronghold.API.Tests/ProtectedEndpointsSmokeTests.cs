using System.Net;
using System.Net.Http.Headers;
using Stronghold.API.Tests.Infrastructure;

namespace Stronghold.API.Tests;

public class ProtectedEndpointsSmokeTests : IClassFixture<StrongholdApiFactory>, IAsyncLifetime
{
    private readonly StrongholdApiFactory _factory;

    public ProtectedEndpointsSmokeTests(StrongholdApiFactory factory)
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
    public async Task GetProfile_ShouldReturnUnauthorized_WithoutToken()
    {
        var client = _factory.CreateApiClient();

        var response = await client.GetAsync("/api/profile");

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task GetProfile_ShouldReturnOk_WithMemberToken()
    {
        var client = _factory.CreateApiClient();
        var token = await _factory.LoginAndGetTokenAsync(
            client,
            StrongholdApiFactory.MemberUsername,
            StrongholdApiFactory.Password);

        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

        var response = await client.GetAsync("/api/profile");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task GetMyAppointments_ShouldReturnOk_WithMemberToken()
    {
        var client = _factory.CreateApiClient();
        var token = await _factory.LoginAndGetTokenAsync(
            client,
            StrongholdApiFactory.MemberUsername,
            StrongholdApiFactory.Password);

        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

        var response = await client.GetAsync("/api/appointments/my?pageNumber=1&pageSize=10");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task GetMyOrders_ShouldReturnOk_WithMemberToken()
    {
        var client = _factory.CreateApiClient();
        var token = await _factory.LoginAndGetTokenAsync(
            client,
            StrongholdApiFactory.MemberUsername,
            StrongholdApiFactory.Password);

        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

        var response = await client.GetAsync("/api/orders/my?pageNumber=1&pageSize=10");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task GetAdminAppointments_ShouldReturnUnauthorized_ForMemberToken()
    {
        var client = _factory.CreateApiClient();
        var token = await _factory.LoginAndGetTokenAsync(
            client,
            StrongholdApiFactory.MemberUsername,
            StrongholdApiFactory.Password);

        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

        var response = await client.GetAsync("/api/appointments/admin?pageNumber=1&pageSize=10");

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task GetAdminAppointments_ShouldReturnOk_ForAdminToken()
    {
        var client = _factory.CreateApiClient();
        var token = await _factory.LoginAndGetTokenAsync(
            client,
            StrongholdApiFactory.AdminUsername,
            StrongholdApiFactory.Password);

        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

        var response = await client.GetAsync("/api/appointments/admin?pageNumber=1&pageSize=10");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }
}
