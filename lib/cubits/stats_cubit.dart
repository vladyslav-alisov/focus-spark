import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/local_storage_repository.dart';

class StatsState {
  const StatsState({
    this.completedTasks = 0,
    this.focusSessions = 0,
    this.bestGameScore = 0,
    this.isLoading = true,
  });

  final int completedTasks;
  final int focusSessions;
  final int bestGameScore;
  final bool isLoading;

  StatsState copyWith({
    int? completedTasks,
    int? focusSessions,
    int? bestGameScore,
    bool? isLoading,
  }) {
    return StatsState(
      completedTasks: completedTasks ?? this.completedTasks,
      focusSessions: focusSessions ?? this.focusSessions,
      bestGameScore: bestGameScore ?? this.bestGameScore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class StatsCubit extends Cubit<StatsState> {
  StatsCubit(this._repository) : super(const StatsState());

  final LocalStorageRepository _repository;

  Future<void> load() async {
    emit(
      state.copyWith(
        completedTasks: _repository.loadCompletedTaskCount(),
        focusSessions: _repository.loadFocusSessionCount(),
        bestGameScore: _repository.loadBestGameScore(),
        isLoading: false,
      ),
    );
  }

  Future<void> incrementCompletedTasks() async {
    final value = state.completedTasks + 1;
    await _repository.saveCompletedTaskCount(value);
    emit(state.copyWith(completedTasks: value));
  }

  Future<void> setCompletedTasks(int value) async {
    await _repository.saveCompletedTaskCount(value);
    emit(state.copyWith(completedTasks: value));
  }

  Future<void> incrementFocusSessions() async {
    final value = state.focusSessions + 1;
    await _repository.saveFocusSessionCount(value);
    emit(state.copyWith(focusSessions: value));
  }

  Future<void> saveBestGameScore(int score) async {
    if (score <= state.bestGameScore) {
      return;
    }
    await _repository.saveBestGameScore(score);
    emit(state.copyWith(bestGameScore: score));
  }
}
