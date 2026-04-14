import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'stats_cubit.dart';

const kRemainigSeconds = 30;

class StarTarget {
  const StarTarget({
    required this.id,
    required this.x,
    required this.y,
    required this.spawnedAt,
  });

  final String id;
  final double x;
  final double y;
  final DateTime spawnedAt;
}

class StarGameState {
  const StarGameState({
    this.stars = const [],
    this.score = 0,
    this.bestScore = 0,
    this.remainingSeconds = kRemainigSeconds,
    this.isRunning = false,
    this.isAvailable = false,
    this.hasFinished = false,
  });

  final List<StarTarget> stars;
  final int score;
  final int bestScore;
  final int remainingSeconds;
  final bool isRunning;
  final bool isAvailable;
  final bool hasFinished;

  StarGameState copyWith({
    List<StarTarget>? stars,
    int? score,
    int? bestScore,
    int? remainingSeconds,
    bool? isRunning,
    bool? isAvailable,
    bool? hasFinished,
  }) {
    return StarGameState(
      stars: stars ?? this.stars,
      score: score ?? this.score,
      bestScore: bestScore ?? this.bestScore,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isAvailable: isAvailable ?? this.isAvailable,
      hasFinished: hasFinished ?? this.hasFinished,
    );
  }
}

class StarGameCubit extends Cubit<StarGameState> {
  StarGameCubit({required StatsCubit statsCubit})
    : _statsCubit = statsCubit,
      super(StarGameState(bestScore: statsCubit.state.bestGameScore));

  final StatsCubit _statsCubit;
  final Random _random = Random();
  Timer? _gameTimer;
  Timer? _spawnTimer;

  void setAvailability(bool isAvailable) {
    emit(
      state.copyWith(
        isAvailable: isAvailable,
        bestScore: _statsCubit.state.bestGameScore,
      ),
    );
    if (!isAvailable) {
      stop(clearAvailability: false);
    }
  }

  void start() {
    if (!state.isAvailable || state.isRunning) {
      return;
    }

    emit(
      state.copyWith(
        isRunning: true,
        hasFinished: false,
        score: 0,
        remainingSeconds: kRemainigSeconds,
        stars: const [],
      ),
    );

    _spawnStar();
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 450), (_) {
      _spawnStar();
      _purgeExpiredStars();
    });
  }

  void tapStar(String id) {
    if (!state.isRunning) {
      return;
    }

    final updatedStars = state.stars.where((star) => star.id != id).toList();
    emit(state.copyWith(stars: updatedStars, score: state.score + 1));
  }

  void stop({bool clearAvailability = true}) {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    emit(
      state.copyWith(
        isRunning: false,
        stars: const [],
        remainingSeconds: state.remainingSeconds == 0
            ? 0
            : state.remainingSeconds,
        isAvailable: clearAvailability ? false : state.isAvailable,
      ),
    );
  }

  void _tick() {
    final remaining = state.remainingSeconds - 1;
    _purgeExpiredStars();

    if (remaining <= 0) {
      print("finish round");
      _finishRound();
      return;
    }

    emit(state.copyWith(remainingSeconds: remaining));
  }

  void _spawnStar() {
    if (!state.isRunning) {
      return;
    }

    final updatedStars = [...state.stars];
    updatedStars.add(
      StarTarget(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        x: _random.nextDouble() * 0.82 + 0.04,
        y: _random.nextDouble() * 0.72 + 0.10,
        spawnedAt: DateTime.now(),
      ),
    );
    emit(state.copyWith(stars: updatedStars));
  }

  void _purgeExpiredStars() {
    final now = DateTime.now();
    final active = state.stars
        .where(
          (star) => now.difference(star.spawnedAt) < const Duration(seconds: 1),
        )
        .toList();
    if (active.length != state.stars.length) {
      emit(state.copyWith(stars: active));
    }
  }

  Future<void> _finishRound() async {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    final score = state.score;
    await _statsCubit.saveBestGameScore(score);
    emit(
      state.copyWith(
        isRunning: false,
        hasFinished: true,
        remainingSeconds: 0,
        stars: const [],
        bestScore: _statsCubit.state.bestGameScore,
      ),
    );
  }

  @override
  Future<void> close() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    return super.close();
  }
}
