class TodoModel {
  int id;
  String title;
  String description;
  bool isCompleted;
  DateTime? createdAt;
  DateTime? updatedAt;

  TodoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    this.createdAt,
    this.updatedAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isCompleted: json['is_completed'] is bool
          ? json['is_completed']
          : (json['is_completed'] == 1 || json['is_completed'] == '1'),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "is_completed": isCompleted,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      "title": title,
      "description": description,
      "is_completed": isCompleted,
    };
  }

  TodoModel copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TodoModel(id: $id, title: $title, description: $description, isCompleted: $isCompleted)';
  }
}
