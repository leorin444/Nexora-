import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/auth_models.dart';
import 'models/couple_model.dart';
import 'models/note_model.dart';
import 'models/calendar_event_model.dart';
import 'models/vault_item_model.dart';
import 'models/news_article_model.dart';
import 'providers/auth_provider.dart';
import 'services/couples_service.dart';
import 'services/notes_service.dart';
import 'services/calendar_service.dart';
import 'services/vault_service.dart';
import 'services/news_service.dart';
import 'theme/nexora_theme.dart';
import 'widgets/bento_card.dart';
import 'screens/login_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/couple_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/vault_screen.dart';
import 'screens/ai_screen.dart';
import 'screens/news_screen.dart';
import 'screens/search_screen.dart';
import 'screens/note_editor_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const NexoraApp(),
    ),
  );
}

class NexoraApp extends StatelessWidget {
  const NexoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexora',
      debugShowCheckedModeBanner: false,
      theme: NexoraTheme.lightTheme,
      darkTheme: NexoraTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          switch (auth.status) {
            case AuthStatus.uninitialized:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            case AuthStatus.authenticated:
              return MainNavigationShell(user: auth.user!);
            case AuthStatus.unauthenticated:
              return const LoginScreen();
          }
        },
      ),
    );
  }
}

/// Docked 5-destination navigation dock wrapper
class MainNavigationShell extends StatefulWidget {
  final UserProfile user;
  const MainNavigationShell({super.key, required this.user});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tokens = NexoraTheme.of(context);

    final List<Widget> screens = [
      HomeScreen(
        user: widget.user,
        onNavigateTab: (index) {
          setState(() => _currentIndex = index);
        },
      ),
      const NotesScreen(),
      const CoupleScreen(),
      const VaultScreen(),
      const AIScreen(),
    ];

    return Scaffold(
      backgroundColor: tokens.canvas,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: tokens.cardSurface,
          border: Border(top: BorderSide(color: tokens.strokeSubtle, width: 1.2)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_rounded, Icons.dashboard_outlined, 'Home', tokens),
                _buildNavItem(1, Icons.note_alt_rounded, Icons.note_alt_outlined, 'Notes', tokens),
                _buildNavItem(2, Icons.favorite_rounded, Icons.favorite_border_rounded, 'Couple', tokens, accentColor: tokens.coupleAccent),
                _buildNavItem(3, Icons.shield_rounded, Icons.shield_outlined, 'Vault', tokens, accentColor: tokens.vaultAccent),
                _buildNavItem(4, Icons.auto_awesome_rounded, Icons.auto_awesome_outlined, 'AI', tokens, accentColor: tokens.intelligence),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    NexoraThemeExtension tokens, {
    Color? accentColor,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? (accentColor ?? tokens.brandPrimary) : tokens.textSecondary;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _currentIndex = index);
      },
      borderRadius: NexoraRadius.borderSm,
      child: Container(
        constraints: const BoxConstraints(minWidth: 54, minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : inactiveIcon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bento Grid Executive Dashboard
class HomeScreen extends StatefulWidget {
  final UserProfile user;
  final ValueChanged<int>? onNavigateTab;

  const HomeScreen({
    super.key,
    required this.user,
    this.onNavigateTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CouplesService _couplesService = CouplesService();
  final NotesService _notesService = NotesService();
  final CalendarService _calendarService = CalendarService();
  final VaultService _vaultService = VaultService();
  final NewsService _newsService = NewsService();

  CoupleModel? _couple;
  List<NoteModel> _notes = [];
  List<CalendarEventModel> _events = [];
  List<VaultItemModel> _vaultItems = [];
  List<NewsArticleModel> _news = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final results = await Future.wait([
        _couplesService.getCurrentCouple().catchError((_) => null),
        _notesService.getNotes().catchError((_) => <NoteModel>[]),
        _calendarService.getEvents().catchError((_) => <CalendarEventModel>[]),
        _vaultService.getItems().catchError((_) => <VaultItemModel>[]),
        _newsService.getArticles(topStoriesOnly: true).catchError((_) => <NewsArticleModel>[]),
      ]);

      if (mounted) {
        setState(() {
          _couple = results[0] as CoupleModel?;
          _notes = results[1] as List<NoteModel>;
          _events = results[2] as List<CalendarEventModel>;
          _vaultItems = results[3] as List<VaultItemModel>;
          _news = results[4] as List<NewsArticleModel>;
        });
      }
    } catch (_) {}
  }

  int get _daysConnected {
    if (_couple == null) return 0;
    return DateTime.now().difference(_couple!.connectedAtUtc.toLocal()).inDays + 1;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NexoraTheme.of(context);
    final userInitials = widget.user.firstName.isNotEmpty
        ? widget.user.firstName[0].toUpperCase()
        : 'N';

    final pinnedNote = _notes.firstWhere(
      (n) => n.isPinned,
      orElse: () => _notes.isNotEmpty
          ? _notes.first
          : NoteModel(
              id: '',
              title: 'Welcome Note',
              content: 'Tap + to capture quick thoughts.',
              isPinned: false,
              visibility: VisibilityLevel.private,
              isArchived: false,
              createdAtUtc: DateTime.now(),
              updatedAtUtc: DateTime.now(),
            ),
    );

    final nextEvent = _events.isNotEmpty ? _events.first : null;
    final latestNews = _news.isNotEmpty ? _news.first : null;

    return Scaffold(
      backgroundColor: tokens.canvas,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: tokens.brandPrimary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Bar: Avatar with emerald green status dot + Greeting + Search action
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: tokens.brandPrimary.withOpacity(0.18),
                          child: Text(
                            userInitials,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: tokens.brandPrimary,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: NexoraColors.successLight, // #00B894
                              shape: BoxShape.circle,
                              border: Border.all(color: tokens.cardSurface, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()},',
                            style: TextStyle(
                              fontSize: 13,
                              color: tokens.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            widget.user.fullName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: tokens.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Search Action Icon
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: tokens.cardSurface,
                          shape: BoxShape.circle,
                          border: Border.all(color: tokens.strokeSubtle),
                        ),
                        child: Icon(Icons.search_rounded, size: 20, color: tokens.textPrimary),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SearchScreen()),
                        );
                      },
                    ),
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: tokens.cardSurface,
                          shape: BoxShape.circle,
                          border: Border.all(color: tokens.strokeSubtle),
                        ),
                        child: Icon(Icons.logout_rounded, size: 20, color: tokens.textSecondary),
                      ),
                      onPressed: () {
                        Provider.of<AuthProvider>(context, listen: false).logout();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 1. Couple Space Hero (Top, Full Width)
                BentoCard(
                  onTap: () {
                    widget.onNavigateTab != null
                        ? widget.onNavigateTab!(2)
                        : Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CoupleScreen()),
                          );
                  },
                  gradient: LinearGradient(
                    colors: [tokens.coupleAccent, tokens.brandPrimary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _couple != null ? 'Couple Space' : 'Connect Your Partner',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          // Days connected counter badge
                          if (_couple != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: NexoraRadius.borderSm,
                              ),
                              child: Text(
                                'Day $_daysConnected Together',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_couple != null) ...[
                        Row(
                          children: [
                            // Linked profile initials
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              child: Text(
                                userInitials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.favorite, color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              child: Text(
                                _couple!.partner.fullName.isNotEmpty
                                    ? _couple!.partner.fullName[0].toUpperCase()
                                    : 'P',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'With ${_couple!.partner.fullName}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Unread chat pill / quick chat link
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ChatScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: NexoraRadius.borderSm,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Open Duo Chat & E2EE Stream',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'Generate a private invite code or enter your partner\'s key to unlock duo mode.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: NexoraRadius.borderSm,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Pair Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Split Row (2-Column): Notes Widget & Calendar Widget
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notes Widget
                    Expanded(
                      child: BentoCard(
                        onTap: () {
                          widget.onNavigateTab != null
                              ? widget.onNavigateTab!(1)
                              : Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const NotesScreen()),
                                );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: tokens.brandPrimary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.note_alt_outlined, color: tokens.brandPrimary, size: 18),
                                ),
                                IconButton(
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.add_circle_outline, color: tokens.brandPrimary, size: 22),
                                  onPressed: () async {
                                    HapticFeedback.lightImpact();
                                    final res = await Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
                                    );
                                    if (res == true) _loadDashboardData();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Notes',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: tokens.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              pinnedNote.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: tokens.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: tokens.strokeSubtle,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${_notes.length} saved',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Calendar Widget
                    Expanded(
                      child: BentoCard(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CalendarScreen()),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: tokens.coupleAccent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.event_outlined, color: tokens.coupleAccent, size: 18),
                                ),
                                if (nextEvent != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (nextEvent.visibility != 0
                                              ? tokens.coupleAccent
                                              : tokens.brandPrimary)
                                          .withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      nextEvent.visibility != 0 ? 'Duo' : 'Private',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: nextEvent.visibility != 0
                                            ? tokens.coupleAccent
                                            : tokens.brandPrimary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Next Event',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: tokens.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              nextEvent != null ? nextEvent.title : 'No events scheduled',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: tokens.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: tokens.strokeSubtle,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                nextEvent != null
                                    ? nextEvent.startTimeUtc.toLocal().toString().substring(11, 16)
                                    : 'Schedule +',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 3. AI Compass Card (Full Width)
                BentoCard(
                  onTap: () {
                    widget.onNavigateTab != null
                        ? widget.onNavigateTab!(4)
                        : Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AIScreen()),
                          );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: tokens.intelligence.withOpacity(0.12),
                              borderRadius: NexoraRadius.borderSm,
                            ),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              color: tokens.intelligence,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Intelligence & Coach',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Contextual assistant for empathy & clarity',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: tokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // 2 Suggestion Chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildSuggestionChip('✨ Draft dinner invite', tokens, () {
                            widget.onNavigateTab != null
                                ? widget.onNavigateTab!(4)
                                : Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const AIScreen()),
                                  );
                          }),
                          _buildSuggestionChip('💖 Tone check draft', tokens, () {
                            widget.onNavigateTab != null
                                ? widget.onNavigateTab!(4)
                                : Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const AIScreen()),
                                  );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 4. Split Row (2-Column): Vault Widget & News Mini-Ticker
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vault Widget
                    Expanded(
                      child: BentoCard(
                        onTap: () {
                          widget.onNavigateTab != null
                              ? widget.onNavigateTab!(3)
                              : Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const VaultScreen()),
                                );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: tokens.vaultAccent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.lock_outline_rounded, color: tokens.vaultAccent, size: 18),
                                ),
                                Text(
                                  '${_vaultItems.length} items',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: tokens.vaultAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Knowledge Vault',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: tokens.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _vaultItems.isNotEmpty ? _vaultItems.first.title : 'Vault is empty',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: tokens.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Masked secret preview
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: tokens.strokeSubtle,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '••••••••',
                                style: TextStyle(
                                  fontFamily: NexoraTheme.monoFont,
                                  fontSize: 11,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w700,
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // News Mini-Ticker
                    Expanded(
                      child: BentoCard(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const NewsScreen()),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: tokens.intelligence.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.newspaper_rounded, color: tokens.intelligence, size: 18),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: tokens.intelligence.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'NEWS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: tokens.intelligence,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              latestNews != null ? latestNews.sourceName : 'Daily Digest',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: tokens.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              latestNews != null ? latestNews.title : 'Check latest curated feed',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: tokens.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(
    String label,
    NexoraThemeExtension tokens,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: NexoraRadius.borderSm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: tokens.strokeSubtle,
          borderRadius: NexoraRadius.borderSm,
          border: Border.all(color: tokens.strokeSubtle, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: tokens.textPrimary,
          ),
        ),
      ),
    );
  }
}
