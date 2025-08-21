import SwiftUI

struct ProfilePage: View {
    @State private var selectedTab: Int = 3 // Profile is now index 3
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("userPhoneNumber") private var phoneNumber: String = ""
    @State private var shouldNavigateToLoading = false
    @EnvironmentObject private var navigationManager: PageNavigationManager
    
    var body: some View {
        NavigationContentView(selectedTab: $selectedTab) {
            VStack(spacing: 20) {
                Text("Profile")
                    .font(.custom("PlayfairDisplaySC-Regular", size: 28))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 60)
                    .padding(.horizontal, 20)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Profile Header
                        ProfileHeaderCard(name: userName, phone: phoneNumber)
                        
                        // Health Stats
                        HealthStatsCard()
                        
                        // Preferences
                        PreferencesCard()
                        
                        // Account Actions
                        AccountActionsCard(shouldNavigateToLoading: $shouldNavigateToLoading)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .onChange(of: shouldNavigateToLoading) { oldValue, newValue in
            if newValue {
                // Navigate back to LoadingPage (page 1) to trigger existing user check
                navigationManager.goToPage(1)
                shouldNavigateToLoading = false
            }
        }
    }
}

struct ProfileHeaderCard: View {
    let name: String
    let phone: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(AppConstants.Colors.primary)
            
            VStack(spacing: 4) {
                Text(name.isEmpty ? "User" : name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppConstants.Colors.textPrimary)
                
                Text(phone.isEmpty ? "No phone number" : phone)
                    .font(.subheadline)
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }
        }
        .padding()
        .background(AppConstants.Colors.white)
        .cornerRadius(16)
        .shadow(color: AppConstants.Colors.shadowMedium, radius: 8, x: 0, y: 4)
    }
}

struct HealthStatsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health Stats")
                .font(.headline)
                .foregroundColor(AppConstants.Colors.textPrimary)
            
            HStack(spacing: 20) {
                StatItem(title: "Days Active", value: "7", icon: "calendar")
                StatItem(title: "Analyses", value: "3", icon: "chart.pie")
                StatItem(title: "Journal Entries", value: "12", icon: "book")
            }
        }
        .padding()
        .background(AppConstants.Colors.white)
        .cornerRadius(16)
        .shadow(color: AppConstants.Colors.shadowMedium, radius: 8, x: 0, y: 4)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppConstants.Colors.primary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppConstants.Colors.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(AppConstants.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PreferencesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences")
                .font(.headline)
                .foregroundColor(AppConstants.Colors.textPrimary)
            
            VStack(spacing: 12) {
                PreferenceRow(title: "Notifications", icon: "bell", hasToggle: true)
                PreferenceRow(title: "Dark Mode", icon: "moon", hasToggle: true)
                PreferenceRow(title: "Health Reminders", icon: "clock", hasToggle: true)
            }
        }
        .padding()
        .background(AppConstants.Colors.white)
        .cornerRadius(16)
        .shadow(color: AppConstants.Colors.shadowMedium, radius: 8, x: 0, y: 4)
    }
}

struct PreferenceRow: View {
    let title: String
    let icon: String
    let hasToggle: Bool
    @State private var isEnabled = true
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppConstants.Colors.primary)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(AppConstants.Colors.textPrimary)
            
            Spacer()
            
            if hasToggle {
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }
        }
    }
}

struct AccountActionsCard: View {
    @Binding var shouldNavigateToLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account")
                .font(.headline)
                .foregroundColor(AppConstants.Colors.textPrimary)
            
            VStack(spacing: 12) {
                ActionRow(title: "Edit Profile", icon: "person.crop.circle")
                ActionRow(title: "Privacy Settings", icon: "lock")
                ActionRow(title: "Help & Support", icon: "questionmark.circle")
                ActionRow(title: "Sign Out", icon: "rectangle.portrait.and.arrow.right", isDestructive: true, shouldNavigateToLoading: $shouldNavigateToLoading)
            }
        }
        .padding()
        .background(AppConstants.Colors.white)
        .cornerRadius(16)
        .shadow(color: AppConstants.Colors.shadowMedium, radius: 8, x: 0, y: 4)
    }
}

struct ActionRow: View {
    let title: String
    let icon: String
    var isDestructive: Bool = false
    var shouldNavigateToLoading: Binding<Bool>? = nil
    @StateObject private var verificationService = PhoneVerificationService.shared
    @State private var showSignOutAlert = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isDestructive ? .red : AppConstants.Colors.primary)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(isDestructive ? .red : AppConstants.Colors.textPrimary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppConstants.Colors.textSecondary)
        }
        .onTapGesture {
            if title == "Sign Out" {
                showSignOutAlert = true
            }
        }
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                signOut()
            }
        } message: {
            Text("Are you sure you want to sign out? This will clear your data and return you to the onboarding flow.")
        }
    }
    
    private func signOut() {
        Task {
            do {
                // Sign out from Firebase
                try await verificationService.signOut()
                
                // Clear stored user data
                UserDefaults.standard.removeObject(forKey: "userPhoneNumber")
                UserDefaults.standard.removeObject(forKey: "userName")
                UserDefaults.standard.removeObject(forKey: "userBirthDate")
                
                // Clear any other stored data
                UserDefaults.standard.synchronize()
                
                print("✅ User signed out successfully")
                
                // Trigger navigation back to LoadingPage
                await MainActor.run {
                    shouldNavigateToLoading?.wrappedValue = true
                }
            } catch {
                print("❌ Error signing out: \(error)")
            }
        }
    }
}

struct ProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePage()
    }
} 