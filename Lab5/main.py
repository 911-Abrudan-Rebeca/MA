import asyncio
import json
import threading

import websockets as websockets

from flask_sqlalchemy import SQLAlchemy
from flask import Flask, jsonify, request, render_template

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///todos.db'  # SQLite database file
db = SQLAlchemy(app)
connected_clients = set()


class Todo(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    time = db.Column(db.String(255), nullable=False)
    details = db.Column(db.Text, nullable=False)
    goal = db.Column(db.Text, nullable=False)
    emotion = db.Column(db.String(255), nullable=False)

    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'time': self.time,
            'details': self.details,
            'goal': self.goal,
            'emotion': self.emotion,
        }


@app.route('/')
def home():
    return render_template('index.html', message='Hello')


@app.route('/add_todo', methods=['POST'])
def add_todo():
    # Print the current thread ID
    print(f"Handling request in thread {threading.current_thread().ident}")

    data = request.get_json()
    new_todo = Todo(
        title=data['title'],
        time=data['time'],
        details=data['details'],
        goal=data['goal'],
        emotion=data['emotion']
    )

    db.session.add(new_todo)
    db.session.commit()
    print("ToDo added successfully")
    return jsonify({'message': 'ToDo added successfully'})


@app.route('/update', methods=['PUT'])
def update_todo():
    # Print the current thread ID
    print(f"Handling request in thread {threading.current_thread().ident}")

    data = request.get_json()
    todo_id = data.get('id')
    todo = Todo.query.get(todo_id)

    if todo:
        todo.title = data['title']
        todo.time = data['time']
        todo.details = data['details']
        todo.goal = data['goal']
        todo.emotion = data['emotion']

        db.session.commit()
        print("ToDo added successfully")
        return jsonify({'message': 'ToDo updated successfully'})
    else:
        return jsonify({'message': 'ToDo not found'}), 404


@app.route('/todos', methods=['GET'])
def get_all_todos():
    # Print the current thread ID
    print(f"Handling request in thread {threading.current_thread().ident}")

    todos = Todo.query.all()
    todos_list = [todo.to_dict() for todo in todos]
    return jsonify({'todos': todos_list})


@app.route('/delete/<int:todo_id>', methods=['DELETE'])
def delete_todo(todo_id):
    todo = Todo.query.get(todo_id)

    # Print the current thread ID
    print(f"Handling request in thread {threading.current_thread().ident}")

    if todo:
        db.session.delete(todo)
        db.session.commit()
        print("ToDo deleted successfully")
        return jsonify({'message': 'ToDo deleted successfully'})
    else:
        return jsonify({'message': 'ToDo not found'}), 404


if __name__ == '__main__':
    with app.app_context():
        db.create_all()  # Create tables before running the app

    app.run(host='0.0.0.0', port=5000, debug=True, threaded=True)
