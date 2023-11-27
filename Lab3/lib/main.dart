import 'package:flutter/material.dart';
import 'repository.dart';
import 'todo.dart'; // Import your Todo model
import 'todo_detail.dart';
import 'todo_add.dart';

void main() {
  runApp(MaterialApp(
    home: MainPage(),
  ));
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TodoRepository _todoRepository = TodoRepository();
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() async {
    final todos = await _todoRepository.getAllTodos();
    setState(() {
      _todos = todos;
    });
  }

  void _addTodo() async {
    // Navigate to the page for adding a new todo and receive the result
    final newTodoAdded = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoAddPage(),
      ),
    );

    if (newTodoAdded == true) {
      // Reload todos if a new todo was added successfully
      _loadTodos();
    }
  }

  void _deleteTodo(int id) async {
    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this todo?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () async {
                // Delete the todo and reload todos
                await _todoRepository.deleteTodo(id);
                _loadTodos();

                // Close the dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateTodo(Todo todo) async {
    final result = await _todoRepository.updateTodo(todo);
    print('Todo updated successfully');

    if (result > 0) {
      _loadTodos();
      print('Todo updated successfully');
    } else {
      print('Failed to update todo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        backgroundColor: Color(0xFFD09494), // Set the background color for the app bar
      ),
      body: Container(
        color: Color(0xFFD09494), // Set the background color for the entire page
        child: ListView.builder(
          itemCount: _todos.length,
          itemBuilder: (context, index) {
            final todo = _todos[index];
            return Card(
              color: Color(0xFFFBF3F3), // Set the background color for each todo
              child: ListTile(
                title: Text(todo.title),
                subtitle: Text(todo.details),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TodoDetailPage(
                        todo: todo,
                        onUpdate: (updatedTodo) {
                          _updateTodo(updatedTodo);
                        },
                        onDelete: _deleteTodo,
                      ),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteTodo(todo.id);
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: Icon(Icons.add),
        backgroundColor: Color(0xFFC17171), // Set the background color for the add button
      ),
    );
  }
}
