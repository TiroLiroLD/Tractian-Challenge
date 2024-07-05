import 'package:flutter/material.dart';
import 'package:tractian_challenge/themes/app_colors.dart';

class CollapsibleWidget extends StatefulWidget {
  final String title;
  final String iconPath;
  final String? status;
  final bool isExpanded;
  final bool filterActive;
  final List<Widget> children;

  CollapsibleWidget({
    required this.title,
    required this.iconPath,
    this.status,
    this.isExpanded = false,
    this.filterActive = false,
    required this.children,
  });

  @override
  _CollapsibleWidgetState createState() => _CollapsibleWidgetState();
}

class _CollapsibleWidgetState extends State<CollapsibleWidget> with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (_isExpanded) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(CollapsibleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded || oldWidget.filterActive != widget.filterActive) {
      setState(() {
        _isExpanded = widget.isExpanded || widget.filterActive;
      });
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TreeLinePainter(_isExpanded && widget.children.isNotEmpty),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0), // Indentation for child nodes
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.children.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                    ),
                    onPressed: widget.filterActive
                        ? null
                        : () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                      if (_isExpanded) {
                        _controller.forward();
                      } else {
                        _controller.reverse();
                      }
                    },
                    color: widget.filterActive ? AppColors.bodyDivider : AppColors.bodyText2,
                  ),
                if (widget.children.isEmpty)
                  const SizedBox(
                    width: 48,
                    height: 42,
                  ),
                Image.asset(
                  widget.iconPath,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.status != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      widget.status == 'alert' ? Icons.circle : Icons.bolt_rounded,
                      color: widget.status == 'alert' ? Colors.red : Colors.green,
                      size: widget.status == 'alert' ? 12 : null,
                    ),
                  ),
              ],
            ),
            SizeTransition(
              sizeFactor: _animation,
              axisAlignment: -1.0,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0), // Additional indentation for children
                child: Column(
                  children: widget.children,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TreeLinePainter extends CustomPainter {
  final bool drawLines;

  TreeLinePainter(this.drawLines);

  @override
  void paint(Canvas canvas, Size size) {
    if (!drawLines) return;

    final paint = Paint()
      ..color = AppColors.bodyDivider
      ..strokeWidth = 2;

    // Draw vertical line from the middle of the icon button to the bottom
    double startX = 40; // Starting X position to align with the icon
    double iconSize = 24; // Icon size for positioning

    canvas.drawLine(Offset(startX, iconSize), Offset(startX, size.height), paint);

    // Draw horizontal line from the middle to the right at the bottom
    canvas.drawLine(Offset(startX, size.height), Offset(startX + iconSize/2, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
