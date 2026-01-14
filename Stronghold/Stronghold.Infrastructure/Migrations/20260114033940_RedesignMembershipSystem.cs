using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Stronghold.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class RedesignMembershipSystem : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_MembershipPackages_Users_UserId",
                table: "MembershipPackages");

            migrationBuilder.DropTable(
                name: "MembershipPayments");

            migrationBuilder.DropIndex(
                name: "IX_MembershipPackages_UserId",
                table: "MembershipPackages");

            migrationBuilder.DropColumn(
                name: "EndDate",
                table: "MembershipPackages");

            migrationBuilder.DropColumn(
                name: "StartDate",
                table: "MembershipPackages");

            migrationBuilder.DropColumn(
                name: "UserId",
                table: "MembershipPackages");

            migrationBuilder.RenameColumn(
                name: "Price",
                table: "MembershipPackages",
                newName: "PackagePrice");

            migrationBuilder.RenameColumn(
                name: "Name",
                table: "MembershipPackages",
                newName: "PackageName");

            migrationBuilder.AlterColumn<string>(
                name: "Description",
                table: "MembershipPackages",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(500)",
                oldMaxLength: 500,
                oldNullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsActive",
                table: "MembershipPackages",
                type: "bit",
                nullable: false,
                defaultValue: true);

            migrationBuilder.CreateTable(
                name: "MembershipPaymentHistory",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    MembershipPackageId = table.Column<int>(type: "int", nullable: false),
                    AmountPaid = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    PaymentDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    StartDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EndDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MembershipPaymentHistory", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MembershipPaymentHistory_MembershipPackages_MembershipPackageId",
                        column: x => x.MembershipPackageId,
                        principalTable: "MembershipPackages",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MembershipPaymentHistory_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Memberships",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    MembershipPackageId = table.Column<int>(type: "int", nullable: false),
                    StartDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EndDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Memberships", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Memberships_MembershipPackages_MembershipPackageId",
                        column: x => x.MembershipPackageId,
                        principalTable: "MembershipPackages",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Memberships_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_MembershipPaymentHistory_MembershipPackageId",
                table: "MembershipPaymentHistory",
                column: "MembershipPackageId");

            migrationBuilder.CreateIndex(
                name: "IX_MembershipPaymentHistory_UserId",
                table: "MembershipPaymentHistory",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Memberships_MembershipPackageId",
                table: "Memberships",
                column: "MembershipPackageId");

            migrationBuilder.CreateIndex(
                name: "IX_Memberships_UserId",
                table: "Memberships",
                column: "UserId",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "MembershipPaymentHistory");

            migrationBuilder.DropTable(
                name: "Memberships");

            migrationBuilder.DropColumn(
                name: "IsActive",
                table: "MembershipPackages");

            migrationBuilder.RenameColumn(
                name: "PackagePrice",
                table: "MembershipPackages",
                newName: "Price");

            migrationBuilder.RenameColumn(
                name: "PackageName",
                table: "MembershipPackages",
                newName: "Name");

            migrationBuilder.AlterColumn<string>(
                name: "Description",
                table: "MembershipPackages",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(500)",
                oldMaxLength: 500);

            migrationBuilder.AddColumn<DateTime>(
                name: "EndDate",
                table: "MembershipPackages",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "StartDate",
                table: "MembershipPackages",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<int>(
                name: "UserId",
                table: "MembershipPackages",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "MembershipPayments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MembershipPackageId = table.Column<int>(type: "int", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Amount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    PaymentDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MembershipPayments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MembershipPayments_MembershipPackages_MembershipPackageId",
                        column: x => x.MembershipPackageId,
                        principalTable: "MembershipPackages",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MembershipPayments_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_MembershipPackages_UserId",
                table: "MembershipPackages",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_MembershipPayments_MembershipPackageId",
                table: "MembershipPayments",
                column: "MembershipPackageId");

            migrationBuilder.CreateIndex(
                name: "IX_MembershipPayments_UserId",
                table: "MembershipPayments",
                column: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_MembershipPackages_Users_UserId",
                table: "MembershipPackages",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
