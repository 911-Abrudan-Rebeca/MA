import 'package:flutter/material.dart';
import 'repository.dart';
import 'todo.dart';

class TodoDetailPage extends StatefulWidget {
  final Todo todo;
  final Function(Todo) onUpdate;
  final void Function(int) onDelete;

  TodoDetailPage({
    required this.todo,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  _TodoDetailPageState createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late Todo _editedTodo;

  @override
  void initState() {
    super.initState();
    _editedTodo = widget.todo;
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final updatedTodo = Todo(
        id: _editedTodo.id,
        title: _editedTodo.title,
        time: _editedTodo.time,
        details: _editedTodo.details,
        goal: _editedTodo.goal,
        emotion: _editedTodo.emotion,
      );

      print('Updating Todo: $updatedTodo');

      final result = await TodoRepository().updateTodo(updatedTodo);

      if (result > 0) {
        print('Todo updated successfully');
      } else {
        print('Failed to update todo');
      }

      Navigator.pop(context);
    }
  }

  void _deleteTodo() async {
    try {
    await TodoRepository().deleteTodo(_editedTodo.id);
    
    // If the deletion was successful, trigger a refresh
    Navigator.pop(context);
    widget.onDelete(_editedTodo.id);
  } catch (error) {
    // Handle the case where deletion failed
    print('Failed to delete todo: $error');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo Details'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveChanges();
              widget.onUpdate(_editedTodo);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteTodo();
              widget.onDelete(_editedTodo.id);
            },
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFFBF3F3), // Set the background color for the entire page
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: <Widget>[
              TextFormField(
                initialValue: _editedTodo.title,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Color(0xFFFBF3F3)),
                  fillColor: Color(0xFFD09494), // Set the background color for the text field
                  filled: true,
                ),
                style: TextStyle(color: Color(0xFFFBF3F3)),
                onChanged: (value) {
                  setState(() {
                    _editedTodo = _editedTodo.copyWith(title: value);
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
                initialValue: _editedTodo.time,
                decoration: InputDecoration(
                  labelText: 'Time',
                  labelStyle: TextStyle(color: Color(0xFFFBF3F3)),
                  fillColor: Color(0xFFD09494), // Set the background color for the text field
                  filled: true,
                ),
                style: TextStyle(color: Color(0xFFFBF3F3)),
                onChanged: (value) {
                  _editedTodo = _editedTodo.copyWith(time: value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a time';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _editedTodo.details,
                decoration: InputDecoration(
                  labelText: 'Details',
                  labelStyle: TextStyle(color: Color(0xFFFBF3F3)),
                  fillColor: Color(0xFFD09494), // Set the background color for the text field
                  filled: true,
                ),
                style: TextStyle(color: Color(0xFFFBF3F3)),
                onChanged: (value) {
                  _editedTodo = _editedTodo.copyWith(details: value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter details';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _editedTodo.goal,
                decoration: InputDecoration(
                  labelText: 'Goal',
                  labelStyle: TextStyle(color: Color(0xFFFBF3F3)),
                  fillColor: Color(0xFFD09494), // Set the background color for the text field
                  filled: true,
                ),
                style: TextStyle(color: Color(0xFFFBF3F3)),
                onChanged: (value) {
                  _editedTodo = _editedTodo.copyWith(goal: value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a goal';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _editedTodo.emotion,
                decoration: InputDecoration(
                  labelText: 'Emotion',
                  labelStyle: TextStyle(color: Color(0xFFFBF3F3)),
                  fillColor: Color(0xFFD09494), // Set the background color for the text field
                  filled: true,
                ),
                style: TextStyle(color: Color(0xFFFBF3F3)),
                onChanged: (value) {
                  _editedTodo = _editedTodo.copyWith(emotion: value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an emotion';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
