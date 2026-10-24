import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ai_models.dart';
import '../theme/nexora_theme.dart';
import 'bento_card.dart';

/// Relationship Coach Diagnostic Display Card.
/// Displays Tone assessment badges (Constructive, Defensive, Empathetic),
/// bulleted insight items, and a container featuring the one-tap copyable recommended rewrite.
class RelationshipCoachCard extends StatelessWidget {
  final CoachResponseModel response;

  const RelationshipCoachCard({
    super.key,
    required this.response,
  });

  void _copyRewrite(BuildContext context) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: response.suggestion));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Optimized rewrite copied!'),
          ],
        ),
        backgroundColor: NexoraColors.successLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: NexoraRadius.borderSm),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  (String, Color, IconData) _analyzeTone(String feedback) {
    final lower = feedback.toLowerCase();
    if (lower.contains('defensive') || lower.contains('harsh') || lower.contains('frustrat')) {
      return ('Defensive', const Color(0xFFE17055), Icons.warning_amber_rounded);
    } else if (lower.contains('empath') || lower.contains('caring') || lower.contains('warm') || lower.contains('gentle')) {
      return ('Empathetic', const Color(0xFF00B894), Icons.favorite_rounded);
    }
    return ('Constructive', const Color(0xFF0984E3), Icons.lightbulb_outline_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NexoraTheme.of(context);
    final (toneLabel, toneColor, toneIcon) = _analyzeTone(response.toneFeedback);

    return BentoCard(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tokens.coupleAccent.withOpacity(0.14),
                  borderRadius: NexoraRadius.borderSm,
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: tokens.coupleAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Communication Analysis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),
              ),
              // Tone badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: toneColor.withOpacity(0.12),
                  borderRadius: NexoraRadius.borderSm,
                  border: Border.all(color: toneColor.withOpacity(0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(toneIcon, size: 14, color: toneColor),
                    const SizedBox(width: 4),
                    Text(
                      toneLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: toneColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tone Insights bullet items
          if (response.toneFeedback.isNotEmpty) ...[
            Text(
              'Diagnostic Insights',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: tokens.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tokens.strokeSubtle.withOpacity(0.5),
                borderRadius: NexoraRadius.borderSm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: tokens.brandPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      response.toneFeedback,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: tokens.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Recommended rewrite container
          Text(
            'Recommended Rewrite',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: tokens.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  tokens.coupleAccent.withOpacity(0.08),
                  tokens.brandPrimary.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: NexoraRadius.borderMd,
              border: Border.all(
                color: tokens.coupleAccent.withOpacity(0.25),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '"${response.suggestion}"',
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.brandPrimary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(130, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: NexoraRadius.borderSm,
                      ),
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Use Rewrite', style: TextStyle(fontSize: 13)),
                    onPressed: () => _copyRewrite(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
