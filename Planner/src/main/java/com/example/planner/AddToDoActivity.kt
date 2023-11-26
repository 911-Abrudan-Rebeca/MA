package com.example.planner

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.lifecycle.ViewModelProvider

class AddToDoActivity : ComponentActivity() {
    private lateinit var toDoViewModel: ToDoViewModel

    var idGenerator = ToDoIdGenerator()

    //creating a new service with an auto incremented id

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.add_page)
        toDoViewModel = ViewModelProvider(this).get(ToDoViewModel::class.java)


        val btnSubmit = findViewById<Button>(R.id.btnSubmit)

        btnSubmit.setOnClickListener {
            // Retrieve data from EditText fields
            val title = findViewById<EditText>(R.id.etTitle).text.toString()
            val time = findViewById<EditText>(R.id.etTime).text.toString()
            val details = findViewById<EditText>(R.id.etDetails).text.toString()
            val goal = findViewById<EditText>(R.id.etGoal).text.toString()
            val emotion = findViewById<EditText>(R.id.etEmotion).text.toString()

            if (title.isEmpty() || time.isEmpty() || details.isEmpty() || goal.isEmpty() || emotion.isEmpty()) {
                // Show an error message with a Toast
                Toast.makeText(this, "Please fill in all fields", Toast.LENGTH_SHORT).show()
            }
            else {

                // Create a new ToDos object
                val newToDo = ToDo(
                    idGenerator.generateUniqueId(),
                    title,
                    time,
                    details,
                    goal,
                    emotion
                );

                Log.d("AddToDoActivity", "New ToDo: $newToDo")


                // Add the new ToDos to the ViewModel
                //toDoViewModel.addService(newToDo)

                // Optionally, clear the EditText fields after submission
                //clearEditTextFields()

                // Notify observers of the data change
//                toDoViewModel.getToDo().value?.let { updatedToDos ->
//                    // Do something with updatedToDos if needed
//                    Log.d("AddToDoActivity", "Updated ToDo List: $updatedToDos")
//                }
                // Optionally, clear the EditText fields after submission
                clearEditTextFields()

                val intent = Intent()
                intent.putExtra("newToDo", newToDo)
                setResult(Activity.RESULT_OK, intent)
                finish()
            }
        }
    }

    private fun clearEditTextFields() {
        val editTextIds = arrayOf(R.id.etTitle, R.id.etTime, R.id.etDetails, R.id.etGoal, R.id.etEmotion)
        for (editTextId in editTextIds) {
            findViewById<EditText>(editTextId).text.clear()
        }
    }

}