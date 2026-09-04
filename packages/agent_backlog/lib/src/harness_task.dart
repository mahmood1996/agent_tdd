/// Value object representing a task or feature spec item in a backlog
final class HarnessTask {
  final int id;
  final String title;
  final String status; // 'pending', 'in_progress', 'done'
  final Map<String, dynamic> metadata;

  const HarnessTask({
    required this.id,
    required this.title,
    required this.status,
    this.metadata = const {},
  });

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isDone => status == 'done';

  HarnessTask copyWith({
    int? id,
    String? title,
    String? status,
    Map<String, dynamic>? metadata,
  }) {
    return HarnessTask(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'metadata': metadata,
    };
  }

  factory HarnessTask.fromJson(Map<String, dynamic> json) {
    return HarnessTask(
      id: json['id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
    );
  }
}
