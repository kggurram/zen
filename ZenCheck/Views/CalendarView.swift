//
//  CalendarView.swift
//  ZenCheck
//
//  Created by Karthik Gurram on 2024-08-17.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var taskViewModel: TaskViewModel
    @State private var currentDate = Date()
    
    var body: some View {
        VStack {
            Text("Calendar")
                .font(.largeTitle)
                .padding()
            
            CalendarGridView(currentDate: $currentDate, taskViewModel: taskViewModel)
            
            Spacer()
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CalendarGridView: View {
    @Binding var currentDate: Date
    @ObservedObject var taskViewModel: TaskViewModel
    
    var body: some View {
        let daysInMonth = getDaysInMonth(for: currentDate)
        let firstDayOfMonth = getFirstDayOfMonth(for: currentDate)
        
        let days = (1...daysInMonth).map { day -> CalendarDay in
            let date = getDate(for: day, currentDate: currentDate)
            let tasks = taskViewModel.tasksFor(date: date)
            let isCompleted = tasks.allSatisfy { $0.isCompleted }
            return CalendarDay(date: date, dayNumber: day, hasTasks: !tasks.isEmpty, isCompleted: isCompleted)
        }
        
        let leadingEmptyCells = firstDayOfMonth - 1
        
        return VStack {
            HStack {
                Text("<")
                    .onTapGesture {
                        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                    }
                Spacer()
                Text(currentDate, style: .date)
                Spacer()
                Text(">")
                    .onTapGesture {
                        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                    }
            }
            .padding()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(0..<leadingEmptyCells, id: \.self) { _ in
                    Text("")
                }
                
                ForEach(days) { day in
                    VStack {
                        Text("\(day.dayNumber)")
                            .foregroundColor(day.hasTasks ? (day.isCompleted ? .green : .blue) : .gray)
                        if day.hasTasks {
                            Circle()
                                .fill(day.isCompleted ? Color.green : Color.blue)
                                .frame(width: 8, height: 8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
    }
    
    func getDaysInMonth(for date: Date) -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    func getFirstDayOfMonth(for date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        let firstDay = calendar.date(from: components)!
        return calendar.component(.weekday, from: firstDay)
    }
    
    func getDate(for day: Int, currentDate: Date) -> Date {
        var components = Calendar.current.dateComponents([.year, .month], from: currentDate)
        components.day = day
        return Calendar.current.date(from: components)!
    }
}

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let dayNumber: Int
    let hasTasks: Bool
    let isCompleted: Bool
}
