using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Stronghold.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class SimplifyOrderStatus : Migration
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

            // Remap existing OrderStatus values to new simplified enum:
            // Old values: 0=Pending, 1=Processing, 2=Shipped, 3=Delivered, 4=Cancelled
            // New values: 0=Processing, 1=Delivered

            // First, map Shipped(2), Delivered(3), Cancelled(4) to new Delivered(1)
            migrationBuilder.Sql("UPDATE Orders SET Status = 1 WHERE Status IN (2, 3, 4)");

            // Then, map old Processing(1) to new Processing(0)
            // Old Pending(0) already maps to new Processing(0)
            migrationBuilder.Sql("UPDATE Orders SET Status = 0 WHERE Status = 1");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Reverse OrderStatus mapping (best effort - some info is lost):
            // New Delivered(1) -> Old Delivered(3)
            // New Processing(0) -> Old Pending(0)
            migrationBuilder.Sql("UPDATE Orders SET Status = 3 WHERE Status = 1");

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
