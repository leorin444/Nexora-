import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/vault_item_model.dart';
import '../theme/nexora_theme.dart';
import 'bento_card.dart';

/// Vault Secret Tile widget displaying encrypted items with masked secret preview,
/// reveal eye toggle (180ms cross-fade), and haptic copy-to-clipboard action.
class VaultSecretTile extends StatefulWidget {
  final VaultItemModel item;
  final VoidCallback? onTap;

  const VaultSecretTile({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  State<VaultSecretTile> createState() => _VaultSecretTileState();
}

class _VaultSecretTileState extends State<VaultSecretTile> {
  bool _isRevealed = false;

  void _copyToClipboard(BuildContext context) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: widget.item.encryptedPayload));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Secret copied to clipboard'),
          ],
        ),
        backgroundColor: NexoraColors.successLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: NexoraRadius.borderSm),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  IconData _iconForType(int type) {
    switch (type) {
      case 1:
        return Icons.vpn_key_rounded;
      case 2:
        return Icons.credit_card_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NexoraTheme.of(context);
    final isShared = widget.item.visibility != 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: BentoCard(
        onTap: widget.onTap,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tokens.vaultAccent.withOpacity(0.12),
                    borderRadius: NexoraRadius.borderSm,
                  ),
                  child: Icon(
                    _iconForType(widget.item.itemType),
                    color: tokens.vaultAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: tokens.textPrimary,
                        ),
                      ),
                      if (widget.item.description != null &&
                          widget.item.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            widget.item.description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: tokens.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                // Visibility chip: 🔒 Only You vs 💖 Shared Pair
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (isShared ? tokens.coupleAccent : tokens.brandPrimary)
                        .withOpacity(0.12),
                    borderRadius: NexoraRadius.borderSm,
                  ),
                  child: Text(
                    isShared ? '💖 Shared Pair' : '🔒 Only You',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isShared ? tokens.coupleAccent : tokens.brandPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Tags wrap
            if (widget.item.tags != null && widget.item.tags!.trim().isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: widget.item.tags!
                    .split(',')
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tokens.strokeSubtle,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#${tag.trim()}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: tokens.textSecondary,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
            // Masked secret container with eye toggle & copy button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: tokens.strokeSubtle.withOpacity(0.5),
                borderRadius: NexoraRadius.borderSm,
                border: Border.all(color: tokens.strokeSubtle, width: 1.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedCrossFade(
                      duration: const Duration(milliseconds: 180),
                      crossFadeState: _isRevealed
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: Text(
                        '••••••••••••',
                        style: TextStyle(
                          fontFamily: NexoraTheme.monoFont,
                          fontSize: 16,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w700,
                          color: tokens.textPrimary,
                        ),
                      ),
                      secondChild: Text(
                        widget.item.encryptedPayload,
                        style: TextStyle(
                          fontFamily: NexoraTheme.monoFont,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: tokens.vaultAccent,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    icon: Icon(
                      _isRevealed
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: tokens.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isRevealed = !_isRevealed);
                    },
                    tooltip: _isRevealed ? 'Mask secret' : 'Reveal secret',
                  ),
                  IconButton(
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    icon: Icon(
                      Icons.copy_rounded,
                      color: tokens.brandPrimary,
                      size: 20,
                    ),
                    onPressed: () => _copyToClipboard(context),
                    tooltip: 'Copy secret',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
