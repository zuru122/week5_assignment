// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;


contract Todo{
    // Things you need why building a todo list
    // 1. A way to store the todo list
    // 2. A way to add items to the todo list
    // 3. A way to remove items from the todo list
    // 4. A way to mark items as completed or not completed

    // Edge cases  
    // 1. What if the user tries to add an empty item to the todo list?
    // 2. What if the user tries to remove an item that doesn't exist in the todo list?
    // 3. What if the user tries to mark an item as completed that doesn't exist in the todo list?
    // 4. What if the user tries to mark an item as not completed that doesn't exist in the todo list?

    struct Task{
        uint8 id;
        string title;
        bool isCompleted; 
        uint256 timeCompleted;
    }

    Task[] public tasks;
    uint8 todo_id;

    function createTask(string memory _title) external{
        uint8 id = todo_id++;
        tasks.push(Task(id, _title, false, 0));
        todo_id = id;

    }

    function getAllTasks()external view returns(Task[] memory){
        return tasks;
    }

    function markTaskCompleted(uint8 _id) external{
        for(uint8 i = 0; i < tasks.length; i++){
            if(tasks[i].id == _id){
                tasks[i].isCompleted = true;
                tasks[i].timeCompleted = block.timestamp;
            }
        }
    }

    function deleteTask(uint8 _id) external{
        for(uint8 i = 0; i < tasks.length; i++){
            if(tasks[i].id == _id){
                tasks[i] = tasks[tasks.length - 1];
                tasks.pop();
                break;
            }
        }
    }

    function updateTask(uint8 _id, string memory _title) external{
        for(uint8 i = 0; i < tasks.length; i++){
            if(tasks[i].id == _id){
                tasks[i].title = _title;
            }
        }
    }

    function undoTask(uint8 _id) external{
        for(uint8 i = 0; i < tasks.length; i++){
            if(tasks[i].id == _id){
                tasks[i].isCompleted = false;
                tasks[i].timeCompleted = 0;
            }
        }
    }

}