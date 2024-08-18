//
//  HomeView.swift
//  ZenCheck
//
//  Created by Karthik Gurram on 2024-08-17.
//
import SwiftUI

struct HomeView: View {
    @State private var newTaskTitle: String = ""
    @ObservedObject var taskViewModel: TaskViewModel
    @State private var currentDate = Date()
    @Namespace private var animationNamespace // Namespace for matched geometry effect

    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading) {
                    Text(currentDateFormatted)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(cyan)
                    
                    HStack {
                        Text("\(taskViewModel.tasksFor(date: currentDate).filter { $0.isCompleted }.count) Completed")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        Text("•")
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                taskViewModel.clearTasks(for: currentDate)
                            }
                        }) {
                            Text("Clear")
                                .foregroundColor(cyan)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 5)
                }
                .padding(.horizontal)
                
                // Custom TextField with dynamic underline
                VStack {
                    ZStack(alignment: .leading) {
                        Text(newTaskTitle) // This Text will be used to measure the text width
                            .foregroundColor(.clear)
                            .padding(.vertical, 10)
                            .background(GeometryReader { geometry in
                                Color.clear.preference(key: WidthPreferenceKey.self, value: geometry.size.width)
                            })
                            .onPreferenceChange(WidthPreferenceKey.self) { width in
                                self.underlineWidth = width
                            }
                        
                        TextField("Add new task", text: $newTaskTitle)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .background(Color.clear)
                    }
                    .overlay(
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(cyan)
                            .frame(width: underlineWidth, alignment: .leading)
                            .animation(.easeInOut(duration: 0.3), value: underlineWidth)
                            .offset(y: 10)
                        , alignment: .leading
                    )
                    .padding(.horizontal)
                }
                
                Button(action: {
                    if !newTaskTitle.isEmpty {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.3)) {
                            taskViewModel.addTask(title: newTaskTitle, for: currentDate)
                            newTaskTitle = ""
                            underlineWidth = 0 // Reset the underline width when a new task is added
                        }
                    }
                }) {
                    Text("Add Task")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(cyan)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                List {
                    ForEach(taskViewModel.tasksFor(date: currentDate)) { task in
                        HStack {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? cyan : .gray)
                                .scaleEffect(task.isCompleted ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.5).repeatCount(1, autoreverses: true), value: task.isCompleted)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                        taskViewModel.toggleTaskCompletion(task: task, for: currentDate)
                                    }
                                }
                            
                            TextField("", text: Binding(
                                get: { task.title },
                                set: { newValue in
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        taskViewModel.editTask(task: task, newTitle: newValue, for: currentDate)
                                    }
                                }))
                            .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    taskViewModel.deleteTask(task: task, for: currentDate)
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding(.vertical, 10)
                        .listRowSeparator(.hidden)
                        .listRowBackground(darkGrey)
                        .transition(.asymmetric(insertion: .scale(scale: 0.8).combined(with: .opacity), removal: .scale(scale: 0.8).combined(with: .opacity)))
                        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.3), value: task.id)
                    }
                    .onDelete(perform: { indexSet in
                        withAnimation(.easeInOut(duration: 0.4)) {
                            for index in indexSet {
                                let task = taskViewModel.tasksFor(date: currentDate)[index]
                                taskViewModel.deleteTask(task: task, for: currentDate)
                            }
                        }
                    })
                }
                .listStyle(PlainListStyle())
            }
            .background(darkGrey)
            .navigationBarHidden(true)
            .onAppear {
                currentDate = Date()
            }
        }
    }
    
    // MARK: - Private properties and methods
    
    @State private var underlineWidth: CGFloat = 0
    
    private var currentDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: currentDate)
    }
    
    private var darkGrey: Color {
        return Color(.systemGray6)
    }
    
    private var cyan: Color {
        return Color.cyan
    }
}

struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
