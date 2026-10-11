import 'package:flutter/material.dart';
import '../models/ai_models.dart';
import '../services/ai_service.dart';

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

    setState(() {
      _isAsking = true;
      _askError = null;
    });

    try {
      final res = await _aiService.askAI(prompt, context: _contextController.text.trim());
      setState(() {
        _aiResponse = res;
      });
    } catch (e) {
      setState(() {
        _askError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isAsking = false;
      });
    }
  }

  Future<void> _handleCoach() async {
    final msg = _coachMessageController.text.trim();
    if (msg.isEmpty) return;

    setState(() {
      _isCoaching = true;
      _coachError = null;
    });

    try {
      final res = await _aiService.getCoachFeedback(msg, situation: _coachSituationController.text.trim());
      setState(() {
        _coachResponse = res;
      });
    } catch (e) {
      setState(() {
        _coachError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isCoaching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexora AI Assistant'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.auto_awesome), text: 'Ask AI'),
            Tab(icon: Icon(Icons.record_voice_over), text: 'Communication Coach'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Ask AI
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                TextField(
                  controller: _promptController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Ask anything...',
                    hintText: 'e.g. How can we balance busy schedules this week?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contextController,
                  decoration: const InputDecoration(
                    labelText: 'Optional Context',
                    hintText: 'e.g. Partner works night shifts',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isAsking ? null : _handleAskAI,
                  icon: const Icon(Icons.send),
                  label: _isAsking
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Send Prompt'),
                ),
                if (_askError != null) ...[
                  const SizedBox(height: 12),
                  Text('Error: $_askError', style: const TextStyle(color: Colors.red)),
                ],
                if (_aiResponse != null) ...[
                  const SizedBox(height: 20),
                  Card(
                    color: Colors.purple.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Provider: ${_aiResponse!.provider}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Chip(
                                label: Text(_aiResponse!.isAvailable ? 'Live' : 'Fallback', style: const TextStyle(fontSize: 10)),
                                backgroundColor: _aiResponse!.isAvailable ? Colors.green.shade100 : Colors.orange.shade100,
                              ),
                            ],
                          ),
                          const Divider(),
                          Text(_aiResponse!.answer, style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Tab 2: Communication Coach
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                TextField(
                  controller: _coachMessageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Message to Partner',
                    hintText: 'Type what you want to say, even if you are upset...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _coachSituationController,
                  decoration: const InputDecoration(
                    labelText: 'Situation context (optional)',
                    hintText: 'e.g. Partner forgot to pick up groceries again',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade50,
                    foregroundColor: Colors.teal.shade900,
                  ),
                  onPressed: _isCoaching ? null : _handleCoach,
                  icon: const Icon(Icons.psychology),
                  label: _isCoaching
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Review & Enhance Message'),
                ),
                if (_coachError != null) ...[
                  const SizedBox(height: 12),
                  Text('Error: $_coachError', style: const TextStyle(color: Colors.red)),
                ],
                if (_coachResponse != null) ...[
                  const SizedBox(height: 20),
                  Card(
                    color: Colors.teal.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Empathetic Suggestion:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 6),
                          Text(_coachResponse!.suggestion, style: const TextStyle(fontSize: 15)),
                          if (_coachResponse!.toneFeedback.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text('Tone Insight:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.teal)),
                            const SizedBox(height: 4),
                            Text(_coachResponse!.toneFeedback, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
