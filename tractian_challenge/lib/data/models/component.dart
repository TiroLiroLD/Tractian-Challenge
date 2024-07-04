import 'package:json_annotation/json_annotation.dart';

part 'component.g.dart';

@JsonSerializable()
class Component {
  final String id;
  final String name;
  final String parentId;
  final String sensorType;
  final String status;

  Component({
    required this.id,
    required this.name,
    required this.parentId,
    required this.sensorType,
    required this.status,
  });

  factory Component.fromJson(Map<String, dynamic> json) => _$ComponentFromJson(json);
  Map<String, dynamic> toJson() => _$ComponentToJson(this);
}
