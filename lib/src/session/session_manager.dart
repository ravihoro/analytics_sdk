import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SessionManager {
  static const _sessionKey = 'analytics_session_id';
  static const _lastActiveKey = 'analytics_last_active_ms';

  /// If idle longer than this, start a new session
  static const idleTimeout = Duration(minutes: 30);

  final SharedPreferences _prefs;

  final _uuid = const Uuid();

  SessionManager(this._prefs);

  String get sessionId {
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _prefs.getInt(_lastActiveKey);

    final current = _prefs.getString(_sessionKey);

    final expired =
        last == null ||
        now - last > idleTimeout.inMilliseconds ||
        current == null;

    if (expired) {
      final id = _uuid.v4();
      _prefs.setString(_sessionKey, id);
      _prefs.setInt(_lastActiveKey, now);
      return id;
    }

    _prefs.setInt(_lastActiveKey, now);
    return current;
  }

  /// Call whenever an event is tracked so idle timeout resets
  void touch() {
    _prefs.setInt(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);
  }
}
