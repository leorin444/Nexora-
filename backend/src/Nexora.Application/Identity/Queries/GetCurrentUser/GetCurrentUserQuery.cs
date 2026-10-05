using MediatR;
using Nexora.Application.Identity.DTOs;

namespace Nexora.Application.Identity.Queries.GetCurrentUser;

/// <summary>Returns the profile of the currently authenticated user.</summary>
public sealed record GetCurrentUserQuery : IRequest<UserProfileDto>;
