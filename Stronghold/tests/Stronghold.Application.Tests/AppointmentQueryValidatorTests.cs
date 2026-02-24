using Stronghold.Application.Features.Appointments.DTOs;
using Stronghold.Application.Features.Appointments.Queries;

namespace Stronghold.Application.Tests;

public class AppointmentQueryValidatorTests
{
    [Fact]
    public void GetAdminAppointmentsValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetAdminAppointmentsQueryValidator();

        var result = validator.Validate(new GetAdminAppointmentsQuery
        {
            Filter = new AppointmentFilter
            {
                OrderBy = "legacy"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetAdminAppointmentsValidator_ShouldPass_WhenOrderByIsValid()
    {
        var validator = new GetAdminAppointmentsQueryValidator();

        var result = validator.Validate(new GetAdminAppointmentsQuery
        {
            Filter = new AppointmentFilter
            {
                OrderBy = "userdesc"
            }
        });

        Assert.True(result.IsValid);
    }

    [Fact]
    public void GetMyAppointmentsValidator_ShouldFail_WhenOrderByIsInvalid()
    {
        var validator = new GetMyAppointmentsQueryValidator();

        var result = validator.Validate(new GetMyAppointmentsQuery
        {
            Filter = new AppointmentFilter
            {
                OrderBy = "user"
            }
        });

        Assert.False(result.IsValid);
    }

    [Fact]
    public void GetMyAppointmentsValidator_ShouldPass_WhenOrderByIsValid()
    {
        var validator = new GetMyAppointmentsQueryValidator();

        var result = validator.Validate(new GetMyAppointmentsQuery
        {
            Filter = new AppointmentFilter
            {
                OrderBy = "datedesc"
            }
        });

        Assert.True(result.IsValid);
    }
}
