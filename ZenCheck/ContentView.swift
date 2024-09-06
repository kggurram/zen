import SwiftUI

struct ContentView: View {
    @ObservedObject var taskViewModel = TaskViewModel()
    
    var body: some View {
        TabView {
            HomeView(taskViewModel: taskViewModel)
                .tabItem {
                    VStack{
                        Image(systemName: "checkmark.circle.fill")
//                        Text("Home")
                    }
                    
                    
                }

            CalendarView(taskViewModel: taskViewModel)
                .tabItem {
                    Image(systemName: "calendar")
//                    Text("Calendar")
                }
            AnalyticsView(taskViewModel: taskViewModel)
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
//                    Text("Analytics")
                }
        }
        .accentColor(.cyan) // Set the tab bar color to cyan to match your color scheme
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



