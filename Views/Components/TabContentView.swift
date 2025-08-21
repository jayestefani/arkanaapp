import SwiftUI

struct TabContentView: View {
    @Binding var selectedTab: Int
    
    @ViewBuilder
    var body: some View {
        NavigationContentView(selectedTab: $selectedTab) {
            switch selectedTab {
            case 0:
                MainDashboardPage()
            case 1:
                JourneyPage()
            case 2:
                AnalyticsView()
            case 3:
                ProfilePage()
            case 4:
                SettingsPage()
            default:
                MainDashboardPage()
            }
        }
    }
}

struct AnalyticsView: View {
    var body: some View {
        VStack {
            Text("Analytics")
                .font(.title)
                .foregroundColor(.black)
            
            Text("Track your health journey")
                .font(.body)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct TabContentView_Previews: PreviewProvider {
    static var previews: some View {
        TabContentView(selectedTab: .constant(2))
    }
} 