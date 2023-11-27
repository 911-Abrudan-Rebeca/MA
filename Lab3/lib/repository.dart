import 'sql/sql_helper.dart'; // Import your SQLHelper class
import 'todo.dart'; // Import the todo model

class TodoRepository {
  // Method to fetch all todos from the database
  Future<List<Todo>> getAllTodos() async {
    final List<Map<String, dynamic>> todoData = await SQLHelper.getTodos();
    return todoData.map((data) => Todo(
      id: data['id'],
      title: data['title'],
      time: data['time'],
      details: data['details'],
      goal: data['goal'],
      emotion: data['emotion'],
    )).toList();
  }

  // Method to add a new todo to the database
  Future<int> addTodo(Todo todo) async {
    return SQLHelper.createTodo(
      todo.title,
      todo.time,
      todo.details,
      todo.goal,
      todo.emotion,
    );
  }

  // Method to update an existing todo in the database
  Future<int> updateTodo(Todo todo) async {
    print('Updating Todo: $todo'); 
    return SQLHelper.updateTodo(
      todo.id,
      todo.title,
      todo.time,
      todo.details,
      todo.goal,
      todo.emotion,
    );
  }

  // Method to delete a todo from the database
  Future<void> deleteTodo(int id) async {
    await SQLHelper.deleteTodo(id);
  }
}