import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/stats_cubit.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/section_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Stats',
      subtitle: 'Small wins, steady streaks, and your best break-game run.',
      child: BlocBuilder<StatsCubit, StatsState>(
        builder: (context, state) {
          return ListView(
            children: [
              SectionCard(
                child: Column(
                  children: [
                    _StatRow(
                      label: 'Completed tasks',
                      value: '${state.completedTasks}',
                      icon: Icons.task_alt_outlined,
                    ),
                    const SizedBox(height: 18),
                    _StatRow(
                      label: 'Focus sessions',
                      value: '${state.focusSessions}',
                      icon: Icons.timer_outlined,
                    ),
                    const SizedBox(height: 18),
                    _StatRow(
                      label: 'Best game score',
                      value: '${state.bestGameScore}',
                      icon: Icons.star_outline_rounded,
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

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}
