using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Stronghold.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddUniqueConstraints : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Appointments_NutritionistId",
                table: "Appointments");

            migrationBuilder.DropIndex(
                name: "IX_Appointments_TrainerId",
                table: "Appointments");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_StripePaymentId",
                table: "Orders",
                column: "StripePaymentId",
                unique: true,
                filter: "[StripePaymentId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Appointments_NutritionistId_AppointmentDate",
                table: "Appointments",
                columns: new[] { "NutritionistId", "AppointmentDate" },
                unique: true,
                filter: "[NutritionistId] IS NOT NULL AND [IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_Appointments_TrainerId_AppointmentDate",
                table: "Appointments",
                columns: new[] { "TrainerId", "AppointmentDate" },
                unique: true,
                filter: "[TrainerId] IS NOT NULL AND [IsDeleted] = 0");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Orders_StripePaymentId",
                table: "Orders");

            migrationBuilder.DropIndex(
                name: "IX_Appointments_NutritionistId_AppointmentDate",
                table: "Appointments");

            migrationBuilder.DropIndex(
                name: "IX_Appointments_TrainerId_AppointmentDate",
                table: "Appointments");

            migrationBuilder.CreateIndex(
                name: "IX_Appointments_NutritionistId",
                table: "Appointments",
                column: "NutritionistId");

            migrationBuilder.CreateIndex(
                name: "IX_Appointments_TrainerId",
                table: "Appointments",
                column: "TrainerId");
        }
    }
}
