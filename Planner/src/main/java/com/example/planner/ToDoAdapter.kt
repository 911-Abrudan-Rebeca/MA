package com.example.planner

import android.graphics.Paint.STRIKE_THRU_TEXT_FLAG
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView


class ToDoAdapter (
    private var todos: MutableList<ToDo>,
    private var itemClickListener: OnItemClickListener? = null
) : RecyclerView.Adapter<ToDoAdapter.ToDoViewHolder>() {

    class ToDoViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView){
        val title: TextView = itemView.findViewById(R.id.tvName)
        val time: TextView = itemView.findViewById(R.id.tvTime)
        val details: TextView = itemView.findViewById(R.id.tvDetails)
        val goal: TextView = itemView.findViewById(R.id.tvGoal)
//        var checked: TextView = itemView.findViewById(R.id.cbDone)
    }


    interface OnItemClickListener {
        fun onItemClick(service: ToDo)
    }

    fun setOnItemClickListener(listener: OnItemClickListener) {
        itemClickListener = listener
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ToDoViewHolder {
        return ToDoViewHolder(
            LayoutInflater.from(parent.context).inflate(
                R.layout.item_todo,
                parent,
                false
            )
        )
    }

    override fun getItemCount(): Int {
        return todos.size
    }

    fun addService(service: ToDo) {
        todos.add(service)
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
            holder.goal.text = curToDo.goal
            holder.details.text = curToDo.details
//            cbDone.isChecked = curToDo.isChecked
//            toggleStrikeThrough(title, curToDo.isChecked)
//            cbDone.setOn
        }
        holder.itemView.setOnClickListener {
            itemClickListener?.onItemClick(curToDo)
        }
    }

    fun setServices(newToDo: MutableList<ToDo>) {
        todos = newToDo
        notifyDataSetChanged() // Notify the adapter of data change
    }
}