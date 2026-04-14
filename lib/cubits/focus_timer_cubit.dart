import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'stats_cubit.dart';

enum FocusPhase { focus, breakTime }

enum FocusTimerStatus { idle, running, paused }

class FocusTimerState {
  const FocusTimerState({
    required this.phase,
    required this.status,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.completedFocusSessions = 0,
  });

  const FocusTimerState.initial()
    : phase = FocusPhase.focus,
      status = FocusTimerStatus.idle,
      remainingSeconds = focusDurationSeconds,
      totalSeconds = focusDurationSeconds,
      completedFocusSessions = 0;

  static const int focusDurationSeconds = 25 * 60;
  static const int breakDurationSeconds = 5 * 60;

  final FocusPhase phase;
  final FocusTimerStatus status;
  final int remainingSeconds;
  final int totalSeconds;
  final int completedFocusSessions;

  double get progress =>
      1 - (remainingSeconds / totalSeconds).clamp(0.0, 1.0).toDouble();

  FocusTimerState copyWith({
    FocusPhase? phase,
    FocusTimerStatus? status,
    int? remainingSeconds,
    int? totalSeconds,
    int? completedFocusSessions,
  }) {
    return FocusTimerState(
      phase: phase ?? this.phase,
      status: status ?? this.status,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      completedFocusSessions:
          completedFocusSessions ?? this.completedFocusSessions,
    );
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class FocusTimerCubit extends Cubit<FocusTimerState> {
  FocusTimerCubit({required StatsCubit statsCubit})
    : _statsCubit = statsCubit,
      super(const FocusTimerState.initial());

  final StatsCubit _statsCubit;
  Timer? _timer;

  void start() {
    if (state.status == FocusTimerStatus.running) {
      return;
    }

    emit(state.copyWith(status: FocusTimerStatus.running));
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    _timer?.cancel();
    emit(state.copyWith(status: FocusTimerStatus.paused));
  }

  void reset() {
    _timer?.cancel();
    final totalSeconds = state.phase == FocusPhase.focus
        ? FocusTimerState.focusDurationSeconds
        : FocusTimerState.breakDurationSeconds;
    emit(
      FocusTimerState(
        phase: state.phase,
        status: FocusTimerStatus.idle,
        remainingSeconds: totalSeconds,
        totalSeconds: totalSeconds,
        completedFocusSessions: state.completedFocusSessions,
      ),
    );
  }

  void skipToFocus() {
    _timer?.cancel();
    emit(
      state.copyWith(
        phase: FocusPhase.focus,
        status: FocusTimerStatus.idle,
        remainingSeconds: FocusTimerState.focusDurationSeconds,
        totalSeconds: FocusTimerState.focusDurationSeconds,
      ),
    );
  }

  void _tick() {
    if (state.remainingSeconds <= 1) {
      _advancePhase();
      return;
    }

    emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
  }

  Future<void> _advancePhase() async {
    _timer?.cancel();

    if (state.phase == FocusPhase.focus) {
      final sessions = state.completedFocusSessions + 1;
      await _statsCubit.incrementFocusSessions();
      emit(
        state.copyWith(
          phase: FocusPhase.breakTime,
          status: FocusTimerStatus.running,
          remainingSeconds: FocusTimerState.breakDurationSeconds,
          totalSeconds: FocusTimerState.breakDurationSeconds,
          completedFocusSessions: sessions,
        ),
      );
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      return;
    }

    emit(
      state.copyWith(
        phase: FocusPhase.focus,
        status: FocusTimerStatus.idle,
        remainingSeconds: FocusTimerState.focusDurationSeconds,
        totalSeconds: FocusTimerState.focusDurationSeconds,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
