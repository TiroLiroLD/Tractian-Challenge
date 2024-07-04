import 'package:flutter/material.dart';

class CollapsibleWidget extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final String? status; // Add status to determine icon color

  CollapsibleWidget({
    required this.title,
    required this.icon,
    required this.children,
    this.status,
  });

  @override
  _CollapsibleWidgetState createState() => _CollapsibleWidgetState();
}

class _CollapsibleWidgetState extends State<CollapsibleWidget> {
  bool _isExpanded = false;

  Color? _getStatusColor(String? status) {
    if (status == 'alert') {
      return Colors.red;
    } else if (status == 'operating') {
      return Colors.green;
    } else {
      return null; // No color for undefined status
    }
  }

  @override
  Widget build(BuildContext context) {
    Color? statusColor = _getStatusColor(widget.status);

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
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            if (widget.children.isEmpty)
              SizedBox(
                width: 48, // To maintain alignment with other rows
              ),
            Icon(widget.icon),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (statusColor != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (_isExpanded && widget.children.isNotEmpty)
          Stack(
            children: [
              Positioned(
                left: 24, // Position the vertical line to the left
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
                  physics: NeverScrollableScrollPhysics(),
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
