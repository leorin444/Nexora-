import 'package:flutter/material.dart';
import '../models/search_models.dart';
import '../theme/nexora_theme.dart';
import 'bento_card.dart';

/// Multi-entity search row displaying dynamic color-coded category badges
/// ([NOTE], [EVENT], [VAULT], [NEWS]), title, highlighted snippet, timestamp,
/// and forward navigation chevron.
class UniversalSearchTile extends StatelessWidget {
  final SearchResultModel item;
  final VoidCallback? onTap;

  const UniversalSearchTile({
    super.key,
    required this.item,
    this.onTap,
  });

  (String, Color, IconData) _metaForType(int type, NexoraThemeExtension tokens) {
    switch (type) {
      case 0:
        return ('NOTE', tokens.brandPrimary, Icons.note_alt_outlined);
      case 1:
        return ('REMINDER', const Color(0xFFF39C12), Icons.alarm_rounded);
      case 2:
        return ('EVENT', tokens.coupleAccent, Icons.event_rounded);
      case 3:
        return ('VAULT', tokens.vaultAccent, Icons.shield_rounded);
      case 4:
        return ('NEWS', tokens.intelligence, Icons.newspaper_rounded);
      default:
        return ('ITEM', tokens.textSecondary, Icons.search_rounded);
    }
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NexoraTheme.of(context);
    final (badgeLabel, badgeColor, badgeIcon) = _metaForType(item.resultType, tokens);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: BentoCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderRadius: NexoraRadius.borderMd,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.12),
                borderRadius: NexoraRadius.borderSm,
              ),
              child: Icon(badgeIcon, color: badgeColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: badgeColor.withOpacity(0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '[$badgeLabel]',
                          style: TextStyle(
                            fontFamily: NexoraTheme.monoFont,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: tokens.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (item.snippet != null && item.snippet!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.snippet!,
                      style: TextStyle(
                        fontSize: 13,
                        color: tokens.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatRelativeTime(item.timestampUtc),
                    style: TextStyle(
                      fontSize: 11,
                      color: tokens.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: tokens.textSecondary.withOpacity(0.6),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
