import SwiftUI

// MARK: - Bottom Navigation Bar
struct BottomNavigationBar: View {
    @Binding var selectedTab: Int
    let geo: GeometryProxy
    
    // Navigation items - Dashboard (home) is now first
    private let navigationItems = [
        NavigationItem(id: 0, title: "Dashboard", icon: "yinyangblack", iconUnselected: "yinyangblack"),
        NavigationItem(id: 1, title: "Journey", icon: "map.fill", iconUnselected: "map"),
        NavigationItem(id: 2, title: "Analysis", icon: "chart.pie.fill", iconUnselected: "chart.pie"),
        NavigationItem(id: 3, title: "Profile", icon: "person.fill", iconUnselected: "person"),
        NavigationItem(id: 4, title: "Settings", icon: "gearshape.fill", iconUnselected: "gearshape")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(navigationItems, id: \.id) { item in
                NavigationTabButton(
                    item: item,
                    isSelected: selectedTab == item.id,
                    geo: geo
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = item.id
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        // .background(
        //     Rectangle()
        //         .fill(AppConstants.Colors.white)
        //         .shadow(
        //             color: AppConstants.Colors.shadowMedium,
        //             radius: 20,
        //             x: 0,
        //             y: -5
        //         )
        // )
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

// MARK: - Navigation Item Model
struct NavigationItem {
    let id: Int
    let title: String
    let icon: String
    let iconUnselected: String
}

// MARK: - Navigation Tab Button
struct NavigationTabButton: View {
    let item: NavigationItem
    let isSelected: Bool
    let geo: GeometryProxy
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if item.id == 0 {
                    // Use custom yinyangblack asset for Dashboard
                    Image("yinyangblack")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geo.size.width * 0.08, height: geo.size.width * 0.08)
                } else {
                    // SF Symbol for other tabs
                    Image(systemName: isSelected ? item.icon : item.iconUnselected)
                        .font(.system(size: geo.size.width * 0.06, weight: .medium))
                        .foregroundColor(isSelected ? AppConstants.Colors.primary : AppConstants.Colors.textSecondary)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isSelected)
                }
            }
            .padding(.top, 20)
            .frame(maxWidth: .infinity)
            .padding(.vertical, geo.size.height * 0.015)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.clear)
                    .scaleEffect(isSelected ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Navigation Content View
struct NavigationContentView<Content: View>: View {
    @Binding var selectedTab: Int
    let content: Content
    
    init(selectedTab: Binding<Int>, @ViewBuilder content: () -> Content) {
        self._selectedTab = selectedTab
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Main content and nav bar
                VStack(spacing: 0) {
                    content
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    BottomNavigationBar(selectedTab: $selectedTab, geo: geo)
                        .frame(maxWidth: .infinity)
                }

                // Second VStack (currently empty, but visible)
                VStack(spacing: 0) {
                    // Add content here if needed
                }
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                // .background(Color.white)
            }
            .background(AppConstants.Colors.backgroundGradient)
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}

// MARK: - Preview
struct BottomNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationContentView(selectedTab: .constant(0)) {
            VStack {
                Text("Dashboard Content")
                    .font(.title)
                    .foregroundColor(.white)
                Spacer()
            }
        }
    }
} 
 