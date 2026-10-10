using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Nexora.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class CoupleSystemInvitationsAndRelationships : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "CoupleInvitations",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    SenderId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    InvitationCode = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    ExpiresAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    AcceptedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    AcceptedByUserId = table.Column<Guid>(type: "uniqueidentifier", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CoupleInvitations", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Couples",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Partner1Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Partner2Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    ConnectedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EndedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Couples", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_CoupleInvitations_InvitationCode",
                table: "CoupleInvitations",
                column: "InvitationCode",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_CoupleInvitations_SenderId",
                table: "CoupleInvitations",
                column: "SenderId");

            migrationBuilder.CreateIndex(
                name: "IX_CoupleInvitations_SenderId_Status",
                table: "CoupleInvitations",
                columns: new[] { "SenderId", "Status" });

            migrationBuilder.CreateIndex(
                name: "IX_Couples_Partner1Id",
                table: "Couples",
                column: "Partner1Id");

            migrationBuilder.CreateIndex(
                name: "IX_Couples_Partner1Id_Status",
                table: "Couples",
                columns: new[] { "Partner1Id", "Status" });

            migrationBuilder.CreateIndex(
                name: "IX_Couples_Partner2Id",
                table: "Couples",
                column: "Partner2Id");

            migrationBuilder.CreateIndex(
                name: "IX_Couples_Partner2Id_Status",
                table: "Couples",
                columns: new[] { "Partner2Id", "Status" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CoupleInvitations");

            migrationBuilder.DropTable(
                name: "Couples");
        }
    }
}
