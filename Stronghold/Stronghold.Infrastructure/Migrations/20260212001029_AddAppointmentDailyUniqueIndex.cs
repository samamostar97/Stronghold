using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Stronghold.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddAppointmentDailyUniqueIndex : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Appointments_UserId",
                table: "Appointments");

            migrationBuilder.AddColumn<DateTime>(
                name: "AppointmentDateDate",
                table: "Appointments",
                type: "date",
                nullable: false,
                computedColumnSql: "CONVERT(date, [AppointmentDate])",
                stored: true);

            migrationBuilder.CreateIndex(
                name: "IX_Appointments_UserId_AppointmentDateDate",
                table: "Appointments",
                columns: new[] { "UserId", "AppointmentDateDate" },
                unique: true,
                filter: "[IsDeleted] = 0");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Appointments_UserId_AppointmentDateDate",
                table: "Appointments");

            migrationBuilder.DropColumn(
                name: "AppointmentDateDate",
                table: "Appointments");

            migrationBuilder.CreateIndex(
                name: "IX_Appointments_UserId",
                table: "Appointments",
                column: "UserId");
        }
    }
}
