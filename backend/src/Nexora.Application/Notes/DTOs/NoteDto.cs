using Nexora.Domain.Common;

namespace Nexora.Application.Notes.DTOs;

public sealed record NoteDto(
    Guid Id,
    string Title,
    string Content,
    bool IsPinned,
    VisibilityLevel Visibility,
    bool IsArchived,
    DateTime CreatedAtUtc,
    DateTime UpdatedAtUtc);
