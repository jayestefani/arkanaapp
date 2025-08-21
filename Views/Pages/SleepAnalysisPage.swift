import SwiftUI
#if canImport(Firebase)
import Firebase
import FirebaseAuth
import FirebaseFirestore
#endif

struct SleepAnalysisPage: View {
    @Binding var currentPage: Int
    @State private var selectedIndex: Int? = nil
    @State private var showPopup = false
    @StateObject private var profileService = UserProfileService.shared
    @State private var isSavingSleep = false

    let sleepOptions = [
        ("Deep Sleep", "sleep well, feel refreshed", LinearGradient(gradient: Gradient(colors: [AppConstants.Colors.secondary.opacity(0.3), AppConstants.Colors.accent.opacity(0.3)]), startPoint: .leading, endPoint: .trailing), "DeepSleepMoon"), // Dark Green for excellent
        ("Light Sleep", "sleep okay, still feel tired", LinearGradient(gradient: Gradient(colors: [Color(hex: "#FFD93D").opacity(0.3), Color(hex: "#FFB74D").opacity(0.3)]), startPoint: .leading, endPoint: .trailing), "LightSleepMoon"), // Yellow for middle
        ("Broken Sleep", "restless sleep, wake up groggy", LinearGradient(gradient: Gradient(colors: [Color(hex: "#D45A5A").opacity(0.3), Color(hex: "#FF6B35").opacity(0.3)]), startPoint: .leading, endPoint: .trailing), "BrokenSleepMoon"), // Lighter Red for poor
        ("Barely Sleep", "feels like no sleep, wake up groggy", LinearGradient(gradient: Gradient(colors: [AppConstants.Colors.primary.opacity(0.3), AppConstants.Colors.primary.opacity(0.3)]), startPoint: .leading, endPoint: .trailing), "NoSleepMoon") // Brand Red for very poor
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppConstants.Colors.secondaryBackgroundGradient
                    .ignoresSafeArea()

                VStack {
                    // Header
                    Text("How do you typically sleep?")
                        .font(.custom("PlayfairDisplay-Regular", size: 24))
                        .fontWeight(.semibold)
                        .padding(.top, geo.size.height * 0.065)
                        .foregroundColor(AppConstants.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: geo.size.width * 0.86, alignment: .leading)
                        .padding(.horizontal, geo.size.width * 0.07)
                        .padding(.bottom, geo.size.height * 0.05)

                    // Sleep Options Grid
                    let columns = [
                        GridItem(.flexible(), spacing: geo.size.width * 0.04),
                        GridItem(.flexible(), spacing: geo.size.width * 0.04)
                    ]
                    LazyVGrid(columns: columns, spacing: AppConstants.Spacing.responsiveMedium(geo.size.height)) {
                        ForEach(0..<sleepOptions.count, id: \.self) { index in
                            let (title, subtext, gradient, imageName) = sleepOptions[index]
                            let isSelected = selectedIndex == index

                            Button(action: {
                                if selectedIndex == index {
                                    selectedIndex = nil
                                } else {
                                    selectedIndex = index
                                }
                            }) {
                                VStack(alignment: .center, spacing: 0) {
                                    HStack(spacing: geo.size.width * 2) {
                                        Image(imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: geo.size.width * 0.22, height: geo.size.width * 0.22)
                                    }
                                    HStack {
                                        Text(title)
                                            .font(.custom("PlayfairDisplaySC-Bold", size: geo.size.width * 0.045))
                                            .foregroundColor(AppConstants.Colors.textPrimary)
                                            .lineLimit(1)
                                            .multilineTextAlignment(.center)
                                            .padding(.top, geo.size.height * 0.02)
                                    }
                                    HStack {
                                        Text(subtext)
                                            .font(AppConstants.Fonts.responsiveBody(geo.size.width * 0.8))
                                            .foregroundColor(AppConstants.Colors.textPrimary)
                                            .multilineTextAlignment(.center)
                                            .fontWeight(.regular)
                                            .padding(.top, geo.size.height * 0.008)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, minHeight: geo.size.height * 0.13)
                                .background(isSelected ? AnyView(gradient) : AnyView(AppConstants.Colors.white))
                                .cornerRadius(16)
                                .shadow(color: AppConstants.Colors.shadowBlackStrong, radius: 4, x: 0, y: 4)
                            }
                        }
                    }
                    .padding(.horizontal, geo.size.width * 0.07)

                    // Yang Popup Button
                    Button(action: { showPopup.toggle() }) {
                        Text("Poor sleep = overheated Yang. Cool it with herbal rituals. 🌿")
                            .font(AppConstants.Fonts.responsiveBody(geo.size.width))
                            .foregroundColor(AppConstants.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, geo.size.width * 0.07)
                            .padding(.top, geo.size.height * 0.1)
                    }
                    .sheet(isPresented: $showPopup) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("In Chinese Medicine, 'overheated Yang' refers to an excess of active, fiery energy in the body, often linked to poor sleep, restlessness, or night sweats. This usually can be linked to Yang imbalance due to stress, late nights, or stimulants. Herbal rituals—like cooling chrysanthemum tea 🌼 or mint-infused baths—help restore balance by grounding excess heat. Modern science shows poor sleep raises cortisol (a stress hormone) and body temperature, disrupting circadian rhythms. TCM's 'cooling' herbs often contain compounds (e.g., antioxidants) that support relaxation and lower inflammation, bridging ancient wisdom and biology.")
                                .font(AppConstants.Fonts.responsiveBody(geo.size.width))

                            PrimaryButton("Close") {
                                showPopup = false
                            }
                        }
                        .padding()
                    }

                    Spacer()

                    // Next Button
                    PrimaryButton(isSavingSleep ? "Saving..." : "next", isEnabled: selectedIndex != nil && !isSavingSleep) {
                        if selectedIndex != nil {
                            saveSleepPattern()
                        }
                    }
                    .padding(.horizontal, geo.size.width * 0.07)
                    .padding(.bottom, geo.size.height * 0.03)
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            }
        }
    }
    
    private func saveSleepPattern() {
        _saveSleepPattern()
    }
}

#if canImport(Firebase)
extension SleepAnalysisPage {
    private func _saveSleepPattern() {
        guard let userId = Auth.auth().currentUser?.uid,
              let selectedIndex = selectedIndex else {
            print("❌ No user signed in or no selection")
            return
        }
        
        isSavingSleep = true
        
        Task {
            do {
                let sleepPattern = sleepOptions[selectedIndex].0
                try await profileService.updateOnboardingData(
                    userId: userId,
                    healthGoals: [], // Keep existing goals
                    sleepPattern: sleepPattern
                )
                
                await MainActor.run {
                    isSavingSleep = false
                    currentPage += 1
                }
            } catch {
                await MainActor.run {
                    isSavingSleep = false
                    print("❌ Error saving sleep pattern: \(error)")
                }
            }
        }
    }
}
#else
extension SleepAnalysisPage {
    private func _saveSleepPattern() {
        isSavingSleep = false
        currentPage += 1
    }
}
#endif

struct SleepAnalysisPage_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var dummyPage = 11
        var body: some View {
            SleepAnalysisPage(currentPage: $dummyPage)
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}

