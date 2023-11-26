package com.example.planner

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView

class MainActivity : ComponentActivity() {
    private lateinit var todoViewModel: ToDoViewModel
    private lateinit var todoAdapter: ToDoAdapter



    private val addToDoLauncher =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result: ActivityResult ->
            if (result.resultCode == Activity.RESULT_OK) {
                val data: Intent? = result.data
                val newToDo = data?.getParcelableExtra<ToDo>("newToDo")
                if (newToDo != null) {
                    todoViewModel.addToDo(newToDo)
                }
            }
        }

    private val editToDoLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result: ActivityResult ->
        if (result.data != null) {
            val data = result.data

            // Check if the result contains a Parcelable (Service)
            val updatedToDo = data?.getParcelableExtra<ToDo>("updatedToDo")
            if (updatedToDo != null) {
                // Handle the Service
                todoViewModel.updateToDo(updatedToDo)
            } else {
                // Check if the result contains a number (ID)
                val deletedToDoId = data?.getLongExtra("deletedToDoId", -1)
                if (deletedToDoId?.toInt() != -1) {
                    // Handle the number (ID)
                    if (deletedToDoId != null) {
                        todoViewModel.deleteToDo(deletedToDoId)
                    }

                    // Update the LiveData with the modified list
                }
            }
        }
    }


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Initialize ViewModel
        todoViewModel = ViewModelProvider(this).get(ToDoViewModel::class.java)

        //btn
        val btnAdd = findViewById<Button>(R.id.btnAddToDo)

        // Simulate data loading or add your actual data
        val initialToDoList = mutableListOf(
            ToDo(1,"gym", "1-2pm", "x", "body", "happy"),
            ToDo(2,"study", "2-5pm", "x", "career", "stress relief"),
            ToDo(3,"reading", "5-6pm", "x","growth", "relaxed")
        )

        // Initialize RecyclerView and Adapter
        val rvToDo = findViewById<RecyclerView>(R.id.rvToDoItems)
        todoAdapter = ToDoAdapter(initialToDoList)

        rvToDo.adapter = todoAdapter
        rvToDo.layoutManager = LinearLayoutManager(this)

        // Observe the LiveData from the ViewModel
        todoViewModel.getToDo().observe(this, Observer { newToDos ->
            todoAdapter.setTodos(newToDos as MutableList<ToDo>)
        })

        todoViewModel.updateToDos(initialToDoList)

        btnAdd.setOnClickListener {
            // Handle the button click, e.g., navigate to another todos
            addToDoLauncher.launch(Intent(this, AddToDoActivity::class.java))
        }


        todoAdapter.setOnItemClickListener(object : ToDoAdapter.OnItemClickListener {
            override fun onItemClick(service: ToDo) {
                // Create an intent to open EditToDoActivity
                val intent = Intent(this@MainActivity, EditToDoActivity::class.java)
                intent.putExtra("selectedToDo", service)
                editToDoLauncher.launch(intent)
            }
        })
    }
}