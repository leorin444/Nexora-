import os
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable
)
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def draw_page_decorations(self, page_count):
        self.saveState()
        self.setFont("Helvetica", 9)
        self.setFillColor(colors.HexColor("#718096"))
        
        # Header (pages after cover)
        if self._pageNumber > 1:
            self.drawString(54, 750, "Nexora Platform v1.0 — Architecture, Features & IIS Hosting Guide")
            self.setStrokeColor(colors.HexColor("#E2E8F0"))
            self.setLineWidth(0.5)
            self.line(54, 742, 558, 742)
            
        # Footer
        self.drawString(54, 36, "CONFIDENTIAL & PROPRIETARY — NEXORA PLATFORM")
        page_str = f"Page {self._pageNumber} of {page_count}"
        self.drawRightString(558, 36, page_str)
        self.setStrokeColor(colors.HexColor("#E2E8F0"))
        self.setLineWidth(0.5)
        self.line(54, 48, 558, 48)
        self.restoreState()

def build_pdf(filename):
    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )

    styles = getSampleStyleSheet()
    
    # Custom styles
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=26,
        leading=32,
        textColor=colors.HexColor('#1A365D')
    )
    
    subtitle_style = ParagraphStyle(
        'DocSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=13,
        leading=18,
        textColor=colors.HexColor('#4A5568')
    )
    
    h1_style = ParagraphStyle(
        'SectionH1',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=16,
        leading=22,
        textColor=colors.HexColor('#1A365D'),
        spaceBefore=14,
        spaceAfter=6,
        keepWithNext=True
    )
    
    h2_style = ParagraphStyle(
        'SectionH2',
        parent=styles['Heading2'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=16,
        textColor=colors.HexColor('#2B6CB0'),
        spaceBefore=10,
        spaceAfter=4,
        keepWithNext=True
    )
    
    body_style = ParagraphStyle(
        'BodyDark',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9.5,
        leading=13.5,
        textColor=colors.HexColor('#2D3748'),
        spaceAfter=6
    )

    code_style = ParagraphStyle(
        'CodeSnippet',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=8.5,
        leading=11.5,
        textColor=colors.HexColor('#1A202C')
    )
    
    callout_style = ParagraphStyle(
        'CalloutText',
        parent=styles['Normal'],
        fontName='Helvetica-Oblique',
        fontSize=9,
        leading=13,
        textColor=colors.HexColor('#2C5282')
    )

    story = []

    # ─── COVER PAGE ──────────────────────────────────────────────────────────
    story.append(Spacer(1, 40))
    story.append(Paragraph("NEXORA PLATFORM", title_style))
    story.append(Paragraph("v1.0 Production System Specification, Features Guide & IIS Hosting Manual", subtitle_style))
    story.append(Spacer(1, 15))
    story.append(HRFlowable(width="100%", thickness=3, color=colors.HexColor('#2B6CB0'), spaceAfter=20))
    
    meta_table = Table([
        [Paragraph("<b>Status:</b>", body_style), Paragraph("Production Ready (v1.0.0 Tagged)", body_style)],
        [Paragraph("<b>Target Framework:</b>", body_style), Paragraph(".NET 10 (ASP.NET Core 10 Web API & Blazor Server)", body_style)],
        [Paragraph("<b>Mobile Platform:</b>", body_style), Paragraph("Flutter 3.47.1 (Dart 3.13.1)", body_style)],
        [Paragraph("<b>Database:</b>", body_style), Paragraph("Microsoft SQL Server 2022 (EF Core 10 Migrations)", body_style)],
        [Paragraph("<b>IIS Publishing:</b>", body_style), Paragraph("A:\\Projects\\Nexora\\publish\\api & \\admin", body_style)],
        [Paragraph("<b>Date:</b>", body_style), Paragraph("October 2026", body_style)],
    ], colWidths=[130, 370])
    meta_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#F7FAFC')),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor('#E2E8F0')),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('PADDING', (0,0), (-1,-1), 6),
    ]))
    story.append(meta_table)
    story.append(Spacer(1, 25))

    # Executive Summary Callout
    summary_box = Table([[
        Paragraph(
            "<b>Executive Summary:</b> Nexora is a private, secure, and extensible unified personal and couple platform. "
            "It bridges personal productivity (Notes, Reminders, Knowledge Vault), relationship intimacy "
            "(Pairing, Shared Calendars, SignalR Chat), curated intelligence (Sector News, Global Search), and "
            "AI coaching (Ollama / OpenAI / Graceful Fallback). This document provides an exhaustive breakdown of the "
            "13 engineering phases delivered and comprehensive instructions for local IIS web hosting.",
            callout_style
        )
    ]], colWidths=[500])
    summary_box.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#EBF8FF')),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor('#90CDF4')),
        ('PADDING', (0,0), (-1,-1), 10),
    ]))
    story.append(summary_box)
    story.append(PageBreak())

    # ─── SECTION 1: ARCHITECTURE OVERVIEW ──────────────────────────────────
    story.append(Paragraph("1. System Architecture & Engineering Principles", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor('#CBD5E0'), spaceAfter=10))
    story.append(Paragraph(
        "Nexora follows strict <b>Clean Architecture</b> and <b>CQRS (Command Query Responsibility Segregation)</b> patterns using MediatR. "
        "The architecture completely decouples domain entities from infrastructure persistence, ensuring modularity, testability, and enterprise maintainability.",
        body_style
    ))
    
    arch_data = [
        ["Layer", "Project", "Key Responsibilities"],
        ["Domain", "Nexora.Domain", "Entities, Enums, Value Objects (User, Note, Couple, CalendarEvent, ChatMessage, VaultItem, NewsArticle). Zero third-party dependencies."],
        ["Application", "Nexora.Application", "CQRS Handlers (MediatR), DTOs, Service Interfaces (INexoraDbContext, IAIProvider, ITokenService, ICurrentUserService)."],
        ["Infrastructure", "Nexora.Infrastructure", "EF Core DbContext, Fluent Configurations, SQL Server Migrations, SignalR Hub, Hangfire, AI Adapters (OpenAI / Null)."],
        ["Web API", "Nexora.Api", "REST Controllers, JWT authentication, Swagger UI, Global Exception Middleware, Production security headers (HSTS, CSP, X-Frame)."],
        ["Admin Portal", "Nexora.Admin", "Blazor Server administrative dashboard for metrics, feature toggling, user oversight, and audit trails."],
        ["Mobile App", "nexora_mobile", "Cross-platform Flutter application (iOS/Android/Web) with Provider state management and secure token storage."]
    ]
    arch_table = Table([[Paragraph(c, body_style) for c in row] for row in arch_data], colWidths=[80, 110, 310])
    arch_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#2B6CB0')),
        ('TEXTCOLOR', (0,0), (-1,0), colors.white),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('BOTTOMPADDING', (0,0), (-1,0), 6),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#CBD5E0')),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor('#F7FAFC')]),
        ('PADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(arch_table)
    story.append(Spacer(1, 15))

    story.append(Paragraph("Zero-Trust Security & Privacy Model", h2_style))
    story.append(Paragraph(
        "• <b>Client Untrust:</b> Client-supplied identifiers (UserId, CoupleId, AdminStatus) are strictly ignored. Identity is extracted exclusively from cryptographic JWT claims.<br/>"
        "• <b>Privacy Isolation:</b> Entities support <i>VisibilityLevel</i> (Private, Shared, PartnerVisible). Server-side queries strictly filter out partner private items (Notes, Events, Vault Secrets).<br/>"
        "• <b>Admin Segregation:</b> Administrators can view system audit logs and feature toggles, but database queries structurally forbid admin access to private user messages or journals.",
        body_style
    ))
    story.append(Spacer(1, 10))

    # ─── SECTION 2: 13 DELIVERED PHASES ────────────────────────────────────
    story.append(Paragraph("2. Complete Capabilities Matrix (Phases 0–13)", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor('#CBD5E0'), spaceAfter=10))

    phases = [
        ("Phase 0 — Product Specification", "Full specification baseline: SRS.md, ARCHITECTURE.md, SECURITY.md, DATABASE.md, DEVELOPMENT.md, and ADR-001 through ADR-005."),
        ("Phase 1 — Engineering Foundation", "Monorepo structure initialized with Git branches (main/develop), .NET 10 solution, Flutter mobile scaffold, Blazor admin, and GitHub Actions CI."),
        ("Phase 2 — Identity & Security", "JWT authentication with refresh tokens, PBKDF2 password hashing, Register/Login/RefreshToken CQRS, and Flutter login/registration screens."),
        ("Phase 3 — Platform Core", "VisibilityLevel privacy model, FeatureFlag entity with in-memory caching, FeatureFlagService, and AuditLogService for security tracking."),
        ("Phase 4 — Admin Foundation", "Blazor Server dashboard with live KPI counters, real-time feature flag toggle switches, and security audit log review table."),
        ("Phase 5 — Personal Domain Core", "Personal Notes (pinned/archived) and Reminders (due dates/recurrence). REST controllers and Flutter Notes/Reminder manager."),
        ("Phase 6 — Couple Domain", "Couple pairing workflow: 6-character claim codes, invitation acceptance, and server-enforced rule of exactly 1 active couple per user."),
        ("Phase 7 — Shared Calendar & Realtime", "Calendar events with partner visibility boundaries, SignalR NexoraHub (/hubs/nexora) with couple group broadcasts, and mobile calendar UI."),
        ("Phase 8 — Couple Realtime Chat", "ChatMessage entity with delivery tracking (Sent/Delivered/Read), chronological history pagination, SignalR push notifications, and bubble chat UI."),
        ("Phase 9 — Knowledge Vault", "Secure Documents and Secrets manager with tags, client encryption payload support, and strict partner isolation for private secrets."),
        ("Phase 10 — AI Platform & Coach", "Provider-independent IAIProvider pipeline (OpenAI / Ollama / Null fallback), Ask AI query, and empathetic Communication Coach with tone insights."),
        ("Phase 11 — News Platform", "Multi-sector news aggregation (Tech, AI, Business, Science, World), canonical URL deduplication, curation ranking, and mobile news feed with Top Story badges."),
        ("Phase 12 — Search & Intelligence", "Global unified search aggregating across Notes, Reminders, Calendar, Vault, and News with zero partner privacy leakage. Domain-typed UI chips."),
        ("Phase 13 — Production Hardening", "Multi-stage Dockerfile, docker-compose orchestration (SQL Server + API), HSTS, and HTTP security headers (X-Frame, X-Content-Type, CSP).")
    ]

    p_table_data = [["Phase", "Delivered Features & Technical Details"]]
    for title, desc in phases:
        p_table_data.append([Paragraph(f"<b>{title}</b>", body_style), Paragraph(desc, body_style)])

    p_table = Table(p_table_data, colWidths=[140, 360])
    p_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#2B6CB0')),
        ('TEXTCOLOR', (0,0), (-1,0), colors.white),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#CBD5E0')),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor('#F7FAFC')]),
        ('PADDING', (0,0), (-1,-1), 4),
    ]))
    story.append(p_table)
    story.append(PageBreak())

    # ─── SECTION 3: PUBLISHED ASSETS & STRUCTURE ───────────────────────────
    story.append(Paragraph("3. Published Binaries & Deployment Artifacts", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor('#CBD5E0'), spaceAfter=10))
    story.append(Paragraph(
        "Both backend server applications have been compiled in <b>Release mode</b> using .NET 10 and published directly for IIS hosting:",
        body_style
    ))

    pub_data = [
        ["Application", "Publish Path", "Port / Protocol", "Entry Point"],
        ["Nexora Web API", "A:\\Projects\\Nexora\\publish\\api", "HTTP 5000 / HTTPS 5001", "Nexora.Api.dll (ASP.NET Core Module v2)"],
        ["Nexora Admin", "A:\\Projects\\Nexora\\publish\\admin", "HTTP 5050 / HTTPS 5051", "Nexora.Admin.dll (Blazor Server)"],
        ["Mobile Client", "A:\\Projects\\Nexora\\mobile\\nexora_mobile", "Android / iOS / Web", "Flutter App connecting to API baseUrl"]
    ]
    pub_table = Table([[Paragraph(c, body_style) for c in row] for row in pub_data], colWidths=[90, 180, 110, 120])
    pub_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#2B6CB0')),
        ('TEXTCOLOR', (0,0), (-1,0), colors.white),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#CBD5E0')),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor('#F7FAFC')]),
        ('PADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(pub_table)
    story.append(Spacer(1, 15))

    # ─── SECTION 4: STEP-BY-STEP IIS SETUP GUIDE ───────────────────────────
    story.append(Paragraph("4. Step-by-Step IIS Hosting Guide", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor('#CBD5E0'), spaceAfter=10))

    story.append(Paragraph("Step 1: Install Required IIS Components & .NET Hosting Bundle", h2_style))
    story.append(Paragraph(
        "1. Open Windows <b>Turn Windows features on or off</b>.<br/>"
        "2. Ensure <b>Internet Information Services</b> is checked, including <b>World Wide Web Services → Application Development Features → WebSocket Protocol</b> (critical for SignalR and Blazor Server).<br/>"
        "3. Download and install the <b>ASP.NET Core 10.0 Hosting Bundle</b> from Microsoft. This installs the native <code>AspNetCoreModuleV2</code> inside IIS.<br/>"
        "4. Restart IIS by running <code>iisreset</code> in an elevated PowerShell terminal.",
        body_style
    ))
    story.append(Spacer(1, 8))

    story.append(Paragraph("Step 2: Create Application Pools in IIS Manager", h2_style))
    story.append(Paragraph(
        "Open <b>IIS Manager</b> (<code>inetmgr</code>) and create two dedicated application pools:<br/>"
        "• <b>NexoraApiPool:</b> .NET CLR Version = <code>No Managed Code</code>, Managed Pipeline Mode = <code>Integrated</code>.<br/>"
        "• <b>NexoraAdminPool:</b> .NET CLR Version = <code>No Managed Code</code>, Managed Pipeline Mode = <code>Integrated</code>.<br/>"
        "<i>Note: Setting 'No Managed Code' is mandatory for ASP.NET Core because IIS acts as a reverse proxy to Kestrel.</i>",
        body_style
    ))
    story.append(Spacer(1, 8))

    story.append(Paragraph("Step 3: Create IIS Websites or Virtual Applications", h2_style))
    story.append(Paragraph(
        "In IIS Manager under <b>Sites</b>, add the following websites (or virtual directories under Default Web Site):<br/>"
        "<b>1. Nexora Web API:</b><br/>"
        "&nbsp;&nbsp;&nbsp;• Site Name: <code>Nexora.Api</code><br/>"
        "&nbsp;&nbsp;&nbsp;• Application Pool: <code>NexoraApiPool</code><br/>"
        "&nbsp;&nbsp;&nbsp;• Physical Path: <code>A:\\Projects\\Nexora\\publish\\api</code><br/>"
        "&nbsp;&nbsp;&nbsp;• Binding: Type = <code>http</code>, Port = <code>5000</code> (or IP/hostname of choice)<br/>"
        "<br/>"
        "<b>2. Nexora Admin Portal:</b><br/>"
        "&nbsp;&nbsp;&nbsp;• Site Name: <code>Nexora.Admin</code><br/>"
        "&nbsp;&nbsp;&nbsp;• Application Pool: <code>NexoraAdminPool</code><br/>"
        "&nbsp;&nbsp;&nbsp;• Physical Path: <code>A:\\Projects\\Nexora\\publish\\admin</code><br/>"
        "&nbsp;&nbsp;&nbsp;• Binding: Type = <code>http</code>, Port = <code>5050</code>",
        body_style
    ))
    story.append(Spacer(1, 8))

    story.append(Paragraph("Step 4: Configure Folder Permissions", h2_style))
    story.append(Paragraph(
        "The IIS worker process accounts need read and execute access to the published folders:<br/>"
        "Run these commands in an elevated PowerShell terminal:",
        body_style
    ))
    
    perms_table = Table([[
        Paragraph(
            "<code>icacls \"A:\\Projects\\Nexora\\publish\\api\" /grant \"IIS AppPool\\NexoraApiPool\":(OI)(CI)RX /T<br/>"
            "icacls \"A:\\Projects\\Nexora\\publish\\admin\" /grant \"IIS AppPool\\NexoraAdminPool\":(OI)(CI)RX /T</code>",
            code_style
        )
    ]], colWidths=[500])
    perms_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#EDF2F7')),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor('#CBD5E0')),
        ('PADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(perms_table)
    story.append(Spacer(1, 8))

    story.append(Paragraph("Step 5: Configure SQL Server Database Connection & Secrets", h2_style))
    story.append(Paragraph(
        "In <code>A:\\Projects\\Nexora\\publish\\api\\appsettings.json</code> (or via IIS Environment Variables):<br/>"
        "1. Verify <code>ConnectionStrings:DefaultConnection</code> points to your SQL Server instance.<br/>"
        "2. Provide your secure <code>Jwt:SecretKey</code> (minimum 32 characters).<br/>"
        "3. On first startup, the API will automatically execute pending EF Core migrations and seed initial roles and feature flags.",
        body_style
    ))
    story.append(PageBreak())

    # ─── SECTION 5: USER GUIDE & HOW TO TEST ────────────────────────────────
    story.append(Paragraph("5. User Guide: How to Use and Test the Platform", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor('#CBD5E0'), spaceAfter=10))

    story.append(Paragraph("A. Testing the Web API", h2_style))
    story.append(Paragraph(
        "1. Open your browser and navigate to <code>http://localhost:5000/health</code>. You should receive an <code>Healthy</code> status confirming database connectivity.<br/>"
        "2. To explore endpoints, navigate to <code>http://localhost:5000/swagger</code> (when in Development) or use Postman to test:<br/>"
        "&nbsp;&nbsp;&nbsp;• <code>POST /api/auth/register</code> — Register a user.<br/>"
        "&nbsp;&nbsp;&nbsp;• <code>POST /api/auth/login</code> — Obtain JWT Bearer token.<br/>"
        "&nbsp;&nbsp;&nbsp;• <code>GET /api/notes</code>, <code>GET /api/calendar</code>, <code>GET /api/vault</code>, <code>GET /api/news</code>, <code>GET /api/search?q=...</code>",
        body_style
    ))
    story.append(Spacer(1, 8))

    story.append(Paragraph("B. Accessing the Blazor Admin Portal", h2_style))
    story.append(Paragraph(
        "1. Navigate to <code>http://localhost:5050</code> in your browser.<br/>"
        "2. View the system dashboard showing total users, active couples, system health, and Hangfire job status.<br/>"
        "3. Use the <b>Feature Flags</b> panel to toggle flags on/off dynamically with immediate server-side enforcement.",
        body_style
    ))
    story.append(Spacer(1, 8))

    story.append(Paragraph("C. Running the Flutter Mobile App", h2_style))
    story.append(Paragraph(
        "From the workspace terminal, launch the mobile client against your local IIS backend:<br/>"
        "<code>cd mobile/nexora_mobile<br/>flutter run -d chrome (or android emulator)</code><br/>"
        "<br/>"
        "<b>Core Mobile Workflows to Experience:</b><br/>"
        "• <b>Personal Mode:</b> Create personal notes and set due-date reminders.<br/>"
        "• <b>Couple Pairing:</b> Generate an invite code from Partner 1, switch to Partner 2, and enter the code to pair.<br/>"
        "• <b>Realtime Chat & Calendar:</b> Exchange SignalR messages with instant push updates and schedule shared events.<br/>"
        "• <b>Knowledge Vault:</b> Store private passwords or shared lease documents with granular privacy tags.<br/>"
        "• <b>AI Communication Coach:</b> Type an emotional message and receive empathetic phrasing suggestions.<br/>"
        "• <b>Curated News & Global Search:</b> Browse multi-sector articles and use unified search across all domains.",
        body_style
    ))
    story.append(Spacer(1, 15))

    # Support / Next Steps Box
    next_box = Table([[
        Paragraph(
            "<b>What's Next?</b><br/>"
            "• <b>SSL Certificate:</b> Bind an HTTPS certificate (e.g. via Win-ACME / Let's Encrypt) to your IIS sites for production encryption.<br/>"
            "• <b>CI/CD Deployment:</b> Connect the GitHub Actions workflow in <code>.github/workflows/ci.yml</code> to automatically deploy published artifacts upon merge to <code>main</code>.<br/>"
            "• <b>Mobile Store Release:</b> Run <code>flutter build apk --release</code> or <code>flutter build appbundle</code> for Google Play and TestFlight distribution.",
            body_style
        )
    ]], colWidths=[500])
    next_box.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#F0FFF4')),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor('#68D391')),
        ('PADDING', (0,0), (-1,-1), 10),
    ]))
    story.append(next_box)

    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"PDF successfully built: {filename}")

if __name__ == '__main__':
    out_path = os.path.abspath('docs/NEXORA_PLATFORM_SPECIFICATION_AND_SETUP_GUIDE.pdf')
    build_pdf(out_path)
