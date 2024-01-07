import 'package:flutter/material.dart';
import '../model/Todo.dart';

class TodoNotifier extends ChangeNotifier {
  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  void setTodos(List<Todo> todos) {
    _todos = todos;
    notifyListeners();
  }

  void addTodo(Todo todo) {
    _todos.add(todo);
    notifyListeners();
  }

  void deleteTodo(int id) {
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }

  void updateTodo(Todo updatedTodo) {
    final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index != -1) {
      _todos[index] = updatedTodo;
      notifyListeners();
    }
  }

  bool todoExists(int id) {
    return todos.any((todo) => todo.id == id);
  }

  int findHighestId() {
    int highestId = 0;
    for (final todo in _todos) {
      if (todo.id > highestId) {
        highestId = todo.id;
      }
    }
    print("Found highest id is: $highestId");
    return highestId;
  }

  int findLowestId() {
    int lowestId = _todos[0].getId();
    for (final todo in _todos) {
      if (todo.id < lowestId) {
        lowestId = todo.id;
      }
    }

    print("Found lowest id is: $lowestId");
    return lowestId;
  }
}
