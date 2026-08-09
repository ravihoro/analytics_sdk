import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_event.freezed.dart';
part 'analytics_event.g.dart';

@freezed
abstract class AnalyticsEvent with _$AnalyticsEvent {
  const factory AnalyticsEvent({
    required String eventId,
    required String name,
    required DateTime timestamp,
    required String anonymousId,
    required String sessionId,
    String? userId,
    @Default({}) Map<String, dynamic> properties,
    String? platform,
    String? appVersion,
  }) = _AnalyticsEvent;

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsEventFromJson(json);
}
