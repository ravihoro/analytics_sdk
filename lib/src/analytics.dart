import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'config.dart';
import 'identity/identity_store.dart';
import 'models/analytics_event.dart';
import 'network/analytics_client.dart';
import 'queue/event_queue.dart';
import 'session/session_manager.dart';

class Analytics {
  Analytics._();

  static final Analytics instance = Analytics._();

  AnalyticsConfig? _config;
  IdentityStore? _identity;
  SessionManager? _session;
  EventQueue? _queue;
  AnalyticsClient? _client;
  Timer? _flushTimer;
  bool _flushing = false;
  final _uuid = const Uuid();

  bool get isInitialized => _config != null;

  static Future<void> init(AnalyticsConfig config) => instance._init(config);

  Future<void> _init(AnalyticsConfig config) async {
    if (_config != null) return;

    final prefs = await SharedPreferences.getInstance();

    _config = config;
    _identity = IdentityStore(prefs);
    _session = SessionManager(prefs);
    _queue = await EventQueue.create();
    _client = AnalyticsClient(baseUrl: config.baseUrl, apiKey: config.apiKey);

    _flushTimer = Timer.periodic(config.flushInterval, (_) {
      unawaited(flush());
    });

    await flush();

    _log('initialized');
  }

  static Future<void> identify(String userId) => instance._identify(userId);

  static Future<void> reset() => instance._reset();

  static Future<void> track(String name, [Map<String, dynamic>? properties]) =>
      instance._track(name, properties);

  static Future<void> screen(String name, [Map<String, dynamic>? properties]) =>
      instance._track('screen_view', {'screen': name, ...?properties});

  static Future<void> flush() => instance._flush();

  Future<void> _identify(String userId) async {
    _ensureInit();
    await _identity!.identify(userId);
    await _track('identify', {'userId': userId});
  }

  Future<void> _reset() async {
    _ensureInit();
    await _identity!.reset();
    await _track('reset', null);
  }

  Future<void> _track(String name, Map<String, dynamic>? properties) async {
    _ensureInit();
    _session!.touch();

    final event = AnalyticsEvent(
      eventId: _uuid.v4(),
      name: name,
      timestamp: DateTime.now().toUtc(),
      anonymousId: _identity!.anonymousId,
      sessionId: _session!.sessionId,
      userId: _identity!.userId,
      properties: properties ?? const {},
      platform: _platform(),
    );

    await _queue!.enqueue(event);

    _log('queued: $name');

    final pending = await _queue!.length();

    if (pending >= _config!.batchSize) {
      await flush();
    }
  }

  Future<void> _flush() async {
    if (!isInitialized || _flushing) return;

    _flushing = true;

    try {
      while (true) {
        final batch = await _queue!.dequeue(_config!.batchSize);

        if (batch.isEmpty) break;

        try {
          await _client!.upload(batch);
          _log('uploaded ${batch.length} event(s)');
        } catch (e, st) {
          await _queue!.requeue(batch);
          _log('upload failed, requeued: $e');
          if (kDebugMode) {
            debugPrintStack(stackTrace: st);
          }
          break;
        }
      }
    } finally {
      _flushing = false;
    }
  }

  String _platform() {
    if (kIsWeb) return 'web';

    try {
      if (Platform.isAndroid) return 'android';
      if (Platform.isIOS) return 'ios';
    } catch (_) {}

    return 'unknown';
  }

  void _ensureInit() {
    if (isInitialized) {
      throw StateError("Call Analytics.init(...) before using the SDK");
    }
  }

  void _log(String message) {
    if (_config?.debug == true) {
      debugPrint('[Analytics] $message');
    }
  }

  static Future<void> dispose() => instance._dispose();

  Future<void> _dispose() async {
    _flushTimer?.cancel();
    _client?.dispose();
    await _queue?.close();
  }
}
