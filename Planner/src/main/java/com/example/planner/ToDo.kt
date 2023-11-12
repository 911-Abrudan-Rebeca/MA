package com.example.planner

import android.os.Parcel
import android.os.Parcelable

data class ToDo (
    val id: Long, //unique id for each activity
    val title: String,
    val time: String,
    val goal: String,
    val details: String,
    val emotion: String,
    //val isChecked: Boolean = false
) : Parcelable {
    constructor(parcel: Parcel) : this (
        parcel.readLong(),
        parcel.readString() ?: "",
        parcel.readString() ?: "",
        parcel.readString() ?: "",
        parcel.readString() ?: "",
        parcel.readString() ?: "",
        //parcel.readBoolean()
    )

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeLong(id)
        parcel.writeString(title)
        parcel.writeString(time)
        parcel.writeString(goal)
        parcel.writeString(details)
        parcel.writeString(emotion)
       // parcel.writeBoolean(isChecked)
    }

    override fun describeContents(): Int {
        return 0
    }

    companion object CREATOR : Parcelable.Creator<ToDo> {
        override fun createFromParcel(parcel: Parcel): ToDo {
            return ToDo(parcel)
        }

        override fun newArray(size: Int): Array<ToDo?> {
            return arrayOfNulls(size)
        }
    }
}