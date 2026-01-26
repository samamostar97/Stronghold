using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Stronghold.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class FilterIsDeletedSeminarAttendee : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_SeminarAttendees_UserId_SeminarId",
                table: "SeminarAttendees");

            migrationBuilder.CreateIndex(
                name: "IX_SeminarAttendees_UserId_SeminarId",
                table: "SeminarAttendees",
                columns: new[] { "UserId", "SeminarId" },
                unique: true,
                filter: "[IsDeleted] = 0");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_SeminarAttendees_UserId_SeminarId",
                table: "SeminarAttendees");

            migrationBuilder.CreateIndex(
                name: "IX_SeminarAttendees_UserId_SeminarId",
                table: "SeminarAttendees",
                columns: new[] { "UserId", "SeminarId" },
                unique: true);
        }
    }
}
