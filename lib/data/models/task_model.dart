class Task {
  final int id;
  final int projectId;
  final String title;
  final String status; // Pending, In Progress, Done
  final String priority; // Low, Medium, High

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.status,
    required this.priority,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      projectId: json['projectId'],
      title: json['title'],
      status: json['status'] ?? 'Pending',
      priority: json['priority'] ?? 'Medium',
    );
  }

  Task copyWith({int? id, int? projectId, String? title, String? status, String? priority}) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      status: status ?? this.status,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'title': title,
    'status': status,
    'priority': priority,
  };
}