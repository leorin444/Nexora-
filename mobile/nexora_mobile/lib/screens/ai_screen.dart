import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ai_models.dart';
import '../services/ai_service.dart';
import '../theme/nexora_theme.dart';
import '../widgets/bento_card.dart';
import '../widgets/relationship_coach_card.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> with SingleTickerProviderStateMixin {
  final AIService _aiService = AIService();
  late TabController _tabController;

  // Ask AI state
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();
  AIResponseModel? _aiResponse;
  bool _isAsking = false;
  String? _askError;

  // Coach state
  final TextEditingController _coachMessageController = TextEditingController();
  final TextEditingController _coachSituationController = TextEditingController();
  CoachResponseModel? _coachResponse;
  bool _isCoaching = false;
  String? _coachError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _promptController.dispose();
    _contextController.dispose();
    _coachMessageController.dispose();
    _coachSituationController.dispose();
    super.dispose();
  }

  Future<void> _handleAskAI() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isAsking = true;
      _askError = null;
    });

    try {
      final res = await _aiService.askAI(prompt, context: _contextController.text.trim());
      if (mounted) {
        setState(() {
          _aiResponse = res;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _askError = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAsking = false;
        });
      }
    }
  }

  Future<void> _handleCoach() async {
    final msg = _coachMessageController.text.trim();
    if (msg.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isCoaching = true;
      _coachError = null;
    });

    try {
      final res = await _aiService.getCoachFeedback(
        msg,
        situation: _coachSituationController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _coachResponse = res;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _coachError = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCoaching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NexoraTheme.of(context);

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        title: const Text('AI Copilot & Coach'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: tokens.strokeSubtle,
              borderRadius: NexoraRadius.borderSm,
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: tokens.cardSurface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
                ],
              ),
              labelColor: tokens.brandPrimary,
              unselectedLabelColor: tokens.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(text: '✨ Ask General AI'),
                Tab(text: '❤️ Relationship Coach'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Ask AI
          _buildAskAITab(tokens),

          // Tab 2: Relationship Coach
          _buildCoachTab(tokens),
        ],
      ),
    );
  }

  Widget _buildAskAITab(NexoraThemeExtension tokens) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        BentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Prompt Assistant',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _promptController,
                maxLines: 3,
                style: TextStyle(color: tokens.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Ask anything...',
                  hintText: 'e.g. How can we balance busy work schedules this week?',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contextController,
                style: TextStyle(color: tokens.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Optional Context',
                  hintText: 'e.g. Partner has night shifts',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isAsking ? null : _handleAskAI,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.intelligence,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: NexoraRadius.borderSm),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: _isAsking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Send Prompt', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
        if (_askError != null) ...[
          const SizedBox(height: 14),
          Text('Error: $_askError', style: TextStyle(color: tokens.vaultAccent)),
        ],
        if (_aiResponse != null) ...[
          const SizedBox(height: 16),
          BentoCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: tokens.intelligence),
                        const SizedBox(width: 6),
                        Text(
                          'Provider: ${_aiResponse!.provider}',
                          style: TextStyle(
                            fontFamily: NexoraTheme.monoFont,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: tokens.intelligence,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (_aiResponse!.isAvailable
                                ? NexoraColors.successLight
                                : tokens.vaultAccent)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _aiResponse!.isAvailable ? 'LIVE' : 'FALLBACK',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _aiResponse!.isAvailable
                              ? NexoraColors.successLight
                              : tokens.vaultAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: tokens.strokeSubtle),
                const SizedBox(height: 8),
                Text(
                  _aiResponse!.answer,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: tokens.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCoachTab(NexoraThemeExtension tokens) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
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
                    child: Icon(Icons.favorite_rounded, color: tokens.coupleAccent, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Situation Context',
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
                controller: _coachSituationController,
                style: TextStyle(color: tokens.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'What is happening? (Optional)',
                  hintText: 'e.g. Partner forgot to pick up groceries after a stressful day',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Draft Message',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: tokens.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _coachMessageController,
                maxLines: 3,
                style: TextStyle(color: tokens.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Type what you want to send, even if frustrated or upset...',
                ),
              ),
              const SizedBox(height: 18),
              // Primary Action: "💖 Analyze Tone & Optimize Communication"
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.coupleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: NexoraRadius.borderSm),
                  ),
                  onPressed: _isCoaching ? null : _handleCoach,
                  icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                  label: _isCoaching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          '💖 Analyze Tone & Optimize Communication',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                ),
              ),
            ],
          ),
        ),
        if (_coachError != null) ...[
          const SizedBox(height: 14),
          Text('Error: $_coachError', style: TextStyle(color: tokens.vaultAccent)),
        ],
        if (_coachResponse != null) ...[
          const SizedBox(height: 16),
          // Analysis Card rendering Tone Assessment badge, bulleted insights, copyable rewrite
          RelationshipCoachCard(response: _coachResponse!),
        ],
      ],
    );
  }
}
