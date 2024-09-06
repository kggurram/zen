import SwiftUI

struct HomeView: View {
    @State private var newTaskTitle: String = ""
    @ObservedObject var taskViewModel: TaskViewModel
    @State private var currentDate = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading) {
                    Text(currentDateFormatted)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                        .foregroundColor(cyan)
                    
                    HStack {
                        Text("\(taskViewModel.tasksFor(date: currentDate).filter { $0.isCompleted }.count) Completed")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        Text("•")
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            withAnimation {
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
                .padding(.top, 10)
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
                        
                        TextField("Add new Zen", text: $newTaskTitle, onCommit: {
                            addNewTask()
                            newTaskTitle = ""
                        })
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .frame(height: 68)
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
                
//                Button(action: {
//                    if !newTaskTitle.isEmpty {
//                        withAnimation {
//                            taskViewModel.addTask(title: newTaskTitle, for: currentDate)
//                            newTaskTitle = ""
//                            underlineWidth = 0 // Reset the underline width when a new task is added
//                        }
//                    }
//                }) {
//                    Text("Add Zen")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(cyan)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                        .padding(.horizontal)
//                }
                
                List {
                    ForEach(taskViewModel.tasksFor(date: currentDate)) { task in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? cyan : .gray)
                                .font(.system(size: 20))
                                .onTapGesture {
                                    withAnimation {
                                        taskViewModel.toggleTaskCompletion(task: task, for: currentDate)
                                    }
                                }
                            
                            VStack(alignment: .leading, spacing: 0) {
                                // The TextField for editing the task
                                TextField("", text: Binding(
                                    get: { task.title },
                                    set: { newValue in
                                        withAnimation {
                                            taskViewModel.editTask(task: task, newTitle: newValue, for: currentDate)
                                        }
                                    }))
                                .foregroundColor(.white)
                                .lineLimit(nil)  // Allow text to wrap to multiple lines
                                .fixedSize(horizontal: false, vertical: true)  // Ensure the text wraps correctly
                                
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation {
                                    taskViewModel.deleteTask(task: task, for: currentDate)
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding(.vertical, 0)  // Reduced vertical padding
                        .listRowSeparator(.hidden)
                        .listRowBackground(darkGrey)
                    }
                    .onDelete(perform: { indexSet in
                        withAnimation {
                            for index in indexSet {
                                let task = taskViewModel.tasksFor(date: currentDate)[index]
                                taskViewModel.deleteTask(task: task, for: currentDate)
                            }
                        }
                    })
                }


                .listStyle(PlainListStyle())

            }
            .padding(.horizontal, 10) // Use padding, but not excessively
            .frame(maxWidth: .infinity) // Ensure the VStack uses the full width
            .background(darkGrey)
            .edgesIgnoringSafeArea(.horizontal)
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
    
    private func addNewTask() {
        if !newTaskTitle.isEmpty {
            withAnimation {
                taskViewModel.addTask(title: newTaskTitle, for: currentDate)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        newTaskTitle = ""  // Reset the text field after adding the task
                        underlineWidth = 0  // Reset the underline width when a new task is added
                    
                }
            }
        }
    }
}

struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
