import 'package:shared_preferences/shared_preferences.dart';

class PauseStateService {
  static const String _keyPauseActive = 'pause_active_';
  static const String _keyPauseStartTimestamp = 'pause_start_timestamp_';

  final Map<int, bool> _pauseActiveCache = {};
  final Map<int, int> _pauseStartTimestampCache = {};

  Future<bool> isPaused(int courseId) async {
    if (_pauseActiveCache.containsKey(courseId)) {
      return _pauseActiveCache[courseId]!;
    }

    final prefs = await SharedPreferences.getInstance();
    final paused = prefs.getBool('$_keyPauseActive$courseId') ?? false;
    _pauseActiveCache[courseId] = paused;
    return paused;
  }

  Future<void> setPaused(int courseId, bool paused) async {
    _pauseActiveCache[courseId] = paused;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyPauseActive$courseId', paused);
  }

  Future<int?> getPauseStartTimestamp(int courseId) async {
    if (_pauseStartTimestampCache.containsKey(courseId)) {
      return _pauseStartTimestampCache[courseId]!;
    }

    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('$_keyPauseStartTimestamp$courseId');
    if (timestamp != null) {
      _pauseStartTimestampCache[courseId] = timestamp;
    }
    return timestamp;
  }

  Future<void> setPauseStartTimestamp(int courseId, int timestamp) async {
    _pauseStartTimestampCache[courseId] = timestamp;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_keyPauseStartTimestamp$courseId', timestamp);
  }

  /// Calculate elapsed pause time in seconds from stored timestamp
  int getPauseElapsedTime(int courseId) {
    final startTimestamp = _pauseStartTimestampCache[courseId];
    if (startTimestamp == null) return 0;

    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final elapsed = currentTimestamp - startTimestamp;
    return elapsed > 0 ? elapsed : 0;
  }

  Future<void> clearPauseState(int courseId) async {
    _pauseActiveCache.remove(courseId);
    _pauseStartTimestampCache.remove(courseId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPauseActive$courseId');
    await prefs.remove('$_keyPauseStartTimestamp$courseId');
  }
}
