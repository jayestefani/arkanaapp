import SwiftUI

struct AnalyticsDashboardPage: View {
    var body: some View {
        VStack {
            Text("Analytics Dashboard")
                .font(.title)
                .foregroundColor(.black)
            
            Text("Track your health journey")
                .font(.body)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct AnalyticsDashboardPage_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsDashboardPage()
    }
} 