import SwiftUI
#if os(iOS)
import UIKit
#endif
import AVFoundation

#if canImport(Firebase)
import Firebase
import FirebaseAuth
import FirebaseFirestore
#endif

struct BirthDatePage: View {
    @Binding var currentPage: Int
    @AppStorage("userBirthDate") private var birthDate: Date = BirthDatePage.makeDefaultBirthDate()
    @StateObject private var profileService = UserProfileService.shared
    @State private var selectedDate: Date = BirthDatePage.makeDefaultBirthDate()
    @State private var wordVisibility = Array(repeating: false, count: 8)
    @State private var isUpdatingProfile = false
    @State private var hasValidDate: Bool = false
    @State private var showRestOfUI = false
    
    // Computed property to safely calculate max date (10 years ago from today)
    private var maxDate: Date {
        Calendar.current.date(byAdding: .year, value: -10, to: Date()) ?? Date()
    }

    private static func makeDefaultBirthDate() -> Date {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let targetYear = currentYear - 30
        var components = DateComponents()
        components.year = targetYear
        components.month = 1
        components.day = 1
        return calendar.date(from: components) ?? Date()
    }

    private let words: [(text: String, font: Font)] = [
        ("When", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("were", AppConstants.Fonts.heading),
        (" ", AppConstants.Fonts.heading),
        ("you", AppConstants.Fonts.heading),
        (" ", AppConstants.Fonts.heading),
        ("born", AppConstants.Fonts.heading),
        ("?", AppConstants.Fonts.headingSC)
    ]

    // MARK: - Computed Properties for Date Picker
    
    @ViewBuilder
    private func datePickerBackground() -> some View {
        ZStack {
            // Main background
            RoundedRectangle(cornerRadius: 56)
                .fill(Color.black.opacity(0.1))
            
            // Inner shadow for paper-inset effect
            RoundedRectangle(cornerRadius: 56)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.08),
                            Color.black.opacity(0.02),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .blur(radius: 0.5)
            
            // Subtle inner shadow overlay
            RoundedRectangle(cornerRadius: 56)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.03),
                            Color.clear,
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
    
    @ViewBuilder
    private func datePickerOverlays() -> some View {
        // 1px white inset border for subtle lift
        RoundedRectangle(cornerRadius: 56)
            .stroke(Color.white, lineWidth: 1)
        // Light border for the picker
        RoundedRectangle(cornerRadius: 56)
            .stroke(Color(hex: "#E2D5C0"), lineWidth: 1.2)
        
        // Additional subtle stroke for definition
        RoundedRectangle(cornerRadius: 56)
            .stroke(
                Color.black.opacity(0.06),
                lineWidth: 0.5
            )
        
        // White glow overlay
        RoundedRectangle(cornerRadius: 56)
            .stroke(Color.white.opacity(0.12), lineWidth: 6)
            .blur(radius: 4)
        
        // Additional border
        RoundedRectangle(cornerRadius: 56)
            .stroke(Color.black.opacity(0.07), lineWidth: 1)
        
        // Subtle etched/paper-texture inset
        RoundedRectangle(cornerRadius: 56)
            .stroke(Color.white.opacity(0.18), lineWidth: 2)
            .blur(radius: 1.5)
            .offset(y: 1)
            .blendMode(.overlay)
        
        // Additional texture overlay
        RoundedRectangle(cornerRadius: 56)
            .stroke(Color.black.opacity(0.06), lineWidth: 1)
            .blur(radius: 0.5)
            .offset(y: -1)
            .blendMode(.multiply)
    }
    
    @ViewBuilder
    private func datePickerShadows() -> some View {
        // Primary shadow
        RoundedRectangle(cornerRadius: 56)
            .fill(Color.clear)
            .shadow(color: AppConstants.Colors.primary.opacity(0.18), radius: 28, x: 0, y: 8)
        
        // Gold shadow
        RoundedRectangle(cornerRadius: 56)
            .fill(Color.clear)
            .shadow(color: Color(hex: "#FFD700").opacity(0.10), radius: 36, x: 0, y: 0)
        
        // Medium shadow
        RoundedRectangle(cornerRadius: 56)
            .fill(Color.clear)
            .shadow(color: AppConstants.Colors.shadowBlackMedium.opacity(0.3), radius: 4, x: 0, y: 4)
        
        // Light shadow
        RoundedRectangle(cornerRadius: 56)
            .fill(Color.clear)
            .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 2)
        
        // Subtle lifted shadow (CSS: box-shadow: 0px 3px 12px rgba(0,0,0,0.08))
        RoundedRectangle(cornerRadius: 56)
            .fill(Color.clear)
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 3)
    }
    
    @ViewBuilder
    private func datePickerContainer(geo: GeometryProxy) -> some View {
        VStack(spacing: geo.size.height * 0.02) {
            DatePicker(
                "Birth Date",
                selection: $selectedDate,
                in: ...maxDate,
                displayedComponents: .date
            )
            #if os(iOS)
            .datePickerStyle(WheelDatePickerStyle())
            #else
            .datePickerStyle(GraphicalDatePickerStyle())
            #endif
            .labelsHidden()
            .accentColor(AppConstants.Colors.primary)
            .colorScheme(.light)
                                    .font(AppConstants.Fonts.heading)
            .onChange(of: selectedDate) { _, newValue in
                birthDate = newValue
                hasValidDate = newValue != Date()
                #if os(iOS)
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                #endif
            }
            .overlay(
                // Subtle divider lines between Month/Day/Year
                HStack(spacing: 0) {
                    Spacer()
                    Rectangle()
                        .fill(Color(hex: "#E2D5C0").opacity(0.3))
                        .frame(width: 0.5, height: geo.size.height * 0.06)
                    Spacer()
                    Rectangle()
                        .fill(Color(hex: "#E2D5C0").opacity(0.3))
                        .frame(width: 0.5, height: geo.size.height * 0.06)
                    Spacer()
                }
                .padding(.horizontal, geo.size.width * 0.22)
            )
        }
        .padding(.vertical, geo.size.height * 0.04)
        .frame(minHeight: geo.size.height * 0.25)
        .background(datePickerBackground())
        .overlay(datePickerOverlays())
        .overlay(datePickerShadows())
        .opacity(showRestOfUI ? 1 : 0)
        .animation(.easeInOut(duration: 0.7).delay(0.1), value: showRestOfUI)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppConstants.Colors.backgroundGradient
                    .ignoresSafeArea()

                VStack(alignment: .center, spacing: 0) {
                    // Animated header
                    HStack(spacing: 0) {
                        ForEach(0..<words.count, id: \.self) { idx in
                            Text(words[idx].text)
                                .font(words[idx].font)
                                .fontWeight(.semibold)
                                .opacity(wordVisibility[idx] ? 1 : 0)
                                .animation(AppConstants.Animation.standard, value: wordVisibility[idx])
                        }
                    }
                    .frame(maxWidth: geo.size.width * 0.86, alignment: .leading)
                    .padding(.top, geo.size.height * 0.065)
                    .padding(.bottom, geo.size.height * 0.025) // Header → Subheader: ~16-20px
                    .padding(.horizontal, geo.size.width * 0.07)
                    
                    // Subheader
                    Text("Your birth date reveals your natural rhythm")
                        .font(AppConstants.Fonts.responsiveBody(geo.size.width))
                        .foregroundColor(Color(hex: "#2A2D34").opacity(0.9))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: geo.size.width * 0.86, alignment: .leading)
                        .lineSpacing(geo.size.width * 0.042 * 0.4)
                        .kerning(0.2)
                        .padding(.bottom, geo.size.height * 0.045) // Subheader → Picker: ~24-32px
                        .padding(.horizontal, geo.size.width * 0.07)
                        .opacity(showRestOfUI ? 1 : 0)
                        .animation(.easeInOut(duration: 0.7), value: showRestOfUI)

                    // Date picker and celestial ring
                    ZStack {
                        // Enhanced soft radial background highlight
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#E2D5C0").opacity(0.22),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 40,
                            endRadius: 220
                        )
                        .frame(height: geo.size.height * 0.48)
                        .padding(.horizontal, geo.size.width * 0.03)
                        
                        // Faint gold celestial ring
                        Circle()
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#FFD700").opacity(0.3),
                                        Color(hex: "#FFD700").opacity(0.1),
                                        Color(hex: "#FFD700").opacity(0.05),
                                        Color.clear
                                    ]),
                                    center: .center
                                ),
                                lineWidth: 2
                            )
                            .frame(width: geo.size.width * 0.8, height: geo.size.width * 0.8)
                            .blur(radius: 1)
                        
                        // Subtle radial gradient background
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#F8F8F8").opacity(0.6),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 50,
                            endRadius: 150
                        )
                        .frame(height: geo.size.height * 0.35)
                        .padding(.horizontal, geo.size.width * 0.07)

                        datePickerContainer(geo: geo)
                    }
                    .padding(.horizontal, geo.size.width * 0.07)
                    .padding(.bottom, geo.size.height * 0.08) // Increased from 0.06 to 0.08 (~48pt)

                    Spacer()

                    // Next button - phases in with the rest of the UI
                    PrimaryButton(isUpdatingProfile ? "Updating..." : "Continue", isEnabled: hasValidDate && !isUpdatingProfile) {
                        updateProfileWithBirthDate()
                    }
                    .padding(.horizontal, geo.size.width * 0.07)
                    .padding(.bottom, geo.size.height * 0.10) // Increased bottom padding for more space below button
                    .opacity(showRestOfUI ? 1 : 0)
                    .animation(.easeInOut(duration: 0.7).delay(0.2), value: showRestOfUI)
                }
                .onAppear {
                    animateWords()
                    // Phase in the rest of the UI after the '?' header character animates in
                    let headerAnimationDelay = Double(wordVisibility.count - 1) * 0.22 + 0.3
                    DispatchQueue.main.asyncAfter(deadline: .now() + headerAnimationDelay) {
                        withAnimation { showRestOfUI = true }
                    }
                    #if os(iOS)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        let utterance = AVSpeechUtterance(string: "When were you born? This helps us personalize your health recommendations.")
                        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                        utterance.rate = 0.45
                        AVSpeechSynthesizer().speak(utterance)
                    }
                    #endif
                }
            }
        }
    }
    
    private func animateWords() {
        for i in 0..<wordVisibility.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.16) {
                withAnimation(.easeOut(duration: 0.24)) { wordVisibility[i] = true }
            }
        }
    }
    
    private func updateProfileWithBirthDate() {
        _updateProfileWithBirthDate()
    }
}

#if canImport(Firebase)
extension BirthDatePage {
    private func _updateProfileWithBirthDate() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No user signed in")
            return
        }
        
        isUpdatingProfile = true
        
        Task {
            do {
                // Update the profile with birth date
                let updateData: [String: Any] = [
                    "birthDate": selectedDate,
                    "updatedAt": FieldValue.serverTimestamp()
                ]
                
                try await Firestore.firestore().collection("userProfiles").document(userId).updateData(updateData)
                
                await MainActor.run {
                    isUpdatingProfile = false
                    currentPage = 8 // Go to transition page
                }
            } catch {
                await MainActor.run {
                    isUpdatingProfile = false
                    print("❌ Error updating profile with birth date: \(error)")
                }
            }
        }
    }
}
#else
extension BirthDatePage {
    private func _updateProfileWithBirthDate() {
        // Fallback: just advance the page
        isUpdatingProfile = false
        currentPage = 8
    }
}
#endif

struct BirthDatePage_Previews: PreviewProvider {
    @State static var dummyPage = 6
    static var previews: some View {
        BirthDatePage(currentPage: $dummyPage)
    }
} 
