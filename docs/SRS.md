# Software Requirements Specification (SRS)

**Project:** Nexora (Personal & Couple Platform)  
**Version:** 1.0.0  
**Date:** 2026-10-05  
**Status:** Approved Baseline  

---

## 1. Introduction

### 1.1 Purpose
This document specifies the software requirements for **Nexora**, a private, secure, and extensible personal and couple platform. Nexora unifies personal life management, relationship interaction, knowledge curation, news aggregation, and AI-assisted communication and insights.

### 1.2 Scope
Nexora encompasses:
- A Cross-Platform Mobile Application (iOS & Android via Flutter)
- A Web Application (Flutter Web)
- An Administrator Dashboard (Blazor Server)
- A Unified Backend Web API (ASP.NET Core 10 Web API)
- A Relational Database (Microsoft SQL Server)
- Realtime Event Stream & Chat (SignalR)
- Background Processing Engine (Hangfire)
- Extensible AI Subsystem (Abstracted Provider Pipeline)

---

## 2. Overall Description

### 2.1 Product Modes
The platform operates under two primary user modes:
1. **Personal Mode**: For individual organization, private reflections, personal notes, reminders, daily reports, knowledge vault, and personal AI interactions.
2. **Couple Mode**: For paired interactions between exactly two users: shared calendars, shared notes, couple countdowns, couple chat, shared music, and partner-visible updates.

### 2.2 User Classes and Roles
- **Guest / Unauthenticated User**: Can register or log in.
- **Platform User**: Authenticated individual with personal data and optional couple membership.
- **Administrator**: System administrator with access to configuration, news sources, feature flags, and audit logs. Administrators *never* receive access to private user journals, feelings, or chats.

---

## 3. System Features & Domain Requirements

### 3.1 Identity & Access Management (IAM)
- Secure registration and login using JWT Bearer tokens (access + refresh tokens).
- User profile management.
- Multi-factor ready and secure password hashing (PBKDF2/Argon2 via ASP.NET Core Identity).
- Role-based and Resource-based access control.

### 3.2 Couple System
- Strict 1-to-1 relationship limit per active user.
- Couple invitation lifecycle: cryptographic token generation, human-readable code, QR code generation, expiration window, single-use enforcement, revocation, and acceptance.
- Relationship history preservation on disconnection or status changes.

### 3.3 Privacy & Visibility Model
- Resource visibility levels:
  - `PRIVATE`: Accessible solely by the resource owner.
  - `PARTNER_VISIBLE`: Accessible by the owner and their verified active partner.
  - `SHARED`: Shared context within the couple relationship.
- Absolute server-side policy enforcement on every read/write operation.

### 3.4 Personal Organization
- **Notes**: Rich notes with ownership and visibility tags (`Private`, `PartnerVisible`, `Shared`).
- **Reminders**: One-time and recurring reminders with scheduled notifications.
- **Calendar & Countdowns**: Events, milestones, anniversaries, and countdown tracking.
- **Daily Reflection & Reports**: Daily activity aggregation, manual reflections, and AI-driven summaries.

### 3.5 Couple Communication & Special Features
- **Couple Chat**: Realtime messaging via SignalR strictly authorized between couple partners. Message history and attachments.
- **Communication Coach**: AI-assisted empathetic communication suggestions, tone feedback, and conflict resolution practice.
- **Private Feelings**: Private emotional reflection space with explicit defaults preventing unintentional sharing.
- **Menstrual Calendar**: Cycle tracking with strict, opt-in privacy visibility controls.
- **Shared Music**: Shared couple playlists with external metadata (links/embeds) without hosting copyrighted media.

### 3.6 Knowledge Vault
- Ingestion pipeline: `CAPTURE -> INBOX -> PROCESSING -> ORGANIZE -> SEARCH -> REVIEW -> REUSE`.
- Stores metadata, URLs, personal annotations, screenshots, and documents.
- Categorization, tagging, status workflows (`Inbox`, `Processing`, `Saved`, `Important`, `Completed`, `Archived`).

### 3.7 News Platform
- Multi-sector aggregation (Technology, AI, Business, Science, World, etc.).
- Admin-configured news sources and fetch cadences.
- Background worker for ingestion, deduplication, ranking, and top 10 curation.

### 3.8 AI Subsystem
- Loose coupling via `IAIProvider`.
- Interchangeable providers (Cloud models, Local Ollama, Null fallback).
- Fault tolerance: System remains fully usable when AI is disabled or unreachable.

### 3.9 Feature Management & Admin Dashboard
- Dynamic feature flags controlled by Administrators.
- Server-side enforcement of feature flags.
- Admin dashboard for user oversight, audit logging, news settings, and health metrics.

---

## 4. Non-Functional Requirements

### 4.1 Security
- All sensitive traffic over TLS (HTTPS/WSS).
- Zero trust on client-supplied identifiers (`UserId`, `CoupleId`, `RoleId`).
- No secrets in source control (enforced via `.gitignore` and `.NET User Secrets`).

### 4.2 Performance & Scalability
- Sub-200ms p95 latency for core REST API endpoints.
- Realtime messaging latency < 100ms via SignalR.
- Resilient background task queues with retry policies in Hangfire.

### 4.3 Reliability & Availability
- Graceful degradation across third-party dependencies (AI, News feeds).
- Idempotent API operations and background jobs.
