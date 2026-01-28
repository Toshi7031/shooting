import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PixelText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final TextAlign textAlign;
  final bool shadow;

  const PixelText(
    this.text, {
    super.key,
    this.fontSize = 14,
    this.color = Colors.white,
    this.textAlign = TextAlign.left,
    this.shadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.pressStart2p(
        fontSize: fontSize,
        color: color,
        textStyle: TextStyle(
          fontFamilyFallback: [
            GoogleFonts.dotGothic16().fontFamily ?? 'sans-serif',
          ],
        ),
        shadows: shadow
            ? [
                const Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 0,
                  color: Colors.black,
                ),
              ]
            : null,
      ),
    );
  }
}
