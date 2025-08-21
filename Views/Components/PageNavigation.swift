import SwiftUI

// MARK: - Page Navigation Manager
class PageNavigationManager: ObservableObject {
    @Published var currentPage: Int = 1
    
    // Page definitions
    static let pages: [PageInfo] = [
        PageInfo(id: 1, name: "Loading Page", description: "App initialization and loading"),
        PageInfo(id: 2, name: "Sign In", description: "User authentication choice"),
        PageInfo(id: 3, name: "Phone Number", description: "Phone number input"),
        PageInfo(id: 4, name: "Verification", description: "SMS code verification"),
        PageInfo(id: 5, name: "Name Input", description: "User name collection"),
        PageInfo(id: 6, name: "Birth Date", description: "User birth date collection"),
        PageInfo(id: 7, name: "Transition", description: "Chinese Medicine intro transition"),
        PageInfo(id: 8, name: "Intro", description: "App introduction and overview"),
        PageInfo(id: 9, name: "Survey Start", description: "Health goals survey"),
        PageInfo(id: 10, name: "Health Goals", description: "User health objectives"),
        PageInfo(id: 11, name: "Sleep Analysis", description: "Sleep pattern assessment"),
        PageInfo(id: 12, name: "Energy Survey", description: "Energy level evaluation"),
        PageInfo(id: 13, name: "Digestion Analysis", description: "Digestive health assessment"),
        PageInfo(id: 14, name: "Stress Survey", description: "Stress level assessment"),
        PageInfo(id: 15, name: "Energy Analysis", description: "Energy feeling cards"),
        PageInfo(id: 16, name: "Tongue Scan", description: "Tongue scanning interface"),
        PageInfo(id: 17, name: "Tongue Analysis", description: "Tongue analysis processing"),
        PageInfo(id: 18, name: "Tongue Results", description: "Tongue analysis results"),
        PageInfo(id: 19, name: "Main Dashboard", description: "Primary app dashboard")
    ]
    
    // Navigation methods
    func goToPage(_ page: Int) {
        withAnimation(AppConstants.Animation.standard) {
            currentPage = page
        }
    }
    
    func nextPage() {
        goToPage(currentPage + 1)
    }
    
    func previousPage() {
        goToPage(currentPage - 1)
    }
    
    func goToLoadingPage() {
        goToPage(1)
    }
    
    func goToMainDashboard() {
        goToPage(20)
    }
    
    // Validation
    func isValidPage(_ page: Int) -> Bool {
        return page >= 1 && page <= PageNavigationManager.pages.count
    }
    
    func getCurrentPageInfo() -> PageInfo? {
        return PageNavigationManager.pages.first { $0.id == currentPage }
    }
}

// MARK: - Page Info Model
struct PageInfo: Identifiable {
    let id: Int
    let name: String
    let description: String
}

// MARK: - Page Navigation View
struct PageNavigationView: View {
    @ObservedObject var navigationManager: PageNavigationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(PageNavigationManager.pages) { page in
                    Button(action: {
                        navigationManager.goToPage(page.id)
                        dismiss()
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Page \(page.id)")
                                    .font(AppConstants.Fonts.bodyMedium)
                                    .foregroundColor(AppConstants.Colors.primary)
                                
                                Spacer()
                                
                                if navigationManager.currentPage == page.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppConstants.Colors.primary)
                                }
                            }
                            
                            Text(page.name)
                                .font(AppConstants.Fonts.heading)
                                .foregroundColor(AppConstants.Colors.textPrimary)
                            
                            Text(page.description)
                                .font(AppConstants.Fonts.body)
                                .foregroundColor(AppConstants.Colors.textSecondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Page Directory")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #endif
            }
        }
    }
}

// MARK: - Navigation Helper View
struct NavigationHelperView: View {
    @ObservedObject var navigationManager: PageNavigationManager
    @State private var showPageManager = false
    
    var body: some View {
        Button(action: {
            showPageManager.toggle()
        }) {
            Image(systemName: "list.bullet")
                .foregroundColor(AppConstants.Colors.primary)
                .font(.title2)
                .padding()
                .background(AppConstants.Colors.white.opacity(0.8))
                .clipShape(Circle())
        }
        .sheet(isPresented: $showPageManager) {
            PageNavigationView(navigationManager: navigationManager)
        }
    }
} 