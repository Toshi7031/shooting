import 'package:flutter/material.dart';

/// A pixel-art styled scrollbar widget with separate track area.
class PixelScrollbar extends StatefulWidget {
  final Widget child;

  const PixelScrollbar({
    super.key,
    required this.child,
  });

  static const double scrollbarWidth = 14.0;

  @override
  State<PixelScrollbar> createState() => _PixelScrollbarState();
}

class _PixelScrollbarState extends State<PixelScrollbar> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  double _maxScrollExtent = 0;
  double _viewportHeight = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
      _maxScrollExtent = _scrollController.position.maxScrollExtent;
      _viewportHeight = _scrollController.position.viewportDimension;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // Content area
            Expanded(
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: widget.child,
                ),
              ),
            ),
            // Custom scrollbar track
            Container(
              width: PixelScrollbar.scrollbarWidth,
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withValues(alpha: 0.5),
                border: Border(
                  left: BorderSide(color: Colors.grey[800]!, width: 1),
                ),
              ),
              child: _buildCustomThumb(constraints.maxHeight),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomThumb(double trackHeight) {
    // Calculate thumb size and position
    final double totalContentHeight = _maxScrollExtent + _viewportHeight;
    if (totalContentHeight <= _viewportHeight || totalContentHeight == 0) {
      // No scrolling needed, don't show thumb
      return const SizedBox.expand();
    }

    final double thumbHeight =
        ((_viewportHeight / totalContentHeight) * trackHeight)
            .clamp(20.0, trackHeight);
    final double scrollableTrack = trackHeight - thumbHeight;
    final double thumbPosition = _maxScrollExtent > 0
        ? (_scrollOffset / _maxScrollExtent) * scrollableTrack
        : 0;

    return Stack(
      children: [
        Positioned(
          top: thumbPosition,
          left: 1,
          right: 1,
          child: Container(
            height: thumbHeight,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              border: Border.all(color: Colors.grey[500]!, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
