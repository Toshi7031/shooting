import 'package:flutter/material.dart';
import 'pixel_text.dart';

/// フローティングテキストを表示するオーバーレイ
class FloatingFeedback {
  static OverlayEntry? _currentEntry;

  /// フローティングテキストを表示
  static void show(
    BuildContext context,
    String message, {
    Color color = Colors.white,
    Duration duration = const Duration(milliseconds: 800),
    Offset? position,
  }) {
    _currentEntry?.remove();

    final overlay = Overlay.of(context);

    // 位置が指定されていない場合は画面中央上部
    final screenSize = MediaQuery.of(context).size;
    final pos = position ??
        Offset(screenSize.width / 2 - 50, screenSize.height / 3);

    _currentEntry = OverlayEntry(
      builder: (context) => _FloatingText(
        message: message,
        color: color,
        position: pos,
        duration: duration,
        onComplete: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    overlay.insert(_currentEntry!);
  }
}

class _FloatingText extends StatefulWidget {
  final String message;
  final Color color;
  final Offset position;
  final Duration duration;
  final VoidCallback onComplete;

  const _FloatingText({
    required this.message,
    required this.color,
    required this.position,
    required this.duration,
    required this.onComplete,
  });

  @override
  State<_FloatingText> createState() => _FloatingTextState();
}

class _FloatingTextState extends State<_FloatingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _moveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _moveAnimation = Tween<double>(begin: 0.0, end: -30.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx,
          top: widget.position.dy + _moveAnimation.value,
          child: IgnorePointer(
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(180),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: widget.color.withAlpha(150)),
                ),
                child: PixelText(
                  widget.message,
                  fontSize: 12,
                  color: widget.color,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
