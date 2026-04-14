import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/task_item.dart';
import '../models/task_priority.dart';
import '../repositories/local_storage_repository.dart';
import 'stats_cubit.dart';

class TasksState {
  const TasksState({this.tasks = const [], this.isLoading = true});

  final List<TaskItem> tasks;
  final bool isLoading;

  List<TaskItem> get pendingTasks =>
      tasks.where((task) => !task.isCompleted).toList()..sort(_sortTasks);

  List<TaskItem> get completedTasks =>
      tasks.where((task) => task.isCompleted).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  TasksState copyWith({List<TaskItem>? tasks, bool? isLoading}) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static int _sortTasks(TaskItem a, TaskItem b) {
    final priorityOrder = b.priority.weight.compareTo(a.priority.weight);
    if (priorityOrder != 0) {
      return priorityOrder;
    }
    return a.createdAt.compareTo(b.createdAt);
  }
}

class TasksCubit extends Cubit<TasksState> {
  TasksCubit(this._repository) : super(const TasksState());

  final LocalStorageRepository _repository;

  Future<void> load() async {
    final tasks = await _repository.loadTasks();
    emit(state.copyWith(tasks: tasks, isLoading: false));
  }

  Future<void> addTask({
    required String title,
    required TaskPriority priority,
  }) async {
    final task = TaskItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      priority: priority,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    final updated = [...state.tasks, task];
    await _persist(updated);
  }

  Future<void> updateTask(
    TaskItem task, {
    required String title,
    required TaskPriority priority,
  }) async {
    final updated = state.tasks
        .map(
          (item) => item.id == task.id
              ? item.copyWith(title: title.trim(), priority: priority)
              : item,
        )
        .toList();
    await _persist(updated);
  }

  Future<void> toggleTask(TaskItem task, StatsCubit statsCubit) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    final updated = state.tasks
        .map((item) => item.id == task.id ? updatedTask : item)
        .toList();
    await _persist(updated);
    await statsCubit.setCompletedTasks(
      updated.where((item) => item.isCompleted).length,
    );
  }

  Future<void> deleteTask(TaskItem task) async {
    final updated = state.tasks.where((item) => item.id != task.id).toList();
    await _persist(updated);
  }

  Future<void> _persist(List<TaskItem> tasks) async {
    await _repository.saveTasks(tasks);
    emit(state.copyWith(tasks: tasks, isLoading: false));
  }
}
