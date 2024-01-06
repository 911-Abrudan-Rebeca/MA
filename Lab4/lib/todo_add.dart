import 'package:flutter/material.dart';
import 'repository.dart'; // Import your TodoRepository
import 'todo.dart'; // Import the Todo model

class TodoAddPage extends StatefulWidget {
  @override
  _TodoAddPageState createState() => _TodoAddPageState();
}

class _TodoAddPageState extends State<TodoAddPage> {
  final TodoRepository _todoRepository = TodoRepository();

  // Create a Todo object to store the form data
  Todo _newTodo = Todo(
    id: 0,
    title: '',
    time: '',
    details: '',
    goal: '',
    emotion: '',
  );

  final _formKey = GlobalKey<FormState>();

  void _saveTodo() async {
    if (_formKey.currentState!.validate()) {
      // Save the new todo to the database
      final newTodoId = await _todoRepository.addTodo(_newTodo);

      if (newTodoId > 0) {
        // Todo was added successfully
        print('Todo added successfully');
        Navigator.pop(context, true); // Return 'true' to indicate success
      } else {
        // Failed to add todo
        print('Failed to add todo');
        Navigator.pop(context, false); // Return 'false' to indicate failure
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Todo'),
      ),
      body: Container(
        color: Color(0xFFFBF3F3), // Set the background color for the entire page
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Color(0xFFFBF3F3)),
                  fillColor: Color(0xFFD09494), // Set the background color for the text field
                  filled: true,
                ),
                style: TextStyle(color: Color(0xFFFBF3F3)),
                onChanged: (value) {
                  setState(() {
                    _newTodo.title = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Time',
                  labelStyle: TextStyle(color: Color(0xFFFBF3F3)),
                  fillColor: Color(0xFFD09494), // Set the background color for the text field
                  filled: true,
                ),
                style: TextStyle(color: Color(0xFFFBF3F3)),
                onChanged: (value) {
                  _newTodo.time = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a time';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Details',
                  labelStyle: TextStyle(color: Color(0xFFFBF3F3)),
                  fillColor: Color(0xFFD09494), // Set the background color for the text field
                  filled: true,
                ),
                style: TextStyle(color: Color(0xFFFBF3F3)),
                onChanged: (value) {
                  _newTodo.details = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter details';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Goal',
                  labelStyle: TextStyle(color: Color(0xFFFBF3F3)),
                  fillColor: Color(0xFFD09494), // Set the background color for the text field
                  filled: true,
                ),
                style: TextStyle(color: Color(0xFFFBF3F3)),
                onChanged: (value) {
                  _newTodo.goal = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a goal';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Emotion',
                  labelStyle: TextStyle(color: Color(0xFFFBF3F3)),
                  fillColor: Color(0xFFD09494), // Set the background color for the text field
                  filled: true,
                ),
                style: TextStyle(color: Color(0xFFFBF3F3)),
                onChanged: (value) {
                  _newTodo.emotion = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an emotion';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveTodo,
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFC17171), // Set the background color for the button
                ),
                child: Text('Submit', 
                 style: TextStyle(color: Color(0xFFFBF3F3)),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
