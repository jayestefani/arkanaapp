import SwiftUI

// Check if Firebase is available
#if canImport(Firebase)
import Firebase

@main
struct ArkanaHealthApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
#else
// Fallback when Firebase is not available
@main
struct ArkanaHealthAppFallback: App {
    var body: some Scene {
        WindowGroup {
            VStack {
                Text("Firebase SDK Required")
                    .font(.title)
                    .padding()
                
                Text("Please install Firebase SDK to use this app.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Install Firebase") {
                    // Open Firebase setup guide
                    if let url = URL(string: "https://firebase.google.com/docs/ios/setup") {
                        #if os(iOS)
                        UIApplication.shared.open(url)
                        #elseif os(macOS)
                        NSWorkspace.shared.open(url)
                        #endif
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}
#endif

struct ContentView: View {
    @StateObject private var navigationManager = PageNavigationManager()
    // @StateObject private var timeManager = TimeManager() // Temporarily commented out due to module visibility issue
    
    var body: some View {
        // Normal App Flow
        normalAppFlow
            .animation(.easeInOut(duration: 0.3), value: navigationManager.currentPage)
            .environmentObject(navigationManager)
            // .environmentObject(timeManager) // Temporarily commented out due to module visibility issue
    }
    
    @ViewBuilder
    private var normalAppFlow: some View {
        // Your existing navigation
        switch navigationManager.currentPage {
            case 1:
                LoadingPage(currentPage: $navigationManager.currentPage)
            case 2:
                SignInChoicePage(currentPage: $navigationManager.currentPage)
            case 3:
                PhoneNumberPage(currentPage: $navigationManager.currentPage)
            case 4:
                VerificationPage(currentPage: $navigationManager.currentPage)
            case 5:
                NamePage(currentPage: $navigationManager.currentPage)
            case 6:
                BirthDatePage(currentPage: $navigationManager.currentPage)
            case 7:
                TransitionPage(currentPage: $navigationManager.currentPage)
            case 8:
                IntroPage(currentPage: $navigationManager.currentPage)
            case 9:
                SurveyStartPage(currentPage: $navigationManager.currentPage)
            case 10:
                HealthGoalsPage(currentPage: $navigationManager.currentPage)
            case 11:
                SleepAnalysisPage(currentPage: $navigationManager.currentPage)
            case 12:
                EnergySurveyCarouselPage(currentPage: $navigationManager.currentPage)
            case 13:
                DigestionSliderCarouselPage(currentPage: $navigationManager.currentPage)
            case 14:
                StressSurveyPage(currentPage: $navigationManager.currentPage)
            case 15:
                YourFeelingCardCarouselPage(currentPage: $navigationManager.currentPage)
            case 16:
                TongueCaptureFlowView(currentPage: $navigationManager.currentPage)
            case 17:
                // Skip to results since camera view requires image binding
                TongueResultView(
                    result: EnhancedTongueAnalysisResult(
                        zones: [
                            "Tip": "Red — indicates Heart heat",
                            "Sides": "Pale — may reflect Liver blood deficiency",
                            "Center": "Swollen with thick coat — suggests Spleen dampness",
                            "Back": "Moist — possible Kidney yang deficiency"
                        ],
                        diagnosis: "Qi Deficiency with Damp Accumulation",
                        recommendations: [
                            "Reduce raw and cold foods",
                            "Incorporate warming herbs like ginger",
                            "Practice mindful eating and deep breathing"
                        ],
                        confidence: 0.85,
                        imageQuality: "Good",
                        additionalNotes: "The analysis shows clear patterns consistent with TCM principles."
                    ),
                    currentPage: $navigationManager.currentPage
                )
            case 18:
                // Additional tongue analysis view or skip to dashboard
                TabContentView(selectedTab: .constant(0))
            case 19:
                TabContentView(selectedTab: .constant(0))
            default:
                LoadingPage(currentPage: $navigationManager.currentPage)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 
