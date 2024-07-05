// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'component.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Component _$ComponentFromJson(Map<String, dynamic> json) => Component(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String,
      sensorType: json['sensorType'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$ComponentToJson(Component instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parentId': instance.parentId,
      'sensorType': instance.sensorType,
      'status': instance.status,
    };
