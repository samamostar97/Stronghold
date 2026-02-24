using Stronghold.Application.Common;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.Appointments.Commands;
using Stronghold.Application.Tests.TestDoubles;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Tests;

public class AppointmentCommandTests
{
    [Fact]
    public async Task AdminCreate_ShouldThrowUnauthorized_WhenCurrentUserIsNotAdmin()
    {
        var repository = new FakeAppointmentRepository();
        var currentUser = new FakeCurrentUserService(
            userId: 12,
            username: "member",
            isAuthenticated: true,
            "GymMember");
        var handler = new AdminCreateAppointmentCommandHandler(repository, currentUser);

        var act = () => handler.Handle(new AdminCreateAppointmentCommand
        {
            UserId = 99,
            TrainerId = 5,
            AppointmentDate = NextValidAppointmentDate()
        }, CancellationToken.None);

        await Assert.ThrowsAsync<UnauthorizedAccessException>(act);
    }

    [Fact]
    public async Task AdminCreate_ShouldThrowArgumentException_WhenNoStaffSelected()
    {
        var repository = new FakeAppointmentRepository();
        var currentUser = new FakeCurrentUserService(
            userId: 1,
            username: "admin",
            isAuthenticated: true,
            "Admin");
        var handler = new AdminCreateAppointmentCommandHandler(repository, currentUser);

        var act = () => handler.Handle(new AdminCreateAppointmentCommand
        {
            UserId = 99,
            TrainerId = null,
            NutritionistId = null,
            AppointmentDate = NextValidAppointmentDate()
        }, CancellationToken.None);

        await Assert.ThrowsAsync<ArgumentException>(act);
    }

    [Fact]
    public async Task AdminCreate_ShouldThrowConflict_WhenUserAlreadyHasAppointmentOnSameDate()
    {
        var repository = new FakeAppointmentRepository
        {
            UserHasAppointmentOnDateResult = true
        };
        var currentUser = new FakeCurrentUserService(
            userId: 1,
            username: "admin",
            isAuthenticated: true,
            "Admin");
        var handler = new AdminCreateAppointmentCommandHandler(repository, currentUser);

        var act = () => handler.Handle(new AdminCreateAppointmentCommand
        {
            UserId = 99,
            TrainerId = 5,
            AppointmentDate = NextValidAppointmentDate()
        }, CancellationToken.None);

        await Assert.ThrowsAsync<ConflictException>(act);
    }

    [Fact]
    public async Task AdminCreate_ShouldReturnCreatedId_WhenRequestIsValid()
    {
        var repository = new FakeAppointmentRepository
        {
            CreatedAppointmentId = 321
        };
        var currentUser = new FakeCurrentUserService(
            userId: 1,
            username: "admin",
            isAuthenticated: true,
            "Admin");
        var handler = new AdminCreateAppointmentCommandHandler(repository, currentUser);

        var result = await handler.Handle(new AdminCreateAppointmentCommand
        {
            UserId = 99,
            TrainerId = 5,
            AppointmentDate = NextValidAppointmentDate()
        }, CancellationToken.None);

        Assert.Equal(321, result);
        Assert.NotNull(repository.AddedAppointment);
        Assert.Equal(99, repository.AddedAppointment!.UserId);
        Assert.Equal(5, repository.AddedAppointment.TrainerId);
        Assert.Null(repository.AddedAppointment.NutritionistId);
    }

    [Fact]
    public async Task CancelMyAppointment_ShouldThrowInvalidOperation_WhenAppointmentIsInPast()
    {
        var repository = new FakeAppointmentRepository
        {
            AppointmentByUserAndIdResult = new Appointment
            {
                Id = 8,
                UserId = 10,
                AppointmentDate = StrongholdTimeUtils.LocalNow.AddMinutes(-10)
            }
        };
        var currentUser = new FakeCurrentUserService(
            userId: 10,
            username: "member",
            isAuthenticated: true,
            "GymMember");
        var handler = new CancelMyAppointmentCommandHandler(repository, currentUser);

        var act = () => handler.Handle(new CancelMyAppointmentCommand
        {
            AppointmentId = 8
        }, CancellationToken.None);

        await Assert.ThrowsAsync<InvalidOperationException>(act);
        Assert.False(repository.DeleteCalled);
    }

    [Fact]
    public async Task CancelMyAppointment_ShouldDeleteAppointment_WhenAppointmentIsUpcoming()
    {
        var appointment = new Appointment
        {
            Id = 8,
            UserId = 10,
            AppointmentDate = StrongholdTimeUtils.LocalNow.AddDays(2)
        };
        var repository = new FakeAppointmentRepository
        {
            AppointmentByUserAndIdResult = appointment
        };
        var currentUser = new FakeCurrentUserService(
            userId: 10,
            username: "member",
            isAuthenticated: true,
            "GymMember");
        var handler = new CancelMyAppointmentCommandHandler(repository, currentUser);

        await handler.Handle(new CancelMyAppointmentCommand
        {
            AppointmentId = 8
        }, CancellationToken.None);

        Assert.True(repository.DeleteCalled);
        Assert.Same(appointment, repository.DeletedAppointment);
        Assert.True(appointment.IsDeleted);
    }

    [Fact]
    public void AdminCreateValidator_ShouldFail_WhenBothTrainerAndNutritionistAreProvided()
    {
        var validator = new AdminCreateAppointmentCommandValidator();

        var result = validator.Validate(new AdminCreateAppointmentCommand
        {
            UserId = 10,
            TrainerId = 1,
            NutritionistId = 2,
            AppointmentDate = NextValidAppointmentDate()
        });

        Assert.False(result.IsValid);
    }

    private static DateTime NextValidAppointmentDate()
    {
        return StrongholdTimeUtils.LocalToday.AddDays(1).AddHours(10);
    }
}
