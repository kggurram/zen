//
//  SummaryView.swift
//  ZenCheck
//
//  Created by Karthik Gurram on 2024-08-18.
//

import SwiftUI

struct SummaryView: View {
    @ObservedObject var taskViewModel: TaskViewModel
    @State private var summaryText: String = ""
    
    var body: some View {
        VStack {
            Text("Task Summary")
                .font(.largeTitle)
                .padding()
            
            Text(summaryText)
                .padding()
            
            Spacer()
        }
        .onAppear {
            summaryText = fetchTaskSummary()
        }
    }
    
    // Define the fetchTaskSummary function
    func fetchTaskSummary() -> String {
        // Here you would implement your logic to generate a summary of the tasks.
        // This is a placeholder implementation:
        let completedTasks = taskViewModel.tasksByDate.flatMap { $0.value }.filter { $0.isCompleted }
        let totalTasks = taskViewModel.tasksByDate.flatMap { $0.value }
        
        return "You have completed \(completedTasks.count) out of \(totalTasks.count) tasks."
    }
}
