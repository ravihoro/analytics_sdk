import 'package:analytics_sdk/analytics_sdk.dart';

class QueuedEvent {
  final int rowId;
  final AnalyticsEvent event;

  const QueuedEvent({required this.event, required this.rowId});
}
