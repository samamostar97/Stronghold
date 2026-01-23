using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Stronghold.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class UpdateCategoryUniqueFilter : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_SupplementCategories_Name",
                table: "SupplementCategories");

            migrationBuilder.CreateIndex(
                name: "IX_SupplementCategories_Name",
                table: "SupplementCategories",
                column: "Name",
                unique: true,
                filter: "[IsDeleted] = 0");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_SupplementCategories_Name",
                table: "SupplementCategories");

            migrationBuilder.CreateIndex(
                name: "IX_SupplementCategories_Name",
                table: "SupplementCategories",
                column: "Name",
                unique: true);
        }
    }
}
