using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Stronghold.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class IsDeletedFilterReviews : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Reviews_UserId_SupplementId",
                table: "Reviews");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_UserId_SupplementId",
                table: "Reviews",
                columns: new[] { "UserId", "SupplementId" },
                unique: true,
                filter: "[IsDeleted] = 0");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Reviews_UserId_SupplementId",
                table: "Reviews");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_UserId_SupplementId",
                table: "Reviews",
                columns: new[] { "UserId", "SupplementId" },
                unique: true);
        }
    }
}
