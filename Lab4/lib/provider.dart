import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'todo.dart'; // Import the Todo model
import 'repository.dart'; // Import your TodoRepository

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  Future<void> loadTodos() async {
    // Load todos from your repository here
    // Replace this with your actual todo loading logic
    _todos = await TodoRepository().getAllTodos();
    notifyListeners();
  }

  Future<void> addTodo(Todo newTodo) async {
    // Add a todo using your repository
    await TodoRepository().addTodo(newTodo);
    await loadTodos(); // Refresh the todo list
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    // Update a todo using your repository
    await TodoRepository().updateTodo(updatedTodo);
    await loadTodos(); // Refresh the todo list
  }

  Future<void> deleteTodo(int id) async {
    // Delete a todo using your repository
    await TodoRepository().deleteTodo(id);
    await loadTodos(); // Refresh the todo list
  }
}
