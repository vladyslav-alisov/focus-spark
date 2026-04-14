import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/focus_timer_cubit.dart';
import '../cubits/tasks_cubit.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/section_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'FocusTap',
      subtitle:
          'Plan your work, protect your focus, and unlock a playful break.',
      child: ListView(
        children: [
          BlocBuilder<FocusTimerCubit, FocusTimerState>(
            builder: (context, timerState) {
              final isRunning = timerState.status == FocusTimerStatus.running;
              final phaseLabel = timerState.phase == FocusPhase.focus
                  ? 'Focus sprint'
                  : 'Break mode';
              return SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phaseLabel,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: timerState.progress),
                      duration: const Duration(milliseconds: 450),
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(99),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      timerState.formattedTime,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: isRunning
                          ? context.read<FocusTimerCubit>().pause
                          : context.read<FocusTimerCubit>().start,
                      icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                      label: Text(isRunning ? 'Pause focus' : 'Start focus'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          BlocBuilder<TasksCubit, TasksState>(
            builder: (context, taskState) {
              final tasks = taskState.pendingTasks.take(3).toList();
              return SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s tasks',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (tasks.isEmpty)
                      const Text(
                        'Add a few tasks to give your next focus block a target.',
                      )
                    else
                      ...tasks.map(
                        (task) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, size: 10),
                              const SizedBox(width: 12),
                              Expanded(child: Text(task.title)),
                              Text(task.priority.label),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
