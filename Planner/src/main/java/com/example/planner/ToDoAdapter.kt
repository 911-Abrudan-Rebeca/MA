package com.example.planner

import android.graphics.Paint.STRIKE_THRU_TEXT_FLAG
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.CheckBox
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView


class ToDoAdapter (
    private var todos: MutableList<ToDo>,
    private var itemClickListener: OnItemClickListener? = null,
//    private var completedListener: OnCompletedListener? = null //flower growth
) : RecyclerView.Adapter<ToDoAdapter.ToDoViewHolder>() {

    class ToDoViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView){
        val title: TextView = itemView.findViewById(R.id.tvName)
        val time: TextView = itemView.findViewById(R.id.tvTime)
        val emotion: TextView = itemView.findViewById(R.id.tvEmotion)
        val goal: TextView = itemView.findViewById(R.id.tvGoal)
        var checked: CheckBox = itemView.findViewById(R.id.cbDone)
    }


//    interface OnCompletedListener {
//        fun onCompletedChanged(completedCount: Int, totalCount: Int)
//    }
//
//    private var completedCount = 0
//
//    fun setOnCompletedListener(listener: OnCompletedListener) {
//        completedListener = listener
//    }

    interface OnItemClickListener {
        fun onItemClick(todo: ToDo)
    }

    fun setOnItemClickListener(listener: OnItemClickListener) {
        itemClickListener = listener
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ToDoViewHolder {
        return ToDoViewHolder(
            LayoutInflater.from(parent.context).inflate(
                R.layout.firstpage,
                parent,
                false
            )
        )
    }

    override fun getItemCount(): Int {
        return todos.size
    }

    fun addToDo(todo: ToDo) {
        todos.add(todo)
        notifyItemInserted(todos.size -1)
    }


    private fun toggleStrikeThrough(tvToDoTitle: TextView, isChecked: Boolean) {
        if(isChecked) {
            tvToDoTitle.paintFlags = tvToDoTitle.paintFlags or STRIKE_THRU_TEXT_FLAG
        } else {
            tvToDoTitle.paintFlags = tvToDoTitle.paintFlags and STRIKE_THRU_TEXT_FLAG.inv()
        }
    }

    override fun onBindViewHolder(holder: ToDoViewHolder, position: Int) {
        val curToDo = todos[position]
        holder.itemView.apply {
            holder.title.text = curToDo.title
            holder.time.text = curToDo.time
            holder.emotion.text = curToDo.emotion
            holder.goal.text = curToDo.goal
            holder.checked.isChecked = curToDo.isChecked

            toggleStrikeThrough(holder.title, curToDo.isChecked)
            holder.checked.setOnCheckedChangeListener { _, isChecked ->
                toggleStrikeThrough(holder.title, isChecked)
                curToDo.isChecked = !curToDo.isChecked


//                // Move checked item to the bottom
//                if (isChecked) {
//                    todos.removeAt(position)
//                    todos.add(curToDo)
//                    notifyItemMoved(position, todos.size - 1)
//                }else {
//                    // If unchecked, move to the top (index 0)
//                    todos.removeAt(position)
//                    todos.add(0, curToDo)
//                    notifyItemMoved(position, 0)
//                }

//                // Update completed count
//                if (isChecked) {
//                    completedCount++
//                } else {
//                    completedCount--
//                }
//
//                completedListener?.onCompletedChanged(completedCount, itemCount)

            }
        }
        holder.itemView.setOnClickListener {
            itemClickListener?.onItemClick(curToDo)
        }
    }

    private fun getCheckedCount(): Int {
        return todos.count { it.isChecked }
    }

    fun setTodos(newToDo: MutableList<ToDo>) {
        todos = newToDo
        notifyDataSetChanged() // Notify the adapter of data change
    }
}