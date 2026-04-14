import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/focus_timer_cubit.dart';
import '../cubits/star_game_cubit.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/section_card.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FocusTimerCubit, FocusTimerState>(
      listenWhen: (previous, current) =>
          previous.phase != current.phase || previous.status != current.status,
      listener: (context, timerState) {
        final available =
            timerState.phase == FocusPhase.breakTime &&
            timerState.status == FocusTimerStatus.running;
        context.read<StarGameCubit>().setAvailability(available);
      },
      child: AppScaffold(
        title: 'Star Tap Break',
        subtitle:
            'Catch as many stars as you can during the first 30 seconds of your break.',
        child: BlocBuilder<StarGameCubit, StarGameState>(
          builder: (context, gameState) {
            final timerState = context.watch<FocusTimerCubit>().state;
            final shouldBeAvailable =
                timerState.phase == FocusPhase.breakTime &&
                timerState.status == FocusTimerStatus.running;
            if (gameState.isAvailable != shouldBeAvailable) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.read<StarGameCubit>().setAvailability(
                    shouldBeAvailable,
                  );
                }
              });
            }
            final breakLabel = timerState.phase == FocusPhase.breakTime
                ? 'Break remaining: ${timerState.formattedTime}'
                : 'Start a focus session to unlock your break game.';

            return ListView(
              children: [
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        breakLabel,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _StatChip(
                            label: 'Score',
                            value: '${gameState.score}',
                          ),
                          const SizedBox(width: 12),
                          _StatChip(
                            label: 'Best',
                            value: '${gameState.bestScore}',
                          ),
                          const SizedBox(width: 12),
                          _StatChip(
                            label: 'Time',
                            value: '${gameState.remainingSeconds}s',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: 360,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gameState.isAvailable
                                ? const [Color(0xFF183D33), Color(0xFF245C4D)]
                                : const [Color(0xFFBFCBB8), Color(0xFF9DB0A2)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Stack(
                            children: [
                              const Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        Color(0x33FFFFFF),
                                        Colors.transparent,
                                      ],
                                      center: Alignment.topCenter,
                                      radius: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              if (gameState.isRunning)
                                ...gameState.stars.map(
                                  (star) => Positioned(
                                    left:
                                        star.x *
                                        MediaQuery.of(context).size.width *
                                        0.76,
                                    top: star.y * 300,
                                    child: GestureDetector(
                                      onTap: () => context
                                          .read<StarGameCubit>()
                                          .tapStar(star.id),
                                      child: const _StarBubble(),
                                    ),
                                  ),
                                )
                              else
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text(
                                      gameState.isAvailable
                                          ? gameState.hasFinished
                                                ? 'Round finished. Start another one while your break lasts.'
                                                : 'Break mode is live. Press play and start tapping.'
                                          : 'The game stays locked until you enter an active break.',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed:
                              gameState.isAvailable && !gameState.isRunning
                              ? () => context.read<StarGameCubit>().start()
                              : null,
                          icon: const Icon(Icons.play_arrow),
                          label: Text(
                            gameState.isRunning
                                ? 'Playing...'
                                : 'Start break round',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StarBubble extends StatelessWidget {
  const _StarBubble();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.75, end: 1),
      duration: const Duration(milliseconds: 220),
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFFFD166),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55FFD166),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(
          Icons.star_rounded,
          color: Color(0xFF8A5200),
          size: 30,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(label),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
