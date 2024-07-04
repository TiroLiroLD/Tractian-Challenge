import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class CollapsibleWidget extends StatefulWidget {
  final String title;
  final String iconPath;
  final List<Widget> children;
  final bool isExpanded;
  final String? status;
  final bool disableCollapse;

  CollapsibleWidget({
    required this.title,
    required this.iconPath,
    required this.children,
    this.isExpanded = false,
    this.status,
    this.disableCollapse = false,
  });

  @override
  _CollapsibleWidgetState createState() => _CollapsibleWidgetState();
}

class _CollapsibleWidgetState extends State<CollapsibleWidget> with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late final ScrollController _scrollController;
  late Ticker _ticker;
  bool _scrollingForward = true;
  int _pauseCounter = 0;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _scrollController = ScrollController();

    _ticker = createTicker((elapsed) {
      const int pauseDuration = 100; // Number of ticks to pause at the end
      const double scrollSpeed = 0.5; // Scroll speed

      if (_scrollingForward) {
        if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
          _pauseCounter++;
          if (_pauseCounter >= pauseDuration) {
            _scrollingForward = false;
            _pauseCounter = 0;
            _scrollController.jumpTo(_scrollController.position.minScrollExtent);
          }
        } else {
          _scrollController.jumpTo(_scrollController.position.pixels + scrollSpeed);
        }
      } else {
        _pauseCounter++;
        if (_pauseCounter >= pauseDuration) {
          _scrollingForward = true;
          _pauseCounter = 0;
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _ticker.start());
  }

  @override
  void didUpdateWidget(CollapsibleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded) {
      setState(() {
        _isExpanded = widget.isExpanded;
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                child: Row(
                  children: [
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
              ),
            ),
          ],
        ),
        if (_isExpanded && widget.children.isNotEmpty)
          Stack(
            children: [
              Positioned(
                left: 24,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: Colors.grey,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.children.length,
                  itemBuilder: (context, index) {
                    return widget.children[index];
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }
}
