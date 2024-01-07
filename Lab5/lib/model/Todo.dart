class Todo {
  int id; // You can set this when adding to a database
  final String title;
  final String time;
  final String details;
  final String goal;
  final String emotion;

  Todo({
    required this.id,
    required this.title,
    required this.time,
    required this.details,
    required this.goal,
    required this.emotion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'details': details,
      'goal': goal,
      'emotion': emotion,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      time: map['time'],
      details: map['details'],
      goal: map['goal'],
      emotion: map['emotion'],
    );
  }

  int getId() {
    return id;
  }
}
