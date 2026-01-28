import 'package:flutter/material.dart';
import 'pixel_text.dart';

class PixelButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const PixelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 120,
    this.height = 40,
    this.color = const Color(0xFF8B4513),
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
              color: const Color(0xFFCD853F), width: 2), // Lighter brown
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: PixelText(label, fontSize: 12),
      ),
    );
  }
}
