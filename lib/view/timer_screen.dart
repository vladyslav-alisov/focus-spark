import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/focus_timer_cubit.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/section_card.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Focus Timer',
      subtitle:
          'Classic Pomodoro flow with a break that unlocks the mini-game.',
      child: BlocBuilder<FocusTimerCubit, FocusTimerState>(
        builder: (context, state) {
          final isRunning = state.status == FocusTimerStatus.running;
          return ListView(
            children: [
              SectionCard(
                child: Column(
                  children: [
                    Text(
                      state.phase == FocusPhase.focus
                          ? '25 min focus'
                          : '5 min break',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 220,
                      width: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: state.progress),
                            duration: const Duration(milliseconds: 400),
                            builder: (context, value, _) {
                              return CircularProgressIndicator(
                                value: value,
                                strokeWidth: 14,
                              );
                            },
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.formattedTime,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isRunning
                                    ? 'In progress'
                                    : 'Ready when you are',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: isRunning
                              ? context.read<FocusTimerCubit>().pause
                              : context.read<FocusTimerCubit>().start,
                          icon: Icon(
                            isRunning ? Icons.pause : Icons.play_arrow,
                          ),
                          label: Text(isRunning ? 'Pause' : 'Start'),
                        ),
                        OutlinedButton.icon(
                          onPressed: context.read<FocusTimerCubit>().reset,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                        ),
                        if (state.phase == FocusPhase.breakTime)
                          OutlinedButton.icon(
                            onPressed: context
                                .read<FocusTimerCubit>()
                                .skipToFocus,
                            icon: const Icon(Icons.skip_next_outlined),
                            label: const Text('End break'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Completed sessions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${state.completedFocusSessions}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
