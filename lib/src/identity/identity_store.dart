import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class IdentityStore {
  static const _anonKey = 'analytics_anonymous_id';
  static const _userKey = 'analytics_user_id';

  final SharedPreferences _prefs;

  final _uuid = const Uuid();

  IdentityStore(this._prefs);

  String get anonymousId {
    final existing = _prefs.getString(_anonKey);

    if (existing != null) return existing;

    final id = _uuid.v4();
    _prefs.setString(_anonKey, id);
    return id;
  }

  String? get userId => _prefs.getString(_userKey);

  Future<void> identify(String userId) async {
    await _prefs.setString(_userKey, userId);
  }

  Future<void> reset() async {
    await _prefs.remove(_userKey);

    // Rotate anonymous id so the next person on this device
    // is not tied to the previous account
    await _prefs.setString(_anonKey, _uuid.v4());
  }
}
