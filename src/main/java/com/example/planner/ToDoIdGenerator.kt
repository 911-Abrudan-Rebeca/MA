package com.example.planner

class ToDoIdGenerator {
    private var currentId: Long = 3

    fun generateUniqueId(): Long {
        return ++currentId
    }
}