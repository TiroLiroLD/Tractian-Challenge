// lib/models/node.dart

import 'package:json_annotation/json_annotation.dart';

part 'node.g.dart';

@JsonSerializable()
class Node {
  final String id;
  final String name;
  final String? parentId;
  final String? locationId; // For assets that reference a location
  final String? sensorType;
  final String? status;
  bool shouldRender;
  List<Node> children;
  bool locationNode;

  Node({
    required this.id,
    required this.name,
    this.parentId,
    this.locationId,
    this.sensorType,
    this.status,
    this.shouldRender = false,
    this.children = const [],
    this.locationNode = false,
  });

  factory Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);
  Map<String, dynamic> toJson() => _$NodeToJson(this);

  void propagateRenderStatus() {
    if (children.any((child) => child.shouldRender)) {
      shouldRender = true;
    }
  }
}
