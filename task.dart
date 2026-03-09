class Task {
  int? id;
  String title;
  String description;
  String dueDate;
  int priority;
  String color;
  bool completed;
  String createdAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.color,
    this.completed = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority,
      'color': color,
      'completed': completed ? 1 : 0,
      'createdAt': createdAt,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: map['dueDate'],
      priority: map['priority'],
      color: map['color'],
      completed: map['completed'] == 1,
      createdAt: map['createdAt'],
    );
  }
}
