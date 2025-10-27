import 'package:shared_preferences/shared_preferences.dart';

class ArrivalStateService {
  static const String _keyPrefix = 'arrival_confirmed_';
  static const String _keyWaitingTime = 'waiting_time_';

  final Map<int, bool> _memoryCache = {};
  final Map<int, int> _waitingTimeCache = {};

  Future<bool> isArrivalConfirmed(int courseId) async {
    if (_memoryCache.containsKey(courseId)) {
      return _memoryCache[courseId]!;
    }

    final prefs = await SharedPreferences.getInstance();
    final confirmed = prefs.getBool('$_keyPrefix$courseId') ?? false;
    _memoryCache[courseId] = confirmed;
    return confirmed;
  }

  Future<void> setArrivalConfirmed(int courseId, bool confirmed) async {
    _memoryCache[courseId] = confirmed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyPrefix$courseId', confirmed);
  }

  Future<int> getWaitingTime(int courseId) async {
    if (_waitingTimeCache.containsKey(courseId)) {
      return _waitingTimeCache[courseId]!;
    }

    final prefs = await SharedPreferences.getInstance();
    final time = prefs.getInt('$_keyWaitingTime$courseId') ?? 0;
    _waitingTimeCache[courseId] = time;
    return time;
  }

  Future<void> setWaitingTime(int courseId, int seconds) async {
    _waitingTimeCache[courseId] = seconds;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_keyWaitingTime$courseId', seconds);
  }

  Future<void> clearCourseState(int courseId) async {
    _memoryCache.remove(courseId);
    _waitingTimeCache.remove(courseId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$courseId');
    await prefs.remove('$_keyWaitingTime$courseId');
  }
}
