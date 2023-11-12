package com.example.planner

import android.app.AlertDialog
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResult
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.lifecycle.ViewModelProvider

class EditToDoActivity : ComponentActivity() {

    private lateinit var todoViewModel: ToDoViewModel
    private lateinit var editToDoLauncher: ActivityResultLauncher<Intent>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.update_page)

        val requestCodeDelete = 123
        val requestCodeEdit = 456

        todoViewModel = ViewModelProvider(this).get(ToDoViewModel::class.java)

        // Initialize views
        val etId = findViewById<EditText>(R.id.etId)
        val etTitle = findViewById<EditText>(R.id.etTitle)
        val etTime = findViewById<EditText>(R.id.etTime)
        val etDetails = findViewById<EditText>(R.id.etDetails)
        val etGoal = findViewById<EditText>(R.id.etGoal)
        val etEmotion = findViewById<EditText>(R.id.etEmotion)

        val btnSubmitChanges = findViewById<Button>(R.id.btnSave)

        // Receive selected item's details from the previous activity
        val selectedToDo = intent.getParcelableExtra<ToDo>("selectedToDo")

        // Populate the EditText views with the details
        etId.setText(selectedToDo?.id.toString())
        etTitle.setText(selectedToDo?.title)
        etTime.setText(selectedToDo?.time)
        etDetails.setText(selectedToDo?.details)
        etGoal.setText(selectedToDo?.goal)
        etEmotion.setText(selectedToDo?.emotion)

        // Initialize the Activity Result Launcher for updating the item
        editToDoLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result: ActivityResult ->
            if (result.resultCode == RESULT_OK) {
                // Handle the result if needed
                val data: Intent? = result.data
                // Extract any data you need from the result
            }
        }

        // Handle the "Submit Changes" button click
        btnSubmitChanges.setOnClickListener {
            // Create a new Service object with the updated details
            val updatedService = ToDo(
                etId.text.toString().toLong(),
                etTitle.text.toString(),
                etTime.text.toString(),
                etDetails.text.toString(),
                etGoal.text.toString(),
                etEmotion.text.toString()
            )


            // Pass the updated Service object to the previous activity
            val intent = Intent()
            intent.putExtra("updatedService", updatedService)
            setResult(RESULT_OK, intent)
            finish()
        }

        val btnDelete = findViewById<Button>(R.id.btnDelete)

        btnDelete.setOnClickListener {
            // Show a confirmation dialog
            val dialogBuilder = AlertDialog.Builder(this)
            dialogBuilder.setMessage("Are you sure you want to delete this todo?")
                .setCancelable(false)
                .setPositiveButton("Yes") { _, _ ->
                    // Delete the todos from your data source (e.g., ViewModel)
                    val intent = Intent()
                    intent.putExtra("deletedToDoId", etId.text.toString().toLong())
                    setResult(RESULT_OK, intent)
                    finish()
                    // Navigate back to the previous screen (e.g., MainActivity)

                }
                .setNegativeButton("No") { dialog, _ ->
                    dialog.dismiss()
                }

            val alertDialog = dialogBuilder.create()
            alertDialog.show()
        }


    }
}