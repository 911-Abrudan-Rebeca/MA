package com.example.planner
import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel

class ToDoViewModel : ViewModel(){
    private val todoList: MutableLiveData<MutableList<ToDo>> = MutableLiveData(mutableListOf()) // Initialize with an empty list

    // Public method to access the LiveData
    fun getToDo(): LiveData<MutableList<ToDo>> {
        return todoList
    }

    fun addToDo(todo: ToDo) {
        Log.d("ToDoViewModel", "FIRST todo list: ${todoList.value}")
        val currentToDos = todoList.value ?: mutableListOf()
        currentToDos.add(todo)
        todoList.postValue(currentToDos)
        Log.d("ToDoViewModel", "Updated todo list: ${currentToDos}")
    }


    // Public method to update the service list
    fun updateToDos(newToDos: MutableList<ToDo>) {
        todoList.value = newToDos
    }

    fun updateToDo(updatedToDo: ToDo) {
        // Get the current list of services
        val currentToDos = todoList.value ?: mutableListOf()

        Log.d("EDIT", "todos: $currentToDos")
        // Find the position of the service to update (you may need a unique identifier in your Service class)
        val todoToUpdate = currentToDos.indexOfFirst { it.id == updatedToDo.id }
        Log.d("EDIT", "New ToDo: $todoToUpdate")

        if (todoToUpdate != -1) {
            Log.d("EDIT", "TEST: $todoToUpdate")

            // Update the service in the list
            currentToDos[todoToUpdate] = updatedToDo

            // Update the LiveData to notify observers of the change
            todoList.value = currentToDos
        }
    }

    fun deleteToDo(etId: Long) {
        val currentToDos = todoList.value ?: mutableListOf()
        Log.d("test","test,${todoList.value}")

        // Find the position of the service to update (you may need a unique identifier in your Service class)
        val serviceToDeleteIndex = currentToDos.indexOfFirst { it.id == etId }
        Log.d("DELETE", "index: $etId")
        Log.d("ALL", "index: $currentToDos")

        if (serviceToDeleteIndex != -1) {
            // Remove the service from the list
            currentToDos.removeAt(serviceToDeleteIndex)

            // Update the LiveData with the modified list
            todoList.postValue(currentToDos)
            Log.d("DELETE", "all: $todoList")
        }
    }
}