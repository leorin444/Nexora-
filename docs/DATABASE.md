# Database Architecture & Design Guide

**Project:** Nexora  
**Engine:** Microsoft SQL Server 2022+  
**ORM:** Entity Framework Core 10  
**Migration Strategy:** Code-First via EF Core Migrations  

---

## 1. Design Principles

1. **UTC Everywhere**: All timestamp columns (`CreatedAtUtc`, `UpdatedAtUtc`, `DeletedAtUtc`, `ScheduledForUtc`) must be stored in UTC (`datetime2`).
2. **Audit & Soft Deletion**: Entity roots implement `IAuditableEntity` and `ISoftDeletable` where appropriate to prevent accidental or permanent data loss.
3. **No Orphaned Records**: Enforce foreign keys with cascading rules or explicit restriction logic.
4. **Tenant / User Isolation**: Every user record has an `OwnerId` or explicit foreign key link. Queries must be scoped to the authenticated caller.
5. **No Secrets in Schema**: Do not store passwords (only cryptographic hashes/salts), tokens (only hashes/jti), or credentials in plaintext.

---

## 2. Core Schemas & Entity Groups

### 2.1 Identity & Users (`identity` / `users`)
- `Users`: `Id (Guid, PK)`, `Email (nvarchar, Unique)`, `PasswordHash`, `FirstName`, `LastName`, `ProfilePictureUrl`, `CreatedAtUtc`, `UpdatedAtUtc`, `IsActive`
- `Roles`: `Id (Guid, PK)`, `Name (nvarchar, Unique)`
- `UserRoles`: `UserId (FK)`, `RoleId (FK)`
- `RefreshTokens`: `Id (Guid, PK)`, `UserId (FK)`, `TokenHash (nvarchar)`, `ExpiresAtUtc`, `RevokedAtUtc`, `ReplacedByTokenHash`

### 2.2 Couples (`couples`)
- `Couples`: `Id (Guid, PK)`, `User1Id (Guid, FK)`, `User2Id (Guid, FK)`, `EstablishedAtUtc`, `Status (int: Active, Paused, Dissolved)`
- `CoupleInvitations`: `Id (Guid, PK)`, `SenderUserId (Guid, FK)`, `InvitationCode (nvarchar, Indexed)`, `TokenHash (nvarchar)`, `ExpiresAtUtc`, `IsUsed (bit)`, `UsedByUserId (Guid, Nullable FK)`

### 2.3 Personal & Shared Content (`content`)
- `Notes`: `Id (Guid, PK)`, `OwnerId (Guid, FK)`, `CoupleId (Guid, Nullable FK)`, `Title`, `Content`, `Visibility (int: Private, PartnerVisible, Shared)`, `CreatedAtUtc`, `UpdatedAtUtc`
- `Reminders`: `Id (Guid, PK)`, `OwnerId (Guid, FK)`, `CoupleId (Guid, Nullable FK)`, `Title`, `DueTimeUtc`, `RecurrencePattern`, `IsCompleted`, `Visibility`
- `Events`: `Id (Guid, PK)`, `OwnerId (Guid, FK)`, `CoupleId (Guid, Nullable FK)`, `Title`, `StartUtc`, `EndUtc`, `IsCountdown`, `Visibility`
- `DailyReflections`: `Id (Guid, PK)`, `UserId (Guid, FK)`, `Date (date)`, `Content`, `Mood`, `CreatedAtUtc`

### 2.4 Realtime Chat (`chat`)
- `CoupleConversations`: `Id (Guid, PK)`, `CoupleId (Guid, FK, Unique)`, `CreatedAtUtc`
- `ChatMessages`: `Id (Guid, PK)`, `ConversationId (Guid, FK)`, `SenderUserId (Guid, FK)`, `Content`, `SentAtUtc`, `ReadAtUtc`, `IsDeleted`

### 2.5 Knowledge Vault (`knowledge`)
- `VaultItems`: `Id (Guid, PK)`, `OwnerId (Guid, FK)`, `Title`, `SourceUrl`, `ItemType (Url, Note, Screenshot, Document)`, `RawContent`, `Summary`, `Status (int: Inbox, Processing, Saved, Important, Completed, Archived)`, `CreatedAtUtc`
- `VaultTags`: `Id (Guid, PK)`, `Name`
- `VaultItemTags`: `VaultItemId (Guid, FK)`, `TagId (Guid, FK)`

### 2.6 News Aggregation (`news`)
- `NewsSectors`: `Id (Guid, PK)`, `Name`, `Slug`, `IsEnabled`
- `NewsSources`: `Id (Guid, PK)`, `SectorId (Guid, FK)`, `Name`, `FeedUrl`, `FetchIntervalMinutes`, `LastFetchedAtUtc`
- `NewsArticles`: `Id (Guid, PK)`, `SourceId (Guid, FK)`, `SectorId (Guid, FK)`, `Title`, `Url`, `Summary`, `PublishedAtUtc`, `RankScore`

### 2.7 Administration & Audit (`admin`)
- `AuditLogs`: `Id (Guid, PK)`, `UserId (Guid, Nullable FK)`, `Action`, `EntityName`, `EntityId`, `OldValues`, `NewValues`, `IpAddress`, `TimestampUtc`
- `FeatureFlags`: `Id (Guid, PK)`, `Key (nvarchar, Unique)`, `IsEnabled (bit)`, `Description`, `UpdatedByUserId (Guid, Nullable FK)`, `UpdatedAtUtc`

---

## 3. Database Migration Workflow

1. Update domain models in `Nexora.Domain`.
2. Configure entity type mappings in `Nexora.Infrastructure/Persistence/Configurations`.
3. Generate migration:
   ```bash
   dotnet ef migrations add <MigrationName> --project src/Nexora.Infrastructure --startup-project src/Nexora.Api --output-dir Persistence/Migrations
   ```
4. Apply migration to local development database:
   ```bash
   dotnet ef database update --project src/Nexora.Infrastructure --startup-project src/Nexora.Api
   ```
