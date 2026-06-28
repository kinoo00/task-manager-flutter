class Project {
  final int id;
  final String title;
  final String? description;
  final String status; // Active, Completed, etc.

  Project({
    required this.id,
    required this.title,
    this.description,
    required this.status,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'status': status,
  };
}