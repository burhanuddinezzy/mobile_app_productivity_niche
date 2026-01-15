import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../models/tree_model.dart';
import '../models/session_model.dart';

enum TimerState { idle, running, paused, completed, failed }

class TimerProvider with ChangeNotifier {
  Timer? _timer;
  TimerState _state = TimerState.idle;
  int _remainingSeconds = 0;
  int _totalSeconds = 1800; // Default 30 minutes
  TreeType _currentTreeType = TreeType.oak;
  String? _currentSessionId;
  DateTime? _sessionStartTime;

  TimerState get state => _state;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  TreeType get currentTreeType => _currentTreeType;
  double get progress => _totalSeconds > 0 ? (_totalSeconds - _remainingSeconds) / _totalSeconds : 0;
  int get elapsedSeconds => _totalSeconds - _remainingSeconds;

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void setDuration(int minutes) {
    if (_state == TimerState.idle) {
      _totalSeconds = minutes * 60;
      _remainingSeconds = _totalSeconds;
      notifyListeners();
    }
  }

  void setTreeType(TreeType type) {
    if (_state == TimerState.idle) {
      _currentTreeType = type;
      notifyListeners();
    }
  }

  Future<void> startTimer() async {
    if (_state != TimerState.idle) return;

    _state = TimerState.running;
    _remainingSeconds = _totalSeconds;
    _currentSessionId = const Uuid().v4();
    _sessionStartTime = DateTime.now();

    // Save session start
    final sessionsBox = Hive.box<SessionModel>('sessions');
    final session = SessionModel(
      id: _currentSessionId!,
      startTime: _sessionStartTime!,
      plannedDuration: _totalSeconds,
      treeType: _currentTreeType,
    );
    await sessionsBox.put(_currentSessionId, session);

    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _completeSession();
      }
    });
  }

  Future<void> _completeSession() async {
    _timer?.cancel();
    _state = TimerState.completed;

    // Update session
    final sessionsBox = Hive.box<SessionModel>('sessions');
    final session = sessionsBox.get(_currentSessionId);
    if (session != null) {
      session.endTime = DateTime.now();
      session.actualDuration = _totalSeconds;
      session.completed = true;
      session.coinsEarned = (_totalSeconds / 60 / 5).floor();
      await session.save();
    }

    // Save tree
    final treesBox = Hive.box<TreeModel>('trees');
    final tree = TreeModel(
      id: _currentSessionId!,
      type: _currentTreeType,
      plantedAt: _sessionStartTime!,
      durationMinutes: _totalSeconds ~/ 60,
      isDead: false,
    );
    await treesBox.put(_currentSessionId, tree);

    notifyListeners();
  }

  Future<void> giveUp() async {
    if (_state != TimerState.running) return;

    _timer?.cancel();
    _state = TimerState.failed;

    // Update session as failed
    final sessionsBox = Hive.box<SessionModel>('sessions');
    final session = sessionsBox.get(_currentSessionId);
    if (session != null) {
      session.endTime = DateTime.now();
      session.actualDuration = _totalSeconds - _remainingSeconds;
      session.completed = false;
      await session.save();
    }

    // Save dead tree
    final treesBox = Hive.box<TreeModel>('trees');
    final tree = TreeModel(
      id: _currentSessionId!,
      type: _currentTreeType,
      plantedAt: _sessionStartTime!,
      durationMinutes: (_totalSeconds - _remainingSeconds) ~/ 60,
      isDead: true,
    );
    await treesBox.put(_currentSessionId, tree);

    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _state = TimerState.idle;
    _remainingSeconds = _totalSeconds;
    _currentSessionId = null;
    _sessionStartTime = null;
    notifyListeners();
  }

  int getCoinsForCurrentSession() {
    if (_state == TimerState.completed) {
      return (_totalSeconds / 60 / 5).floor();
    }
    return 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}