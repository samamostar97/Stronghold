using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Features.Appointments.DTOs;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Repositories;
using Stronghold.Infrastructure.Tests.TestHelpers;

namespace Stronghold.Infrastructure.Tests;

public class AppointmentRepositoryTests
{
    [Fact]
    public async Task GetUserUpcomingPagedAsync_ShouldReturnOnlyUpcomingForUser_OrderedByDate()
    {
        await using var context = TestDbContextFactory.Create();
        var seed = await SeedUsersAndStaffAsync(context);
        var repository = new AppointmentRepository(context);

        var past = new Appointment
        {
            UserId = seed.UserJohn.Id,
            TrainerId = seed.Trainer.Id,
            AppointmentDate = DateTime.UtcNow.AddDays(-1)
        };
        var upcomingLater = new Appointment
        {
            UserId = seed.UserJohn.Id,
            TrainerId = seed.Trainer.Id,
            AppointmentDate = DateTime.UtcNow.AddDays(3)
        };
        var upcomingSooner = new Appointment
        {
            UserId = seed.UserJohn.Id,
            NutritionistId = seed.Nutritionist.Id,
            AppointmentDate = DateTime.UtcNow.AddDays(1)
        };
        var otherUser = new Appointment
        {
            UserId = seed.UserAna.Id,
            TrainerId = seed.Trainer.Id,
            AppointmentDate = DateTime.UtcNow.AddDays(2)
        };

        context.Appointments.AddRange(past, upcomingLater, upcomingSooner, otherUser);
        await context.SaveChangesAsync();

        var filter = new AppointmentFilter
        {
            OrderBy = "date",
            PageNumber = 1,
            PageSize = 10
        };

        var result = await repository.GetUserUpcomingPagedAsync(seed.UserJohn.Id, filter, CancellationToken.None);

        Assert.Equal(2, result.TotalCount);
        Assert.Equal(2, result.Items.Count);
        Assert.True(result.Items[0].AppointmentDate < result.Items[1].AppointmentDate);
        Assert.All(result.Items, x => Assert.Equal(seed.UserJohn.Id, x.UserId));
    }

    [Fact]
    public async Task GetAdminPagedAsync_ShouldApplySearchAndSort()
    {
        await using var context = TestDbContextFactory.Create();
        var seed = await SeedUsersAndStaffAsync(context);
        var repository = new AppointmentRepository(context);

        var first = new Appointment
        {
            UserId = seed.UserJohn.Id,
            TrainerId = seed.Trainer.Id,
            AppointmentDate = DateTime.UtcNow.AddDays(2)
        };
        var second = new Appointment
        {
            UserId = seed.UserJohn.Id,
            NutritionistId = seed.Nutritionist.Id,
            AppointmentDate = DateTime.UtcNow.AddDays(5)
        };
        var third = new Appointment
        {
            UserId = seed.UserAna.Id,
            TrainerId = seed.Trainer.Id,
            AppointmentDate = DateTime.UtcNow.AddDays(4)
        };

        context.Appointments.AddRange(first, second, third);
        await context.SaveChangesAsync();

        var filter = new AppointmentFilter
        {
            Search = "john doe",
            OrderBy = "datedesc",
            PageNumber = 1,
            PageSize = 10
        };

        var result = await repository.GetAdminPagedAsync(filter, CancellationToken.None);

        Assert.Equal(2, result.TotalCount);
        Assert.Equal(2, result.Items.Count);
        Assert.Equal(seed.UserJohn.Id, result.Items[0].UserId);
        Assert.Equal(seed.UserJohn.Id, result.Items[1].UserId);
        Assert.True(result.Items[0].AppointmentDate >= result.Items[1].AppointmentDate);
    }

    [Fact]
    public async Task DeleteAsync_ShouldSoftDeleteEntity()
    {
        await using var context = TestDbContextFactory.Create();
        var seed = await SeedUsersAndStaffAsync(context);
        var repository = new AppointmentRepository(context);

        var appointment = new Appointment
        {
            UserId = seed.UserJohn.Id,
            TrainerId = seed.Trainer.Id,
            AppointmentDate = DateTime.UtcNow.AddDays(2)
        };

        context.Appointments.Add(appointment);
        await context.SaveChangesAsync();

        await repository.DeleteAsync(appointment, CancellationToken.None);

        var visible = await repository.GetByIdAsync(appointment.Id, CancellationToken.None);
        var raw = await context.Appointments
            .IgnoreQueryFilters()
            .SingleAsync(x => x.Id == appointment.Id);

        Assert.Null(visible);
        Assert.True(raw.IsDeleted);
    }

    [Fact]
    public async Task GetAdminPagedAsync_ShouldExcludeSoftDeletedAppointments()
    {
        await using var context = TestDbContextFactory.Create();
        var seed = await SeedUsersAndStaffAsync(context);
        var repository = new AppointmentRepository(context);

        var visibleAppointment = new Appointment
        {
            UserId = seed.UserJohn.Id,
            TrainerId = seed.Trainer.Id,
            AppointmentDate = DateTime.UtcNow.AddDays(2)
        };
        var deletedAppointment = new Appointment
        {
            UserId = seed.UserJohn.Id,
            NutritionistId = seed.Nutritionist.Id,
            AppointmentDate = DateTime.UtcNow.AddDays(3),
            IsDeleted = true
        };

        context.Appointments.AddRange(visibleAppointment, deletedAppointment);
        await context.SaveChangesAsync();

        var result = await repository.GetAdminPagedAsync(
            new AppointmentFilter { PageNumber = 1, PageSize = 10 },
            CancellationToken.None);

        Assert.Equal(1, result.TotalCount);
        Assert.Single(result.Items);
        Assert.Equal(visibleAppointment.Id, result.Items[0].Id);
    }

    [Fact]
    public async Task UserHasAppointmentOnDateAsync_ShouldIgnoreSoftDeletedAppointments()
    {
        await using var context = TestDbContextFactory.Create();
        var seed = await SeedUsersAndStaffAsync(context);
        var repository = new AppointmentRepository(context);

        var deletedAppointment = new Appointment
        {
            UserId = seed.UserJohn.Id,
            TrainerId = seed.Trainer.Id,
            AppointmentDate = DateTime.UtcNow.AddDays(4),
            IsDeleted = true
        };

        context.Appointments.Add(deletedAppointment);
        await context.SaveChangesAsync();

        var exists = await repository.UserHasAppointmentOnDateAsync(
            seed.UserJohn.Id,
            deletedAppointment.AppointmentDate,
            null,
            CancellationToken.None);

        Assert.False(exists);
    }

    private static async Task<(User UserJohn, User UserAna, Trainer Trainer, Nutritionist Nutritionist)> SeedUsersAndStaffAsync(Stronghold.Infrastructure.Data.StrongholdDbContext context)
    {
        var userJohn = new User
        {
            FirstName = "John",
            LastName = "Doe",
            Username = "john",
            Email = "john@example.com",
            PhoneNumber = "061111111",
            Role = Role.GymMember,
            PasswordHash = "hash"
        };
        var userAna = new User
        {
            FirstName = "Ana",
            LastName = "Smith",
            Username = "ana",
            Email = "ana@example.com",
            PhoneNumber = "062222222",
            Role = Role.GymMember,
            PasswordHash = "hash"
        };
        var trainer = new Trainer
        {
            FirstName = "Marko",
            LastName = "Trainer",
            Email = "trainer@example.com",
            PhoneNumber = "063333333"
        };
        var nutritionist = new Nutritionist
        {
            FirstName = "Nina",
            LastName = "Nutrition",
            Email = "nutrition@example.com",
            PhoneNumber = "064444444"
        };

        context.Users.AddRange(userJohn, userAna);
        context.Trainers.Add(trainer);
        context.Nutritionists.Add(nutritionist);
        await context.SaveChangesAsync();

        return (userJohn, userAna, trainer, nutritionist);
    }
}
