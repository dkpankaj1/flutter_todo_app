class TodoModel {
  int id;
  String title;
  String description;
  int isComplete;

  TodoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isComplete,
  });
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isComplete: json['is_completed'] is bool
          ? (json['is_completed'] ? 1 : 0)
          : (json['is_completed'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "is_completed": isComplete,
    };
  }

  @override
  String toString() {
    return 'TodoModel(title: $title, description: $description, isComplete: $isComplete)';
  }
}
