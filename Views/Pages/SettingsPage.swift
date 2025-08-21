import SwiftUI

struct SettingsPage: View {
    @State private var selectedTab: Int = 4 // Settings is now index 4
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("healthRemindersEnabled") private var healthRemindersEnabled = true
    @AppStorage("analyticsEnabled") private var analyticsEnabled = true
    
    var body: some View {
        NavigationContentView(selectedTab: $selectedTab) {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.custom("PlayfairDisplaySC-Regular", size: 28))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 60)
                    .padding(.horizontal, 20)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // App Settings
                        SettingsSection(title: "App Settings") {
                            SettingsToggleRow(
                                title: "Push Notifications",
                                subtitle: "Receive health reminders and updates",
                                icon: "bell",
                                isOn: $notificationsEnabled
                            )
                            
                            SettingsToggleRow(
                                title: "Dark Mode",
                                subtitle: "Use dark theme throughout the app",
                                icon: "moon",
                                isOn: $darkModeEnabled
                            )
                            
                            SettingsToggleRow(
                                title: "Health Reminders",
                                subtitle: "Daily wellness check-ins",
                                icon: "clock",
                                isOn: $healthRemindersEnabled
                            )
                        }
                        
                        // Privacy & Data
                        SettingsSection(title: "Privacy & Data") {
                            SettingsToggleRow(
                                title: "Analytics",
                                subtitle: "Help improve the app with anonymous data",
                                icon: "chart.bar",
                                isOn: $analyticsEnabled
                            )
                            
                            SettingsRow(
                                title: "Data Export",
                                subtitle: "Download your health data",
                                icon: "square.and.arrow.up"
                            )
                            
                            SettingsRow(
                                title: "Delete Account",
                                subtitle: "Permanently remove your data",
                                icon: "trash",
                                isDestructive: true
                            )
                        }
                        
                        // Support
                        SettingsSection(title: "Support") {
                            SettingsRow(
                                title: "Help Center",
                                subtitle: "Find answers to common questions",
                                icon: "questionmark.circle"
                            )
                            
                            SettingsRow(
                                title: "Contact Support",
                                subtitle: "Get help from our team",
                                icon: "envelope"
                            )
                            
                            SettingsRow(
                                title: "Rate App",
                                subtitle: "Share your feedback",
                                icon: "star"
                            )
                        }
                        
                        // About
                        SettingsSection(title: "About") {
                            SettingsRow(
                                title: "Version",
                                subtitle: "1.0.0",
                                icon: "info.circle"
                            )
                            
                            SettingsRow(
                                title: "Terms of Service",
                                subtitle: "Read our terms and conditions",
                                icon: "doc.text"
                            )
                            
                            SettingsRow(
                                title: "Privacy Policy",
                                subtitle: "Learn about data protection",
                                icon: "hand.raised"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppConstants.Colors.textPrimary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 1) {
                content
            }
            .background(AppConstants.Colors.white)
            .cornerRadius(16)
            .shadow(color: AppConstants.Colors.shadowMedium, radius: 8, x: 0, y: 4)
        }
    }
}

struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(AppConstants.Colors.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(AppConstants.Colors.textPrimary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
    }
}

struct SettingsRow: View {
    let title: String
    let subtitle: String
    let icon: String
    var isDestructive: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(isDestructive ? .red : AppConstants.Colors.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(isDestructive ? .red : AppConstants.Colors.textPrimary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppConstants.Colors.textSecondary)
        }
        .padding()
    }
}

struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPage()
    }
} 