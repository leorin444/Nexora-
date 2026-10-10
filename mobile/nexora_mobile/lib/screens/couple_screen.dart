import 'package:flutter/material.dart';
import '../models/couple_model.dart';
import '../services/couples_service.dart';

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
      setState(() {
        _couple = couple;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateInvite() async {
    setState(() => _isActionInProgress = true);
    try {
      final invite = await _couplesService.createInvitation();
      setState(() {
        _generatedInvitation = invite;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isActionInProgress = false);
    }
  }

  Future<void> _acceptInvite() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isActionInProgress = true);
    try {
      final couple = await _couplesService.acceptInvitation(code);
      setState(() {
        _couple = couple;
        _generatedInvitation = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully paired with partner!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      setState(() => _isActionInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Couple Space'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _couple != null
                  ? _buildConnectedView()
                  : _buildUnconnectedView(),
            ),
    );
  }

  Widget _buildConnectedView() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.favorite, size: 72, color: Colors.pink),
            const SizedBox(height: 16),
            Text(
              'Connected Couple',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Partner: ${_couple!.partner.fullName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Connected since: ${_couple!.connectedAtUtc.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Chip(
              label: Text('Couple Mode Active', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.pink,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnconnectedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.link_rounded, size: 64, color: Colors.deepPurple),
        const SizedBox(height: 16),
        Text(
          'Connect with Your Partner',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Pair with exactly one partner to unlock Couple Mode, shared notes, shared calendar, and memories.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),

        // 1. Generate invitation card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '1. Invite Your Partner',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text('Generate an 8-character invitation code to share:'),
                const SizedBox(height: 12),
                if (_generatedInvitation != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepPurple),
                    ),
                    child: Center(
                      child: SelectableText(
                        _generatedInvitation!.invitationCode,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Valid for 48 hours. Single use.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text('Generate Invitation Code'),
                    onPressed: _isActionInProgress ? null : _generateInvite,
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 2. Accept invitation card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '2. Enter Partner\'s Code',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: '8-Character Invitation Code',
                    border: OutlineInputBorder(),
                    hintText: 'e.g. AB12CD34',
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isActionInProgress ? null : _acceptInvite,
                  child: const Text('Connect Couple'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
