// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Node _$NodeFromJson(Map<String, dynamic> json) => Node(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      locationId: json['locationId'] as String?,
      sensorType: json['sensorType'] as String?,
      status: json['status'] as String?,
      shouldRender: json['shouldRender'] as bool? ?? false,
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => Node.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      locationNode: json['locationNode'] as bool? ?? false,
    );

Map<String, dynamic> _$NodeToJson(Node instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parentId': instance.parentId,
      'locationId': instance.locationId,
      'sensorType': instance.sensorType,
      'status': instance.status,
      'shouldRender': instance.shouldRender,
      'children': instance.children,
      'locationNode': instance.locationNode,
    };
