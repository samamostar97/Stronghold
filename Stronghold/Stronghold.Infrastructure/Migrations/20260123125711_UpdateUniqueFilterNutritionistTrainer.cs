using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Stronghold.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class UpdateUniqueFilterNutritionistTrainer : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Trainers_Email",
                table: "Trainers");

            migrationBuilder.DropIndex(
                name: "IX_Nutritionists_Email",
                table: "Nutritionists");

            migrationBuilder.CreateIndex(
                name: "IX_Trainers_Email",
                table: "Trainers",
                column: "Email",
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_Nutritionists_Email",
                table: "Nutritionists",
                column: "Email",
                unique: true,
                filter: "[IsDeleted] = 0");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Trainers_Email",
                table: "Trainers");

            migrationBuilder.DropIndex(
                name: "IX_Nutritionists_Email",
                table: "Nutritionists");

            migrationBuilder.CreateIndex(
                name: "IX_Trainers_Email",
                table: "Trainers",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Nutritionists_Email",
                table: "Nutritionists",
                column: "Email",
                unique: true);
        }
    }
}
