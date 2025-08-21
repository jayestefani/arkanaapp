import SwiftUI

struct LoadingPage: View {
    @Binding var currentPage: Int
    @State private var animate = false
    @State private var taglineVisible = false
    @State private var breathingScale: CGFloat = 1.0
    @EnvironmentObject private var navigationManager: PageNavigationManager
    // @EnvironmentObject private var timeManager: TimeManager // Temporarily commented out due to module visibility issue
    
    // Check for existing user
    @StateObject private var verificationService = PhoneVerificationService.shared
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppConstants.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // App Logo/Icon - Using system icon instead of missing AppIcon
                    
                    // App Name - Bigger with gentle breathing pulse
                    Text("ARKANA")
                        .font(.custom("CormorantGaramond-Bold", size: geo.size.width * 0.12)) // Bigger size
                        .foregroundColor(AppConstants.Colors.textPrimary)
                        .opacity(animate ? 1 : 0)
                        .scaleEffect(breathingScale)
                        .animation(AppConstants.Animation.slow, value: animate)
                        .animation(
                            .easeInOut(duration: 4.0) // Slower, gentler pulse
                            .repeatForever(autoreverses: true),
                            value: breathingScale
                        )
                        .padding(.top, geo.size.height * 0.02) // Reduced spacing
                    
                    // Time-based greeting using TimeManager (Temporarily disabled due to module visibility issue)
                    // if taglineVisible {
                    //     Text(timeManager.greeting)
                    //         .font(.custom("NotoSansSC-Regular", size: geo.size.width * 0.045))
                    //         .foregroundColor(Color(hex: timeManager.timeColor))
                    //         .opacity(taglineVisible ? 1 : 0)
                    //         .animation(.easeInOut(duration: 1.0), value: taglineVisible)
                    //         .padding(.top, geo.size.height * 0.01)
                    // }
                    
                    // Tagline - Closer spacing, slower fade-in
                    Text("ancient medicine for modern life")
                        .font(.custom("CormorantGaramond-Regular", size: geo.size.width * 0.055))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(taglineVisible ? 1 : 0)
                        .offset(y: taglineVisible ? 0 : 10) // Reduced offset
                        .animation(.easeInOut(duration: 1.5), value: taglineVisible) // Slower fade-in
                        .padding(.top, geo.size.height * 0.01) // Very close spacing
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.horizontal, geo.size.width * 0.08)
            }
        }
        .onAppear {
            animate = true
            
            // Start gentle breathing animation
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                breathingScale = 1.03 // Gentler scale change
            }
            
            // Fade in tagline after a longer delay for slower effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                taglineVisible = true
            }
            
            // Check for existing user and route accordingly
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                checkExistingUserAndRoute()
            }
        }
    }
    
    // MARK: - Existing User Check
    private func checkExistingUserAndRoute() {
        print("🔍 Checking for existing user...")
        
        // Check multiple indicators of existing user
        let isFirebaseSignedIn = verificationService.isSignedIn
        let storedPhoneNumber = UserDefaults.standard.string(forKey: "userPhoneNumber")
        let storedName = UserDefaults.standard.string(forKey: "userName")
        let hasStoredPhoneNumber = storedPhoneNumber != nil && !storedPhoneNumber!.isEmpty
        let hasStoredName = storedName != nil && !storedName!.isEmpty
        
        print("🔍 Firebase signed in: \(isFirebaseSignedIn)")
        print("🔍 Has stored phone: \(hasStoredPhoneNumber)")
        print("🔍 Has stored name: \(hasStoredName)")
        print("🔍 Stored phone number: \(storedPhoneNumber ?? "nil")")
        print("🔍 Stored name: \(storedName ?? "nil")")
        
        // Consider user existing ONLY if they're signed in with Firebase
        // Don't use stored data as it gets set during onboarding
        if isFirebaseSignedIn {
            print("✅ Existing user found - routing to dashboard")
            print("✅ Routing to page 19 (Main Dashboard)")
            // Route directly to main dashboard
            currentPage = 19
        } else {
            print("🆕 New user - continuing with onboarding")
            print("🆕 Routing to page 2 (Sign In Choice)")
            // Continue with onboarding flow
            navigationManager.nextPage()
        }
    }
}

struct LoadingPage_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var currentPage = 1
        @StateObject private var navigationManager = PageNavigationManager()
        
        var body: some View {
            LoadingPage(currentPage: $currentPage)
                .environmentObject(navigationManager)
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
 
