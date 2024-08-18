//
//  HomeView.swift
//  ZenCheck
//
//  Created by Karthik Gurram on 2024-08-17.
//
import SwiftUI

struct HomeView: View {
    @State private var newTaskTitle: String = ""
    @ObservedObject var taskViewModel = TaskViewModel()
    
    var body: some View {
        VStack {
            TextField("Add new task", text: $newTaskTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                if !newTaskTitle.isEmpty {
                    taskViewModel.addTask(title: newTaskTitle)
                    newTaskTitle = ""
                }
            }) {
                Text("Add Task")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            
            List {
                ForEach(taskViewModel.tasks) { task in
                    HStack {
                        Text(task.title)
                        Spacer()
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isCompleted ? .green : .gray)
                            .onTapGesture {
                                taskViewModel.toggleTaskCompletion(task: task)
                            }
                    }
                }
            }
        }
        .navigationTitle("Today's Tasks")
    }
}
