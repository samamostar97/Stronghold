using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Stronghold.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddStockManagement : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "StockQuantity",
                table: "Supplements",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "StockLogs",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SupplementId = table.Column<int>(type: "int", nullable: false),
                    QuantityChange = table.Column<int>(type: "int", nullable: false),
                    QuantityBefore = table.Column<int>(type: "int", nullable: false),
                    QuantityAfter = table.Column<int>(type: "int", nullable: false),
                    Reason = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    RelatedOrderId = table.Column<int>(type: "int", nullable: true),
                    PerformedByUserId = table.Column<int>(type: "int", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StockLogs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_StockLogs_Orders_RelatedOrderId",
                        column: x => x.RelatedOrderId,
                        principalTable: "Orders",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_StockLogs_Supplements_SupplementId",
                        column: x => x.SupplementId,
                        principalTable: "Supplements",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_StockLogs_Users_PerformedByUserId",
                        column: x => x.PerformedByUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateIndex(
                name: "IX_StockLogs_CreatedAt",
                table: "StockLogs",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_StockLogs_PerformedByUserId",
                table: "StockLogs",
                column: "PerformedByUserId");

            migrationBuilder.CreateIndex(
                name: "IX_StockLogs_RelatedOrderId",
                table: "StockLogs",
                column: "RelatedOrderId");

            migrationBuilder.CreateIndex(
                name: "IX_StockLogs_SupplementId",
                table: "StockLogs",
                column: "SupplementId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "StockLogs");

            migrationBuilder.DropColumn(
                name: "StockQuantity",
                table: "Supplements");
        }
    }
}
