//
//  TaskViewModel.swift
//  ZenCheck
//
//  Created by Karthik Gurram on 2024-08-17.
//

import SwiftUI
import Combine

class TaskViewModel: ObservableObject {
    @Published var tasksByDate: [String: [Task]] = [:]
    
    private let tasksKey = "tasksByDate"
    
    func addTask(title: String, for date: Date) {
        let newTask = Task(title: title)
        let dateString = dateFormatter.string(from: date)
        
        if tasksByDate[dateString] != nil {
            tasksByDate[dateString]?.append(newTask)
        } else {
            tasksByDate[dateString] = [newTask]
        }
        saveTasks()
    }
    
    func toggleTaskCompletion(task: Task, for date: Date) {
        let dateString = dateFormatter.string(from: date)
        
        if let index = tasksByDate[dateString]?.firstIndex(where: { $0.id == task.id }) {
            tasksByDate[dateString]?[index].isCompleted.toggle()
            saveTasks()
        }
    }
    
    func editTask(task: Task, newTitle: String, for date: Date) {
        let dateString = dateFormatter.string(from: date)
        
        if let index = tasksByDate[dateString]?.firstIndex(where: { $0.id == task.id }) {
            tasksByDate[dateString]?[index].title = newTitle
            saveTasks()
        }
    }
    
    func deleteTask(task: Task, for date: Date) {
        let dateString = dateFormatter.string(from: date)
        
        tasksByDate[dateString]?.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func tasksFor(date: Date) -> [Task] {
        let dateString = dateFormatter.string(from: date)
        return tasksByDate[dateString] ?? []
    }
    
    func clearTasks(for date: Date) {
        let dateString = dateFormatter.string(from: date)
        tasksByDate[dateString] = []
        saveTasks()
    }
    
    private func saveTasks() {
        do {
            let data = try JSONEncoder().encode(tasksByDate)
            UserDefaults.standard.set(data, forKey: tasksKey)
        } catch {
            print("Failed to save tasks: \(error)")
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey) {
            do {
                tasksByDate = try JSONDecoder().decode([String: [Task]].self, from: data)
            } catch {
                print("Failed to load tasks: \(error)")
            }
        }
    }
    
    init() {
        loadTasks()
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}

