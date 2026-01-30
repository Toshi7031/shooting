import 'package:flutter/material.dart';
import 'pixel_text.dart';

class PixelButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final Color color;
  final bool enabled;

  const PixelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 120,
    this.height = 40,
    this.color = const Color(0xFF8B4513),
    this.enabled = true,
  });

  @override
  State<PixelButton> createState() => PixelButtonState();
}

class PixelButtonState extends State<PixelButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: widget.color,
      end: Colors.white,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 成功時のフラッシュアニメーション
  void flashSuccess() {
    _colorAnimation = ColorTween(
      begin: widget.color,
      end: Colors.green.shade300,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward().then((_) => _controller.reverse());
  }

  /// エラー時のシェイク＋フラッシュアニメーション
  void flashError() {
    _colorAnimation = ColorTween(
      begin: widget.color,
      end: Colors.red.shade300,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.enabled ? widget.color : Colors.grey.shade700;
    final borderColor = widget.enabled ? const Color(0xFFCD853F) : Colors.grey.shade500;
    final textColor = widget.enabled ? Colors.white : Colors.grey.shade400;

    return GestureDetector(
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.enabled ? (_controller.isAnimating ? _colorAnimation.value : effectiveColor) : effectiveColor,
                border: Border.all(color: borderColor, width: 2),
                boxShadow: widget.enabled
                    ? const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: PixelText(widget.label, fontSize: 12, color: textColor),
            ),
          );
        },
      ),
    );
  }
}
