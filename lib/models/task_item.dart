import 'task_priority.dart';

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
  });

  final String id;
  final String title;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime createdAt;

  TaskItem copyWith({
    String? id,
    String? title,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority.name,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      priority: TaskPriority.fromName(json['priority'] as String? ?? ''),
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
