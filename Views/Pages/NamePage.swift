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

struct NamePage: View {
    @Binding var currentPage: Int
    @AppStorage("userName") private var userName: String = ""
    @StateObject private var profileService = UserProfileService.shared
    @State private var isCreatingProfile = false

    private let words: [(text: String, font: Font)] = [
        ("Let's", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("begin", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("with", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("your", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("name", AppConstants.Fonts.heading),
        ("...", AppConstants.Fonts.heading)
    ]

    @State private var wordVisibility = Array(repeating: false, count: 10)
    @State private var showExplanatoryText = false
    @State private var showUI = false
    @State private var isFieldFocused = false
    @State private var isTyping = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppConstants.Colors.backgroundGradient
                    .ignoresSafeArea()

                VStack(alignment: .leading) {
                    // Animated header
                    VStack(alignment: .leading, spacing: 0) {
                        // First line: "Let's begin with your"
                        HStack(spacing: 0) {
                            ForEach(0..<8, id: \.self) { idx in
                                Text(words[idx].text)
                                    .font(words[idx].font)
                                    .fontWeight(.semibold)
                                    .opacity(wordVisibility[idx] ? 1 : 0)
                                    .animation(AppConstants.Animation.standard, value: wordVisibility[idx])
                            }
                        }
                        
                        // Second line: "name."
                    HStack(spacing: 0) {
                            ForEach(8..<words.count, id: \.self) { idx in
                            Text(words[idx].text)
                                .font(words[idx].font)
                                .fontWeight(.semibold)
                                .opacity(wordVisibility[idx] ? 1 : 0)
                                .animation(AppConstants.Animation.standard, value: wordVisibility[idx])
                            }
                        }
                    }
                    .frame(maxWidth: geo.size.width * 0.86, alignment: .leading)
                    .padding(.top, geo.size.height * 0.065)
                    .padding(.bottom, geo.size.height * 0.025)
                    .padding(.horizontal, geo.size.width * 0.07)
                    
                    // Explanatory text under header
                    Text("This will help us personalize your wellness journey.")
                        .font(.custom("PlayfairDisplay-Regular", size: geo.size.width * 0.042))
                        .foregroundColor(Color(hex: "#2A2D34").opacity(0.9))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: geo.size.width * 0.86, alignment: .leading)
                        .lineSpacing(geo.size.width * 0.042 * 0.4)
                        .kerning(0.2)
                        .padding(.bottom, geo.size.height * 0.045)
                        .padding(.horizontal, geo.size.width * 0.07)
                        .opacity(showUI ? 1 : 0)
                        .animation(.easeInOut(duration: 1.0), value: showUI)

                    // Name input
                    ZStack(alignment: .leading) {
                        if userName.isEmpty {
                            Text("Enter your name")
                                .font(.custom("PlayfairDisplay-Regular", size: 18))
                                .foregroundColor(AppConstants.Colors.textSecondary.opacity(0.6))
                                .offset(y: isTyping ? -20 : 0)
                                .scaleEffect(isTyping ? 0.8 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: isTyping)
                                .padding(.horizontal, 16)
                        }
                        TextField("", text: $userName)
                            .font(.custom("PlayfairDisplay-Regular", size: 18))
                            .foregroundColor(AppConstants.Colors.textPrimary)
                            #if os(iOS)
                            .textInputAutocapitalization(.words)
                            #endif
                            .frame(height: 56)
                            .padding(.horizontal, 16)
                            .background(Color.clear)
                            .onTapGesture {
                                #if os(iOS)
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                #endif
                                isFieldFocused = true
                                if userName.isEmpty {
                                    isTyping = true
                                }
                            }
                            .onChange(of: userName, initial: false) { _, newValue in
                                isTyping = !newValue.isEmpty
                            }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.medium)
                            .fill(AppConstants.Colors.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.medium)
                            .stroke(borderColor, lineWidth: borderWidth)
                            .animation(.easeInOut(duration: 0.3), value: borderColor)
                            .animation(.easeInOut(duration: 0.2), value: borderWidth)
                    )
                    .shadow(
                        color: isFieldFocused ? AppConstants.Colors.primary.opacity(0.4) : AppConstants.Colors.shadowBlackMedium,
                        radius: isFieldFocused ? 6 : 1,
                        x: 0,
                        y: isFieldFocused ? 3 : 1
                    )
                    .animation(.easeInOut(duration: 0.3), value: isFieldFocused)
                    .padding(.horizontal, geo.size.width * 0.07)
                    .padding(.bottom, geo.size.height * 0.06)
                    .opacity(showUI ? 1 : 0)
                    .offset(y: showUI ? 0 : 20)
                    .animation(.easeInOut(duration: 1.0), value: showUI)

                    // Next button - always present, fades in after header animation
                    let isEnabled = !isCreatingProfile && !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    PrimaryButton(
                        isCreatingProfile ? "Creating Profile..." : "Let's begin",
                        isEnabled: isEnabled,
                        isLoading: isCreatingProfile
                    ) {
                        createUserProfile()
                    }
                    .padding(.horizontal, geo.size.width * 0.07)
                    .padding(.bottom, geo.size.height * 0.10)
                    .frame(minHeight: 56)
                    .scaleEffect(showUI ? (isEnabled ? 1.03 : 0.96) : 0.96)
                    .offset(y: showUI && isEnabled ? -4 : 0)
                    .opacity(showUI ? 1 : 0)
                    .animation(.easeInOut(duration: 0.32), value: isEnabled)
                    .animation(.easeInOut(duration: 0.7).delay(0.2), value: showUI)

                    Spacer(minLength: geo.size.height * 0.08)
                }
                .onAppear {
                    animateWords()
                    
                    #if os(iOS)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        let utterance = AVSpeechUtterance(string: "Just so we're not strangers - what is your name?")
                        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                        utterance.rate = 0.45

                        AVSpeechSynthesizer().speak(utterance)
                    }
                    #endif
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var borderColor: Color {
        if isFieldFocused {
            return AppConstants.Colors.primary
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private var borderWidth: CGFloat {
        if isFieldFocused {
            return 2
        } else {
            return 1
        }
    }
    
    private func animateWords() {
        for i in 0..<wordVisibility.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation { wordVisibility[i] = true }
                
                // Trigger UI animation after "name." (last word) appears
                if i == wordVisibility.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            showUI = true
                        }
                    }
                }
            }
        }
    }
    
    private func createUserProfile() {
        _createUserProfile()
    }
}

#if canImport(Firebase)
extension NamePage {
    private func _createUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No user signed in")
            return
        }
        
        isCreatingProfile = true
        
        Task {
            do {
                let phoneNumber = Auth.auth().currentUser?.phoneNumber ?? ""
                try await profileService.createInitialProfile(
                    userId: userId,
                    name: userName.trimmingCharacters(in: .whitespacesAndNewlines),
                    phoneNumber: phoneNumber
                )
                
                await MainActor.run {
                    isCreatingProfile = false
                    currentPage = 7 // Go to birth date page
                }
            } catch {
                await MainActor.run {
                    isCreatingProfile = false
                    print("❌ Error creating profile: \(error)")
                }
            }
        }
    }
}
#else
extension NamePage {
    private func _createUserProfile() {
        isCreatingProfile = true
        
        Task {
            // Simulate profile creation for non-Firebase environments
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            await MainActor.run {
                isCreatingProfile = false
                currentPage = 7 // Go to birth date page
            }
        }
    }
}
#endif

struct NamePage_Previews: PreviewProvider {
    @State static var dummyPage = 6
    static var previews: some View {
        NamePage(currentPage: $dummyPage)
    }
}
