import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/nexora_theme.dart';

/// Bento Card Component supporting micro-scaling, gradient fills,
/// sleek stroke borders, and haptic feedback.
class BentoCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? borderRadius;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Border? border;
  final double? width;
  final double? height;

  const BentoCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius,
    this.gradient,
    this.backgroundColor,
    this.border,
    this.width,
    this.height,
  });

  @override
  State<BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<BentoCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final tokens = NexoraTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final resolvedRadius = widget.borderRadius ?? NexoraRadius.borderLg;
    final resolvedBgColor = widget.backgroundColor ??
        (widget.gradient == null ? tokens.cardSurface : null);
    final resolvedBorder = widget.border ??
        Border.all(
          color: tokens.strokeSubtle,
          width: 1.2,
        );

    final cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: resolvedBgColor,
        gradient: widget.gradient,
        borderRadius: resolvedRadius,
        border: resolvedBorder,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: resolvedRadius,
        child: Padding(
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );

    if (widget.onTap == null) {
      return cardContent;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutQuad,
        child: cardContent,
      ),
    );
  }
}
