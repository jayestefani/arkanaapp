import SwiftUI

#if canImport(Firebase)
import Firebase
import FirebaseAuth
import FirebaseFirestore
#endif

struct HealthGoalsPage: View {
    @Binding var currentPage: Int
    @State private var selectedOptions: Set<Int> = []
    @State private var wordVisibility = Array(repeating: false, count: 14)
    @State private var subheaderVisible = false
    @State private var optionsVisible = false
    @State private var buttonVisible = false
    @StateObject private var profileService = UserProfileService.shared
    @State private var isSavingGoals = false
    
    private let words: [(text: String, font: Font)] = [
        ("How", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("can", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("we", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("support", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("your", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("health", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("goals", AppConstants.Fonts.heading),
        ("?", AppConstants.Fonts.heading)
    ]
    
    let options = [
        ("Herbal & Tea Remedies", "🍵"),
        ("Chinese Medicine 101", "📖"),
        ("Practitioner Matching", "👨🏻‍⚕️"),
        ("Community and Events", "🎪"),
        ("Daily Rituals", "📋"),
        ("Food as Medicine", "🥣"),
        ("Personalized Assessments", "🧪"),
    ]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppConstants.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: AppConstants.Spacing.responsiveLarge(geo.size.height)) {
                    // Main heading
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 0) {
                            ForEach(0..<7, id: \.self) { idx in
                                Text(words[idx].text)
                                    .font(words[idx].font)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppConstants.Colors.textPrimary)
                                    .opacity(wordVisibility[idx] ? 1 : 0)
                                    .animation(AppConstants.Animation.standard, value: wordVisibility[idx])
                            }
                        }
                        HStack(spacing: 0) {
                            ForEach(8..<words.count, id: \.self) { idx in
                                Text(words[idx].text)
                                    .font(words[idx].font)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppConstants.Colors.textPrimary)
                                    .opacity(wordVisibility[idx] ? 1 : 0)
                                    .animation(AppConstants.Animation.standard, value: wordVisibility[idx])
                            }
                        }
                        // Subheader for multi-select clarification
                        Text("Select up to 3 goals")
                            .font(.custom("PlayfairDisplay-Regular", size: geo.size.width * 0.042))
                            .foregroundColor(Color(hex: "#2A2D34").opacity(0.9))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: geo.size.width * 0.86, alignment: .leading)
                            .lineSpacing(geo.size.width * 0.042 * 0.4)
                            .kerning(0.2)
                            .padding(.top, geo.size.height * 0.02)
                            .opacity(subheaderVisible ? 1 : 0)
                            .animation(AppConstants.Animation.standard, value: subheaderVisible)
                    }
                    .frame(maxWidth: geo.size.width * 0.86, alignment: .leading)
                    .padding(.horizontal, geo.size.width * 0.07)
                    .padding(.top, geo.size.height * 0.065)
                    .padding(.bottom, geo.size.height * 0.008) // Reduced spacing between subheader and first pill
                    
                    // Option list
                    VStack(spacing: geo.size.height * 0.024) {
                        ForEach(0..<options.count, id: \.self) { index in
                            let (title, emoji) = options[index]
                            let isSelected = selectedOptions.contains(index)
                            Button(action: {
                                if isSelected {
                                    selectedOptions.remove(index)
                                } else if selectedOptions.count < 3 {
                                    selectedOptions.insert(index)
                                }
                            }) {
                                HStack {
                                    Text(emoji)
                                        .font(.custom("PlayfairDisplay-Regular", size: 16))
                                        .foregroundColor(isSelected ? .white : AppConstants.Colors.textPrimary)
                                        .padding(.trailing, geo.size.width * 0.025)
                                        .scaleEffect(isSelected ? 1.1 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                                    Text(title)
                                        .font(.custom("PlayfairDisplay-Regular", size: 16))
                                        .foregroundColor(isSelected ? .white : AppConstants.Colors.textPrimary)
                                    Spacer()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(optionBackground(isSelected: isSelected))
                                .cornerRadius(30)
                            }
                        }
                    }
                    .opacity(optionsVisible ? 1 : 0)
                    .animation(AppConstants.Animation.standard, value: optionsVisible)
                    .padding(.horizontal, geo.size.width * 0.07)
                    .padding(.bottom, geo.size.height * 0.01) // Further reduced spacing below last pill
                    
                    // Next button
                    PrimaryButton(isSavingGoals ? "Saving..." : "Next", isEnabled: !selectedOptions.isEmpty && !isSavingGoals) {
                        saveHealthGoals()
                    }
                    .opacity(buttonVisible ? 1 : 0)
                    .animation(AppConstants.Animation.standard, value: buttonVisible)
                    .padding(.horizontal, geo.size.width * 0.07)
                    .padding(.bottom, geo.size.height * 0.03)
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                .onAppear {
                    animateWords()
                }
            }
        }
    }
    
    private func optionBackground(isSelected: Bool) -> some View {
        if isSelected {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#2D4A2D").opacity(0.8),
                    Color(hex: "#1A3D1A").opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            AppConstants.Colors.unselectedGradient
        }
    }

    private func animateWords() {
        for i in 0..<wordVisibility.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.22) {
                withAnimation { wordVisibility[i] = true }
            }
        }
        
        // After header animation completes, fade in the rest of the UI
        let headerDuration = Double(wordVisibility.count) * 0.22
        DispatchQueue.main.asyncAfter(deadline: .now() + headerDuration + 0.3) {
            withAnimation { subheaderVisible = true }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + headerDuration + 0.6) {
            withAnimation { optionsVisible = true }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + headerDuration + 0.9) {
            withAnimation { buttonVisible = true }
        }
    }
    
    private func saveHealthGoals() {
        #if canImport(Firebase)
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No user signed in")
            return
        }
        
        isSavingGoals = true
        
        Task {
            do {
                let selectedGoals = selectedOptions.map { options[$0].0 }
                try await profileService.updateOnboardingData(
                    userId: userId,
                    healthGoals: selectedGoals
                )
                
                await MainActor.run {
                    isSavingGoals = false
                    currentPage += 1
                }
            } catch {
                await MainActor.run {
                    isSavingGoals = false
                    print("❌ Error saving health goals: \(error)")
                }
            }
        }
        #else
        // Fallback for when Firebase is not available
        isSavingGoals = true
        
        Task {
            await MainActor.run {
                isSavingGoals = false
                currentPage += 1
            }
        }
        #endif
    }
}

struct HealthGoalsPage_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var page = 10
        var body: some View {
            HealthGoalsPage(currentPage: $page)
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}
