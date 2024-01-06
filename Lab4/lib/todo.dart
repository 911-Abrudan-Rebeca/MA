class Todo {
  int id;
  String title;
  String time;
  String details;
  String goal;
  String emotion;

  Todo({
    required this.id,
    required this.title,
    required this.time,
    required this.details,
    required this.goal,
    required this.emotion,
  });

  Todo copyWith({
    int? id,
    String? title,
    String? time,
    String? details,
    String? goal,
    String? emotion,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      details: details ?? this.details,
      goal: goal ?? this.goal,
      emotion: emotion ?? this.emotion,
    );
  }

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, time: $time, details: $details, goal: $goal, emotion: $emotion)';
  }
}