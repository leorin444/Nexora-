using MediatR;
using Nexora.Application.Reminders.DTOs;

namespace Nexora.Application.Reminders.Queries.GetReminders;

/// <summary>Returns pending (non-completed) reminders for the authenticated user.</summary>
public sealed record GetRemindersQuery(bool IncludeCompleted = false) : IRequest<IList<ReminderDto>>;
