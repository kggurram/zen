import SwiftUI

struct CalendarView: View {
    @ObservedObject var taskViewModel: TaskViewModel
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    
    // Define colors here
    private let darkGrey = Color(.systemGray6)
    private let green = Color.green
    private let orange = Color.orange
    private let cyan = Color.cyan
    
    var body: some View {
        VStack {
            HStack {
                Text("Zen Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                    .foregroundColor(cyan)
                Spacer() // Pushes the title to the left
            }
            .padding(.top, 10)
            .padding(.horizontal) // Apply horizontal padding
            // Adjusted HStack for Month and Year with Arrows and Improved Spacing
            HStack(spacing: 20) {
                HStack(spacing: 5) {
                    Button(action: {
                        withAnimation {
                            currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(cyan)
                    }
                    
                    Text(currentMonthFormatted)
                        .font(.headline)
                        .foregroundColor(cyan)
                    
                    Button(action: {
                        withAnimation {
                            currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(cyan)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 5) {
                    Button(action: {
                        withAnimation {
                            currentDate = Calendar.current.date(byAdding: .year, value: -1, to: currentDate) ?? currentDate
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(cyan)
                    }
                    
                    Text(currentYearFormatted)
                        .font(.headline)
                        .foregroundColor(cyan)
                    
                    Button(action: {
                        withAnimation {
                            currentDate = Calendar.current.date(byAdding: .year, value: 1, to: currentDate) ?? currentDate
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(cyan)
                    }
                }
            }
            .padding(.horizontal, 30) // Adjusted horizontal padding
            .padding(.top, 5) // Reduced top padding to move closer to the calendar grid
            .padding(.bottom, 5) // Reduced bottom padding to move closer to the calendar grid
            
            CalendarGridView(currentDate: $currentDate, selectedDate: $selectedDate, taskViewModel: taskViewModel, darkGrey: darkGrey, green: green, orange: orange)
                .gesture(DragGesture()
                            .onEnded { value in
                                if value.translation.width < 0 { // Swipe left
                                    withAnimation {
                                        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                                    }
                                } else if value.translation.width > 0 { // Swipe right
                                    withAnimation {
                                        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                                    }
                                }
                            })
            
            if let date = selectedDate {
                VStack {
                    Text("\(date, style: .date) Zen List")
                        .foregroundColor(cyan)
                        .font(.headline)
                    
                    List {
                        ForEach(taskViewModel.tasksFor(date: date)) { task in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(task.isCompleted ? cyan : .gray)
                                    .font(.system(size: 20))
                                Text(task.title)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.vertical, 5)
                        }
                        .listRowBackground(darkGrey)
                        .listRowSeparator(.hidden) // Hide the separator lines between tasks
                    }
                    .listStyle(PlainListStyle())
                }
                .background(darkGrey)
            } else {
                Text("Select a date to check your Zen")
                    .foregroundColor(.gray)
                    .padding()
            }
            
            Spacer()
        }
        .padding(.horizontal, 10) // Use padding, but not excessively
        .frame(maxWidth: .infinity) // Ensure the VStack uses the full width
        .background(darkGrey)
        .edgesIgnoringSafeArea(.horizontal)
        .navigationBarHidden(true)
    }
    
    private var currentMonth: Int {
        Calendar.current.component(.month, from: currentDate)
    }
    
    private var currentYear: Int {
        Calendar.current.component(.year, from: currentDate)
    }
    
    private var currentMonthFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM" // Format to show only Month
        return formatter.string(from: currentDate)
    }
    
    private var currentYearFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy" // Format to show only Year
        return formatter.string(from: currentDate)
    }
    
    private func getDate(month: Int, year: Int) -> Date {
        var components = DateComponents()
        components.month = month
        components.year = year
        return Calendar.current.date(from: components) ?? Date()
    }
}

struct CalendarGridView: View {
    @Binding var currentDate: Date
    @Binding var selectedDate: Date?
    @ObservedObject var taskViewModel: TaskViewModel
    
    let darkGrey: Color
    let green: Color
    let orange: Color
    
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
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
                ForEach(0..<leadingEmptyCells, id: \.self) { _ in
                    Text("")
                }
                
                ForEach(days) { day in
                    Text("\(day.dayNumber)")
                        .foregroundColor(day.hasTasks ? (day.isCompleted ? green : orange) : .gray)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            selectedDate = day.date
                        }
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
