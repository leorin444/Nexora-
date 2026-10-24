import sys
import os
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable
)
from reportlab.pdfgen import canvas

# ─── Numbered Canvas for Dynamic "Page X of Y" and Running Headers ────────────
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
        if self._pageNumber == 1:
            # Suppress header and footer on cover page
            return

        self.saveState()
        self.setFont("Helvetica", 8)
        self.setFillColor(colors.HexColor("#64748B"))

        # Running Header
        self.drawString(45, 11 * 72 - 36, "NEXORA MOBILE APPLICATION — USER GUIDE & REFERENCE MANUAL")
        self.drawRightString(8.5 * 72 - 45, 11 * 72 - 36, "PHASE 1 FOUNDATION")
        self.setStrokeColor(colors.HexColor("#E2E8F0"))
        self.setLineWidth(0.75)
        self.line(45, 11 * 72 - 42, 8.5 * 72 - 45, 11 * 72 - 42)

        # Running Footer
        self.line(45, 45, 8.5 * 72 - 45, 45)
        self.drawString(45, 32, "CONFIDENTIAL & PRIVATE — FOR AUTHORIZED USERS ONLY")
        page_str = f"Page {self._pageNumber} of {page_count}"
        self.drawRightString(8.5 * 72 - 45, 32, page_str)
        self.restoreState()


def create_callout(title, text, style_title, style_body, bg_color="#EEF2FF", border_color="#6366F1"):
    content = [
        Paragraph(f"<b>{title}</b>", style_title),
        Spacer(1, 4),
        Paragraph(text, style_body),
    ]
    t = Table([[content]], colWidths=[522])
    t.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor(bg_color)),
        ('LEFTPADDING', (0, 0), (-1, -1), 14),
        ('RIGHTPADDING', (0, 0), (-1, -1), 14),
        ('TOPPADDING', (0, 0), (-1, -1), 10),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 10),
        ('LINELEFT', (0, 0), (-1, -1), 3.5, colors.HexColor(border_color)),
        ('BOX', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
    ]))
    return t


def generate_guide(output_pdf_path):
    doc = SimpleDocTemplate(
        output_pdf_path,
        pagesize=letter,
        leftMargin=45,
        rightMargin=45,
        topMargin=54,
        bottomMargin=54
    )

    styles = getSampleStyleSheet()

    # Custom typography
    c_primary = colors.HexColor("#4338CA")
    c_dark = colors.HexColor("#0F172A")
    c_muted = colors.HexColor("#475569")
    c_couple = colors.HexColor("#E11D48")

    title_style = ParagraphStyle(
        'CoverTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=28,
        leading=34,
        textColor=c_dark,
        alignment=0
    )

    subtitle_style = ParagraphStyle(
        'CoverSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=13,
        leading=18,
        textColor=c_primary,
        alignment=0
    )

    h1_style = ParagraphStyle(
        'CustomH1',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        textColor=c_primary,
        spaceBefore=14,
        spaceAfter=8,
        keepWithNext=True
    )

    h2_style = ParagraphStyle(
        'CustomH2',
        parent=styles['Heading2'],
        fontName='Helvetica-Bold',
        fontSize=13,
        leading=17,
        textColor=c_dark,
        spaceBefore=10,
        spaceAfter=5,
        keepWithNext=True
    )

    body_style = ParagraphStyle(
        'CustomBody',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9.5,
        leading=14.5,
        textColor=c_muted,
        spaceAfter=6
    )

    bullet_style = ParagraphStyle(
        'CustomBullet',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9.5,
        leading=14,
        textColor=c_muted,
        leftIndent=14,
        spaceAfter=3
    )

    callout_title = ParagraphStyle(
        'CalloutTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=10,
        leading=13,
        textColor=colors.HexColor("#312E81")
    )

    callout_body = ParagraphStyle(
        'CalloutBody',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9,
        leading=13.5,
        textColor=colors.HexColor("#374151")
    )

    story = []

    # ═══════════════════════════════════════════════════════════════════════════
    # COVER PAGE
    # ═══════════════════════════════════════════════════════════════════════════
    story.append(Spacer(1, 40))

    # Decorative pill badge
    badge_data = [[Paragraph("<font color='#4338CA'><b>OFFICIAL SYSTEM DOCUMENTATION</b></font>", ParagraphStyle('b', fontName='Helvetica-Bold', fontSize=9, textColor=c_primary))]]
    badge_table = Table(badge_data, colWidths=[200])
    badge_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#EEF2FF")),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('BOX', (0, 0), (-1, -1), 1, colors.HexColor("#C7D2FE")),
    ]))
    story.append(badge_table)
    story.append(Spacer(1, 20))

    story.append(Paragraph("Nexora Mobile Application", title_style))
    story.append(Spacer(1, 6))
    story.append(Paragraph("Complete Architecture, User Manual & Operational Reference", subtitle_style))
    story.append(Spacer(1, 10))

    story.append(HRFlowable(width="100%", thickness=2.5, color=c_primary, spaceBefore=4, spaceAfter=20))

    cover_meta = [
        [Paragraph("<b>Platform:</b>", body_style), Paragraph("Nexora Personal & Couple Synchronized Suite", body_style)],
        [Paragraph("<b>Client Architecture:</b>", body_style), Paragraph("Flutter 3.x / Dart (Cross-Platform Mobile)", body_style)],
        [Paragraph("<b>Backend Engine:</b>", body_style), Paragraph("ASP.NET Core 10 Web API + SignalR Real-Time Hub", body_style)],
        [Paragraph("<b>Security & Privacy:</b>", body_style), Paragraph("Zero-Knowledge Vault, 3-Tier Granular Visibility, JWT Bearer", body_style)],
        [Paragraph("<b>Document Version:</b>", body_style), Paragraph("Version 1.0 (Phase 1 Engineering Foundation)", body_style)],
        [Paragraph("<b>Classification:</b>", body_style), Paragraph("Private, Secure & Restricted Distribution", body_style)],
    ]
    t_meta = Table(cover_meta, colWidths=[140, 382])
    t_meta.setStyle(TableStyle([
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('LINEBELOW', (0, 0), (-1, -1), 0.5, colors.HexColor("#F1F5F9")),
    ]))
    story.append(t_meta)
    story.append(Spacer(1, 25))

    # Executive Summary Card
    exec_text = (
        "<b>Nexora</b> is a private, extensible executive platform designed as a centralized sanctuary for personal "
        "organization and intimate couple synchronization. The mobile application delivers seamless real-time "
        "collaboration—encompassing notes, shared calendar, encrypted couple chat, a zero-knowledge secret vault, "
        "and an AI-powered empathy and communication coach—while strictly upholding sovereign data privacy."
    )
    story.append(create_callout("EXECUTIVE SUMMARY", exec_text, callout_title, callout_body, "#F8FAFC", "#4338CA"))

    story.append(PageBreak())

    # ═══════════════════════════════════════════════════════════════════════════
    # SECTION 1: ARCHITECTURAL PRINCIPLES & PRIVACY MODEL
    # ═══════════════════════════════════════════════════════════════════════════
    story.append(Paragraph("1. Core Architectural & Privacy Foundations", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor("#CBD5E1"), spaceBefore=2, spaceAfter=10))

    story.append(Paragraph(
        "Nexora's engineering foundation is built around unconditional data sovereignty. Unlike standard shared apps, "
        "every single entity in the Nexora database adheres to a strict visibility policy enforced on the server:",
        body_style
    ))

    vis_data = [
        [Paragraph("<b>Visibility Tier</b>", callout_title), Paragraph("<b>Scope & Accessibility</b>", callout_title), Paragraph("<b>Security Enforcement</b>", callout_title)],
        [
            Paragraph("<font color='#4338CA'><b>PRIVATE (0)</b></font>", body_style),
            Paragraph("Accessible exclusively by the resource owner. Strictly hidden from partner, guests, and system administrators.", body_style),
            Paragraph("Enforced via user ID token claim matching at DB query layer.", body_style)
        ],
        [
            Paragraph("<font color='#E11D48'><b>PARTNER VISIBLE (1)</b></font>", body_style),
            Paragraph("Visible to the owner and their linked couple partner. Read-only or collaborative as designated.", body_style),
            Paragraph("Verified via active couple relationship lookup in cache/DB.", body_style)
        ],
        [
            Paragraph("<font color='#059669'><b>SHARED / DUO (2)</b></font>", body_style),
            Paragraph("Co-owned couple asset. Real-time synchronization and bi-directional edit access across both devices.", body_style),
            Paragraph("SignalR channel broadcast restricted to verified couple room.", body_style)
        ],
    ]
    t_vis = Table(vis_data, colWidths=[120, 240, 162])
    t_vis.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#F1F5F9")),
        ('BOX', (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
    ]))
    story.append(t_vis)
    story.append(Spacer(1, 12))

    story.append(create_callout(
        "CRITICAL SECURITY RULE",
        "System administrators have <b>NO ACCESS</b> to private notes, couple messages, or vault secrets. "
        "Administrative capabilities in Nexora are strictly restricted to system health, feature flag toggles, "
        "and audit log compliance monitoring.",
        callout_title, callout_body, "#FEF2F2", "#EF4444"
    ))
    story.append(Spacer(1, 14))

    # ═══════════════════════════════════════════════════════════════════════════
    # SECTION 2: AUTHENTICATION & SESSION LIFECYCLE
    # ═══════════════════════════════════════════════════════════════════════════
    story.append(Paragraph("2. Authentication & Onboarding Flow", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor("#CBD5E1"), spaceBefore=2, spaceAfter=10))

    story.append(Paragraph(
        "The mobile app manages identity through a secure, non-custodial token storage architecture:",
        body_style
    ))

    story.append(Paragraph("<b>• Account Registration:</b> New users register with First Name, Last Name, Email, and strong password. Passwords are salted and hashed on the backend using ASP.NET Core Identity PBKDF2 with 100,000 iterations.", bullet_style))
    story.append(Paragraph("<b>• Login & Token Issuance:</b> Upon successful login, the API returns a short-lived JWT access token (15-minute lifetime) and a cryptographically secure refresh token (7-day validity).", bullet_style))
    story.append(Paragraph("<b>• Secure Persistence:</b> Tokens are stored in encrypted device storage via <font face='Courier'>TokenStorage</font>. On launch, <font face='Courier'>AuthProvider</font> automatically validates existing tokens and restores session state silently.", bullet_style))
    story.append(Paragraph("<b>• Automatic Token Rotation:</b> When the access token expires, API requests trigger transparent refresh rotation to maintain seamless user experience without interruptions.", bullet_style))
    story.append(Paragraph("<b>• Instant Logout:</b> Logging out invalidates the server-side refresh token and immediately purges local caches and tokens.", bullet_style))
    story.append(Spacer(1, 14))

    # ═══════════════════════════════════════════════════════════════════════════
    # SECTION 3: HOME DASHBOARD — BENTO GRID EXECUTIVE COCKPIT
    # ═══════════════════════════════════════════════════════════════════════════
    story.append(Paragraph("3. Home Dashboard (The Bento Grid Cockpit)", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor("#CBD5E1"), spaceBefore=2, spaceAfter=10))

    story.append(Paragraph(
        "The primary landing screen utilizes an Apple-style Bento Grid design system, consolidating high-density personal "
        "and couple metrics into an intuitive, responsive executive dashboard:",
        body_style
    ))

    bento_features = [
        [Paragraph("<b>Component</b>", callout_title), Paragraph("<b>Functionality & Actions</b>", callout_title)],
        [
            Paragraph("<b>Header Bar</b>", body_style),
            Paragraph("Displays user avatar with real-time green connection pulse, personalized time-of-day greeting (Morning/Afternoon/Evening), universal search button, and instant logout.", body_style)
        ],
        [
            Paragraph("<b>Couple Space Hero</b>", body_style),
            Paragraph("Full-width gradient card with milestone counter (<i>'Day X Together'</i>), partner avatar link, and direct one-tap shortcut to the real-time E2EE Duo Chat.", body_style)
        ],
        [
            Paragraph("<b>Notes Bento Card</b>", body_style),
            Paragraph("Displays total notes count, pinned note title, and one-tap (+) quick note creation button.", body_style)
        ],
        [
            Paragraph("<b>Calendar Bento Card</b>", body_style),
            Paragraph("Highlights next upcoming agenda item, privacy level indicator (Private vs Duo), and event time.", body_style)
        ],
        [
            Paragraph("<b>AI Compass Card</b>", body_style),
            Paragraph("Contextual assistant shortcuts: <i>'Draft dinner invite'</i> and <i>'Tone check draft'</i> with one-tap suggestions.", body_style)
        ],
        [
            Paragraph("<b>Vault & News Mini-Cards</b>", body_style),
            Paragraph("Vault preview with masked secret indicator (••••••••) and live news ticker highlighting latest curated headlines.", body_style)
        ],
    ]
    t_bento = Table(bento_features, colWidths=[150, 372])
    t_bento.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#F1F5F9")),
        ('BOX', (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
    ]))
    story.append(t_bento)

    story.append(PageBreak())

    # ═══════════════════════════════════════════════════════════════════════════
    # SECTION 4: COUPLE SPACE & PAIRING SYSTEM
    # ═══════════════════════════════════════════════════════════════════════════
    story.append(Paragraph("4. Couple Space & Mutual Cryptographic Pairing", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor("#CBD5E1"), spaceBefore=2, spaceAfter=10))

    story.append(Paragraph(
        "Nexora's couple architecture enforces strict 1:1 monogamous pairing. Users cannot accidentally link "
        "multiple accounts, ensuring an exclusive private sanctuary. The screen operates in two dynamic states:",
        body_style
    ))

    story.append(Paragraph("State A: Unpaired Setup Workflow", h2_style))
    story.append(Paragraph("<b>1. Generate Invite Code:</b> Partner A taps <i>'Generate Invite Code'</i>. The backend creates an alphanumeric single-use token (e.g. <font face='Courier'>NEX-7K9M2P</font>) with a strict 48-hour expiration window.", bullet_style))
    story.append(Paragraph("<b>2. Share Securely:</b> Partner A taps the copy icon to transfer the invitation code out-of-band via secure messenger or in-person.", bullet_style))
    story.append(Paragraph("<b>3. Enter Code & Bond:</b> Partner B inputs the invite key into <i>'Enter Partner\\'s Code'</i> and taps <i>'Connect Couple'</i>. Both accounts instantly transition into a mutually synchronized relationship.", bullet_style))
    story.append(Spacer(1, 6))

    story.append(Paragraph("State B: Paired Couple Hub", h2_style))
    story.append(Paragraph("Once paired, the screen transitions to the active Couple Hub featuring:", body_style))
    story.append(Paragraph("• <b>Celebration Header:</b> Highlights mutual names and date of connection.", bullet_style))
    story.append(Paragraph("• <b>Days Together Milestone Counter:</b> Dynamic calculated live counter tracking relationship duration.", bullet_style))
    story.append(Paragraph("• <b>Encrypted Link Status:</b> Live SignalR connection status verifying mutual channel encryption.", bullet_style))
    story.append(Paragraph("• <b>Dedicated Duo Actions:</b> Direct launchpads for Couple Chat and Shared Duo Calendar.", bullet_style))
    story.append(Spacer(1, 14))

    # ═══════════════════════════════════════════════════════════════════════════
    # SECTION 5: PERSONAL & SHARED NOTES
    # ═══════════════════════════════════════════════════════════════════════════
    story.append(Paragraph("5. Personal Notes & Knowledge Capture", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor("#CBD5E1"), spaceBefore=2, spaceAfter=10))

    story.append(Paragraph(
        "The Notes module offers full Markdown authoring, rich metadata tagging, and granular sharing controls:",
        body_style
    ))

    story.append(Paragraph("• <b>Pinning & Organization:</b> Pin high-priority notes to top of feed and Home dashboard.", bullet_style))
    story.append(Paragraph("• <b>Visibility Selector:</b> Choose whether a note is Private, Partner-Visible (read-only for partner), or Shared (co-authored).", bullet_style))
    story.append(Paragraph("• <b>Search & Filter Tabs:</b> Filter by visibility badge (All, Private, Duo) and real-time keyword search.", bullet_style))
    story.append(Paragraph("• <b>Haptic Feedback & Swipe Actions:</b> Seamless swipe-to-archive and quick delete interactions.", bullet_style))
    story.append(Spacer(1, 14))

    # ═══════════════════════════════════════════════════════════════════════════
    # SECTION 6: REAL-TIME COUPLE CHAT (SIGNALR)
    # ═══════════════════════════════════════════════════════════════════════════
    story.append(Paragraph("6. Real-Time Couple Chat (SignalR WebSockets)", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor("#CBD5E1"), spaceBefore=2, spaceAfter=10))

    story.append(Paragraph(
        "The built-in chat engine provides zero-latency messaging between paired partners:",
        body_style
    ))

    chat_specs = [
        [Paragraph("<b>Capability</b>", callout_title), Paragraph("<b>Technical Specification</b>", callout_title)],
        [Paragraph("Protocol", body_style), Paragraph("ASP.NET Core SignalR WebSockets with automatic fallback to Server-Sent Events / Long Polling.", body_style)],
        [Paragraph("Channel Security", body_style), Paragraph("Room IDs are mapped to Couple ID hash; non-members are rejected server-side with HTTP 403.", body_style)],
        [Paragraph("Message Lifecycle", body_style), Paragraph("Persisted in SQL Server with UTC timestamping, soft delete support, and instant delivery receipts.", body_style)],
        [Paragraph("UI UX Flow", body_style), Paragraph("Auto-scrolling message list, bubble alignments (owner on right, partner on left), and timestamp badges.", body_style)],
    ]
    t_chat = Table(chat_specs, colWidths=[140, 382])
    t_chat.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#F1F5F9")),
        ('BOX', (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
    ]))
    story.append(t_chat)

    story.append(PageBreak())

    # ═══════════════════════════════════════════════════════════════════════════
    # SECTION 7: KNOWLEDGE VAULT (ENCRYPTED SECRET STORE)
    # ═══════════════════════════════════════════════════════════════════════════
    story.append(Paragraph("7. Knowledge Vault (Zero-Exposure Secret Store)", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor("#CBD5E1"), spaceBefore=2, spaceAfter=10))

    story.append(Paragraph(
        "The Knowledge Vault safeguards sensitive items such as passwords, banking recovery keys, identity papers, "
        "and emergency pins:",
        body_style
    ))

    story.append(Paragraph("• <b>Item Categorization:</b> Classify items under Documents, Passwords, Payment Cards, or Custom Secrets.", bullet_style))
    story.append(Paragraph("• <b>Masked Previews:</b> Secret payloads are never shown in plaintext on list views (rendered as <font face='Courier'>••••••••</font>).", bullet_style))
    story.append(Paragraph("• <b>One-Tap Decrypt & Copy:</b> Tap eye icon to unmask value; tap copy to securely copy to clipboard with instant confirmation toast.", bullet_style))
    story.append(Paragraph("• <b>Duo Shared Secrets:</b> Mark critical home items (Wi-Fi password, insurance policy) as Shared to make them accessible to your partner.", bullet_style))
    story.append(Spacer(1, 14))

    # ═══════════════════════════════════════════════════════════════════════════
    # SECTION 8: AI INTELLIGENCE & RELATIONSHIP COACH
    # ═══════════════════════════════════════════════════════════════════════════
    story.append(Paragraph("8. AI Intelligence & Communication Coach", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor("#CBD5E1"), spaceBefore=2, spaceAfter=10))

    story.append(Paragraph(
        "Nexora integrates an AI assistant specifically tuned for personal productivity and relational empathy. "
        "The engine operates via provider abstraction (Cloud AI or private local Ollama):",
        body_style
    ))

    story.append(Paragraph("Mode 1: General Assistant (Ask AI)", h2_style))
    story.append(Paragraph("• Formulate questions, summarize long thoughts, or draft invitations with optional context tags.", bullet_style))
    story.append(Spacer(1, 4))

    story.append(Paragraph("Mode 2: Relationship Coach", h2_style))
    story.append(Paragraph("• <b>Tone & Empathy Analysis:</b> Paste a draft message or describe a tense discussion situation.", bullet_style))
    story.append(Paragraph("• <b>De-escalation Feedback:</b> The coach identifies emotional subtexts, flags accidental hostility, and offers empathetic phrasing alternatives.", bullet_style))
    story.append(Paragraph("• <b>Recommended Rephrasing:</b> One-tap copy of balanced, constructive revisions.", bullet_style))
    story.append(Spacer(1, 14))

    # ═══════════════════════════════════════════════════════════════════════════
    # SECTION 9: CALENDAR, NEWS & UNIVERSAL SEARCH
    # ═══════════════════════════════════════════════════════════════════════════
    story.append(Paragraph("9. Calendar, Curated News & Universal Search", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor("#CBD5E1"), spaceBefore=2, spaceAfter=10))

    story.append(Paragraph("<b>• Calendar:</b> Plan personal schedules and joint duo anniversaries. Toggle between agenda list and monthly view with full recurrence support.", bullet_style))
    story.append(Paragraph("<b>• News Feed:</b> Aggregates handpicked news articles from verified publishers. Completely free of algorithmic engagement traps or ads.", bullet_style))
    story.append(Paragraph("<b>• Universal Search:</b> Global search bar on Home screen queries across notes, calendar entries, vault documents, and messages in a single unified interface.", bullet_style))
    story.append(Spacer(1, 20))

    # ═══════════════════════════════════════════════════════════════════════════
    # SECTION 10: QUICK TROUBLESHOOTING & FAQ
    # ═══════════════════════════════════════════════════════════════════════════
    story.append(Paragraph("10. Troubleshooting & Reference FAQ", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor("#CBD5E1"), spaceBefore=2, spaceAfter=10))

    faq_data = [
        [Paragraph("<b>Question</b>", callout_title), Paragraph("<b>Answer / Solution</b>", callout_title)],
        [
            Paragraph("Invite code shows expired or invalid?", body_style),
            Paragraph("Couple invitation codes expire after 48 hours. Generate a fresh code from Partner A's device and enter it within the valid time limit.", body_style)
        ],
        [
            Paragraph("Can I use Nexora without a partner?", body_style),
            Paragraph("Yes! Nexora functions as a comprehensive personal productivity system. Couple features remain dormant until an invitation is paired.", body_style)
        ],
        [
            Paragraph("How is my data backed up?", body_style),
            Paragraph("All records are synchronized to your self-hosted or dedicated ASP.NET Core database backend with automated transaction safety.", body_style)
        ],
        [
            Paragraph("Can my partner see my private vault?", body_style),
            Paragraph("No. Items in the vault default to Private (Visibility 0) and remain visible only on your authenticated account unless explicitly flagged as Shared.", body_style)
        ],
    ]
    t_faq = Table(faq_data, colWidths=[180, 342])
    t_faq.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#F1F5F9")),
        ('BOX', (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
    ]))
    story.append(t_faq)

    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"Successfully generated PDF at: {output_pdf_path}")

if __name__ == "__main__":
    out_path = sys.argv[1] if len(sys.argv) > 1 else "Nexora_Mobile_App_Guide.pdf"
    generate_guide(out_path)
