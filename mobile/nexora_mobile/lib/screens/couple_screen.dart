import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/couple_model.dart';
import '../services/couples_service.dart';
import '../theme/nexora_theme.dart';
import '../widgets/bento_card.dart';
import 'chat_screen.dart';
import 'calendar_screen.dart';

class CoupleScreen extends StatefulWidget {
  const CoupleScreen({super.key});

  @override
  State<CoupleScreen> createState() => _CoupleScreenState();
}

class _CoupleScreenState extends State<CoupleScreen> {
  final CouplesService _couplesService = CouplesService();
  final _codeController = TextEditingController();

  CoupleModel? _couple;
  CoupleInvitationModel? _generatedInvitation;
  bool _isLoading = true;
  String? _error;
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _loadCouple();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadCouple() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final couple = await _couplesService.getCurrentCouple();
      if (mounted) {
        setState(() {
          _couple = couple;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generateInvite() async {
    setState(() => _isActionInProgress = true);
    try {
      final invite = await _couplesService.createInvitation();
      if (mounted) {
        setState(() {
          _generatedInvitation = invite;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: NexoraColors.vaultAccentLight,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isActionInProgress = false);
      }
    }
  }

  Future<void> _acceptInvite() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() => _isActionInProgress = true);
    try {
      final couple = await _couplesService.acceptInvitation(code);
      if (mounted) {
        setState(() {
          _couple = couple;
          _generatedInvitation = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.favorite, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Successfully paired with partner! 💕'),
              ],
            ),
            backgroundColor: NexoraColors.successLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: NexoraRadius.borderSm),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: NexoraColors.vaultAccentLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: NexoraRadius.borderSm),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isActionInProgress = false);
      }
    }
  }

  void _copyInviteCode(String code) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Invite code copied to clipboard!'),
          ],
        ),
        backgroundColor: NexoraColors.successLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: NexoraRadius.borderSm),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  int get _daysTogether {
    if (_couple == null) return 0;
    return DateTime.now().difference(_couple!.connectedAtUtc.toLocal()).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NexoraTheme.of(context);

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        title: const Text('Couple Space'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadCouple,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCouple,
              color: tokens.brandPrimary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _couple != null
                    ? _buildConnectedView(tokens)
                    : _buildUnconnectedView(tokens),
              ),
            ),
    );
  }

  /// State B: Paired Couple Hub
  Widget _buildConnectedView(NexoraThemeExtension tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Celebration Header Card
        BentoCard(
          gradient: LinearGradient(
            colors: [tokens.coupleAccent, tokens.brandPrimary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Connected & Intimate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Paired with ${_couple!.partner.fullName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: NexoraRadius.borderSm,
                ),
                child: Text(
                  'Connected since ${_couple!.connectedAtUtc.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Milestone Metrics Row
        Row(
          children: [
            Expanded(
              child: BentoCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      '$_daysTogether',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: tokens.coupleAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Days Together',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BentoCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: NexoraColors.successLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Encrypted Link',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Quick Navigation Actions
        Row(
          children: [
            Expanded(
              child: BentoCard(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChatScreen()),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: tokens.brandPrimary.withOpacity(0.12),
                        borderRadius: NexoraRadius.borderSm,
                      ),
                      child: Icon(Icons.chat_bubble_rounded, color: tokens.brandPrimary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Couple Chat',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                            ),
                          ),
                          Text(
                            'E2EE Real-time',
                            style: TextStyle(
                              fontSize: 11,
                              color: tokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BentoCard(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CalendarScreen()),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: tokens.coupleAccent.withOpacity(0.12),
                        borderRadius: NexoraRadius.borderSm,
                      ),
                      child: Icon(Icons.calendar_month_rounded, color: tokens.coupleAccent, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Calendar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                            ),
                          ),
                          Text(
                            'Shared Duo dates',
                            style: TextStyle(
                              fontSize: 11,
                              color: tokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// State A: Unpaired Couple Hub
  Widget _buildUnconnectedView(NexoraThemeExtension tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Handshake Header
        BentoCard(
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: tokens.brandPrimary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite_border_rounded, size: 36, color: tokens.brandPrimary),
              ),
              const SizedBox(height: 16),
              Text(
                'Connect with Your Partner',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pair with exactly one person to unlock synchronized notes, dual calendar, vault secrets, and private chat.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: tokens.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 1. Generate Invite Card
        BentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: tokens.brandPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.key_rounded, color: tokens.brandPrimary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '1. Share Your Invite Code',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Generate a private code for your partner to enter on their device:',
                style: TextStyle(fontSize: 13, color: tokens.textSecondary),
              ),
              const SizedBox(height: 14),
              if (_generatedInvitation != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: tokens.brandPrimary.withOpacity(0.08),
                    borderRadius: NexoraRadius.borderSm,
                    border: Border.all(color: tokens.brandPrimary.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _generatedInvitation!.invitationCode,
                        style: TextStyle(
                          fontFamily: NexoraTheme.monoFont,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                          color: tokens.brandPrimary,
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        icon: Icon(Icons.copy_rounded, color: tokens.brandPrimary),
                        onPressed: () => _copyInviteCode(_generatedInvitation!.invitationCode),
                        tooltip: 'Copy Invite Code',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Valid for 48 hours • Single use',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: tokens.textSecondary),
                ),
              ] else ...[
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.brandPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: NexoraRadius.borderSm),
                    ),
                    icon: const Icon(Icons.qr_code_2_rounded, size: 20),
                    label: _isActionInProgress
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Generate Invite Code', style: TextStyle(fontWeight: FontWeight.w700)),
                    onPressed: _isActionInProgress ? null : _generateInvite,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Accept Invite Card
        BentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: tokens.coupleAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.link_rounded, color: tokens.coupleAccent, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '2. Enter Partner\'s Code',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(
                  fontFamily: NexoraTheme.monoFont,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'e.g. NEX-AB12CD',
                  labelText: 'Invite Code',
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.coupleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: NexoraRadius.borderSm),
                  ),
                  onPressed: _isActionInProgress ? null : _acceptInvite,
                  child: _isActionInProgress
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Connect Couple', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
