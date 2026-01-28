import 'package:flutter/material.dart';
import 'pixel_panel.dart';
import 'pixel_button.dart';
import 'pixel_text.dart';

class BaseMenu extends StatelessWidget {
  final String title;
  final Color titleColor;
  final Widget child;
  final VoidCallback? onClose;
  final double? height;

  const BaseMenu({
    super.key,
    required this.title,
    required this.child,
    this.titleColor = Colors.yellow,
    this.onClose,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PixelPanel(
        height: height ?? MediaQuery.of(context).size.height * 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PixelText(title, fontSize: 24, color: titleColor),
            const SizedBox(height: 10),
            Expanded(
              child: child, // The main content of the menu
            ),
            if (onClose != null) ...[
              const SizedBox(height: 10),
              PixelButton(label: "CLOSE", onPressed: onClose!),
            ],
          ],
        ),
      ),
    );
  }
}
