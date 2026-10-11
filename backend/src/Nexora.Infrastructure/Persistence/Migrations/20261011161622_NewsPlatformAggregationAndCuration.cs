using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Nexora.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class NewsPlatformAggregationAndCuration : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "NewsArticles",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Url = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: false),
                    Title = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    Summary = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: false),
                    Content = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SourceName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    ImageUrl = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    Category = table.Column<int>(type: "int", nullable: false),
                    CurationScore = table.Column<double>(type: "float", nullable: false),
                    IsTopStory = table.Column<bool>(type: "bit", nullable: false),
                    PublishedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IngestedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_NewsArticles", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_NewsArticles_Category",
                table: "NewsArticles",
                column: "Category");

            migrationBuilder.CreateIndex(
                name: "IX_NewsArticles_IsTopStory",
                table: "NewsArticles",
                column: "IsTopStory");

            migrationBuilder.CreateIndex(
                name: "IX_NewsArticles_IsTopStory_CurationScore_PublishedAtUtc",
                table: "NewsArticles",
                columns: new[] { "IsTopStory", "CurationScore", "PublishedAtUtc" });

            migrationBuilder.CreateIndex(
                name: "IX_NewsArticles_Url",
                table: "NewsArticles",
                column: "Url",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "NewsArticles");
        }
    }
}
