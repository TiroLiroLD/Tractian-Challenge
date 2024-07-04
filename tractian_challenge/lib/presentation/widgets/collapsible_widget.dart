// lib/presentation/widgets/collapsible_widget.dart

import 'package:flutter/material.dart';

class CollapsibleWidget extends StatefulWidget {
  final String title;
  final String iconPath;
  final String? status;
  final bool isExpanded;
  final bool disableCollapse;
  final List<Widget> children;

  CollapsibleWidget({
    required this.title,
    required this.iconPath,
    this.status,
    this.isExpanded = false,
    this.disableCollapse = false,
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
    if (oldWidget.isExpanded != widget.isExpanded) {
      setState(() {
        _isExpanded = widget.isExpanded;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.children.isNotEmpty)
              IconButton(
                icon: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                ),
                onPressed: widget.disableCollapse
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
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (widget.status != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  widget.status == 'alert'
                      ? Icons.circle
                      : Icons.bolt_rounded,
                  color: widget.status == 'alert'
                      ? Colors.red
                      : Colors.green,
                  size: widget.status == 'alert' ? 12 : null,
                ),
              ),
          ],
        ),
        SizeTransition(
          sizeFactor: _animation,
          axisAlignment: -1.0,
          child: Column(
            children: widget.children,
          ),
        ),
      ],
    );
  }
}
