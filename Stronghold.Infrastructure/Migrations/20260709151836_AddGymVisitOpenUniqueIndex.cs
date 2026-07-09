using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Stronghold.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddGymVisitOpenUniqueIndex : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_GymVisits_UserId",
                table: "GymVisits");

            migrationBuilder.CreateIndex(
                name: "IX_GymVisits_UserId",
                table: "GymVisits",
                column: "UserId",
                unique: true,
                filter: "[CheckOutAt] IS NULL");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_GymVisits_UserId",
                table: "GymVisits");

            migrationBuilder.CreateIndex(
                name: "IX_GymVisits_UserId",
                table: "GymVisits",
                column: "UserId");
        }
    }
}
