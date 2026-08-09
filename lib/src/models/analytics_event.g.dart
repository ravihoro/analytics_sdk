// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnalyticsEvent _$AnalyticsEventFromJson(Map<String, dynamic> json) =>
    _AnalyticsEvent(
      eventId: json['eventId'] as String,
      name: json['name'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      anonymousId: json['anonymousId'] as String,
      sessionId: json['sessionId'] as String,
      userId: json['userId'] as String?,
      properties: json['properties'] as Map<String, dynamic>? ?? const {},
      platform: json['platform'] as String?,
      appVersion: json['appVersion'] as String?,
    );

Map<String, dynamic> _$AnalyticsEventToJson(_AnalyticsEvent instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'name': instance.name,
      'timestamp': instance.timestamp.toIso8601String(),
      'anonymousId': instance.anonymousId,
      'sessionId': instance.sessionId,
      'userId': instance.userId,
      'properties': instance.properties,
      'platform': instance.platform,
      'appVersion': instance.appVersion,
    };
