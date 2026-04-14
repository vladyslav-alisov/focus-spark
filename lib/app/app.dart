import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/focus_timer_cubit.dart';
import '../cubits/star_game_cubit.dart';
import '../cubits/stats_cubit.dart';
import '../cubits/tasks_cubit.dart';
import '../repositories/local_storage_repository.dart';
import '../view/focus_tap_shell.dart';
import 'theme.dart';

class FocusTapApp extends StatelessWidget {
  const FocusTapApp({required this.storageRepository, super.key});

  final LocalStorageRepository storageRepository;

  static Future<FocusTapApp> create() async {
    final repository = await LocalStorageRepository.create();
    return FocusTapApp(storageRepository: repository);
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LocalStorageRepository>.value(
          value: storageRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                TasksCubit(context.read<LocalStorageRepository>())..load(),
          ),
          BlocProvider(
            create: (context) =>
                StatsCubit(context.read<LocalStorageRepository>())..load(),
          ),
          BlocProvider(
            create: (context) =>
                FocusTimerCubit(statsCubit: context.read<StatsCubit>()),
          ),
          BlocProvider(
            create: (context) =>
                StarGameCubit(statsCubit: context.read<StatsCubit>()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FocusTap',
          theme: buildFocusTapTheme(),
          home: const FocusTapShell(),
        ),
      ),
    );
  }
}
