import SwiftUI
import Charts

struct AnalyticsView: View {
    @ObservedObject var taskViewModel: TaskViewModel
    @State private var selectedTimeScale: TimeScale = .week // Default to week

    // Define colors here
    private let darkGrey = Color(.systemGray6)
    private let cyan = Color.cyan
    private let orange = Color.orange
    private let green = Color.green

    // Enum to define the different time scales
    enum TimeScale: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case sixMonths = "6 Months"
        case year = "Year"
    }

    var body: some View {
        VStack {
            // Top section - Task Completion
            HStack {
//                Text(selectedTimeScale.rawValue)
                  Text("Analytics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(cyan)
                    .padding(.top)
                Spacer()
            }
            .padding(.top, 10)
            .padding(.horizontal)

            // Line Chart for task completion trend
            let completedTrendData = taskCompletionTrend(for: selectedTimeScale)
            let incompleteTrendData = taskIncompleteTrend(for: selectedTimeScale)

            if !completedTrendData.isEmpty || !incompleteTrendData.isEmpty {
                Chart {
                    // Completed tasks line and points
                    if completedTrendData.count > 1 {
                        ForEach(completedTrendData) { completionTrend in
                            LineMark(
                                x: .value("Date", completionTrend.date, unit: .day),
                                y: .value("Completed Tasks", completionTrend.completedTasks),
                                series: .value("Task Status", "Completed") // Series for completed tasks
                            )
                            .foregroundStyle(green)
                            .interpolationMethod(.catmullRom)
                        }
                    }

                    ForEach(completedTrendData) { completionTrend in
                        PointMark(
                            x: .value("Date", completionTrend.date, unit: .day),
                            y: .value("Completed Tasks", completionTrend.completedTasks)
                        
                        )
                        .foregroundStyle(green)
                    }

                    // Incomplete tasks line and points
                    if incompleteTrendData.count > 1 {
                        ForEach(incompleteTrendData) { incompleteTrend in
                            LineMark(
                                x: .value("Date", incompleteTrend.date, unit: .day),
                                y: .value("Incomplete Tasks", incompleteTrend.incompleteTasks),
                                series: .value("Task Status", "Incomplete") // Series for incomplete tasks
                            )
                            .foregroundStyle(orange)
                            .interpolationMethod(.catmullRom)
                        }
                    }

                    ForEach(incompleteTrendData) { incompleteTrend in
                        PointMark(
                            x: .value("Date", incompleteTrend.date, unit: .day),
                            y: .value("Incomplete Tasks", incompleteTrend.incompleteTasks)
                            
                        )
                        .foregroundStyle(orange)
                    }
                }
                .frame(height: 200)
                .padding(.horizontal)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel() {
                            if let dateValue = value.as(Date.self) {
                                Text(dateValue.formatted(.dateTime.day().month())) // Short format for day and month
                                    .font(.caption)
                            }
                        }
                    }
                }

            }

 else {
                Text("No Data Available for \(selectedTimeScale.rawValue)")
                    .foregroundColor(.gray)
                    .padding(.top, 10)
            }

            // Segmented control for time scale selection
            Picker("Time Scale", selection: $selectedTimeScale) {
                ForEach(TimeScale.allCases, id: \.self) { scale in
                    Text(scale.rawValue).tag(scale)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.vertical, 20)

            // Task Metrics Section
            VStack(spacing: 10) {
                metricCardView(metricName: "Total", value: "\(taskViewModel.allTasks().count)", color: cyan)
                metricCardView(metricName: "Completed", value: "\(taskViewModel.allTasks().filter { $0.isCompleted }.count)", color: green)
                metricCardView(metricName: "Incomplete", value: "\(taskViewModel.allTasks().filter { !$0.isCompleted }.count)", color: orange)
            }

            Spacer()
        }
        .padding(.horizontal)
        .background(darkGrey)
        .navigationBarHidden(true)
    }

    // MARK: - Task Completion Trend (Completed Tasks)
    func taskCompletionTrend(for timeScale: TimeScale) -> [TaskCompletionData] {
        let now = Date()
        let calendar = Calendar.current
        let startDate: Date

        switch timeScale {
        case .week:
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }

        let tasks = taskViewModel.getTasks(from: startDate, to: now)

        // Group tasks by day
        let groupedTasks = Dictionary(grouping: tasks) { task in
            return calendar.startOfDay(for: task.date)
        }

        // Convert the grouped tasks into trend data
        return groupedTasks.map { (key, tasks) in
            let completedTasks = tasks.filter { $0.isCompleted }.count
            return TaskCompletionData(date: key, completedTasks: completedTasks)
        }.sorted(by: { $0.date < $1.date })
    }

    // MARK: - Task Incomplete Trend (Incomplete Tasks)
    func taskIncompleteTrend(for timeScale: TimeScale) -> [TaskIncompleteData] {
        let now = Date()
        let calendar = Calendar.current
        let startDate: Date

        switch timeScale {
        case .week:
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }

        let tasks = taskViewModel.getTasks(from: startDate, to: now)

        // Group tasks by day
        let groupedTasks = Dictionary(grouping: tasks) { task in
            return calendar.startOfDay(for: task.date)
        }

        // Convert the grouped tasks into trend data
        return groupedTasks.map { (key, tasks) in
            let incompleteTasks = tasks.filter { !$0.isCompleted }.count
            return TaskIncompleteData(date: key, incompleteTasks: incompleteTasks)
        }.sorted(by: { $0.date < $1.date })
    }

    // MARK: - Metric Card View
    func metricCardView(metricName: String, value: String, color: Color) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(metricName)
                    .font(.headline)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(10)
    }
}

// Struct for completed tasks trend
struct TaskCompletionData: Identifiable {
    let id = UUID()
    let date: Date
    let completedTasks: Int
}

// Struct for incomplete tasks trend
struct TaskIncompleteData: Identifiable {
    let id = UUID()
    let date: Date
    let incompleteTasks: Int
}
