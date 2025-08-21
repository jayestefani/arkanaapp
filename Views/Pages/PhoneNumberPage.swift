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

struct PhoneNumberPage: View {
    @Binding var currentPage: Int
    @AppStorage("userPhoneNumber") private var phoneNumber: String = ""
    @State private var phoneInput: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSendingCode = false
    @State private var isFieldFocused = false
    @State private var hasSubmitted = false
    @State private var isTyping = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var dotAnimationOffset: CGFloat = 0
    @State private var showSuccess = false
    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkOpacity: Double = 0
    @State private var shakeOffset: CGFloat = 0
    
    // Use real phone verification service
    @StateObject private var verificationService = PhoneVerificationService.shared

    private let words: [(text: String, font: Font)] = [
        ("What", AppConstants.Fonts.headingSC),
        (" ",  AppConstants.Fonts.heading),
        ("is", AppConstants.Fonts.headingSC),
        (" ",  AppConstants.Fonts.heading),
        ("your", AppConstants.Fonts.headingSC),
        (" ",  AppConstants.Fonts.heading),
        ("number", AppConstants.Fonts.headingSC),
        ("?", AppConstants.Fonts.headingSC)
    ]

    @State private var wordVisibility = Array(repeating: false, count: 8)

    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppConstants.Colors.backgroundGradient
                    .ignoresSafeArea()

                VStack(alignment: .leading) {
                    headerSection(geo: geo)
                    subtextSection(geo: geo)
                    phoneInputSection(geo: geo)
                    errorSection(geo: geo)
                    tosSection(geo: geo)
                    continueButtonSection(geo: geo)
                    Spacer()
                }
                .onAppear {
                    animateWords()
                    phoneInput = formatPhoneNumber(phoneNumber)
                    #if canImport(Firebase)
                    print("🔍 DEBUG: \(verificationService.testFirebaseConfiguration())")
                    #else
                    print("🔍 DEBUG: Firebase not available")
                    #endif
                    #if os(iOS)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        let utterance = AVSpeechUtterance(string: "To secure your account, please enter your phone number.")
                        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                        utterance.rate = 0.45
                        let synthesizer = AVSpeechSynthesizer()
                        synthesizer.speak(utterance)
                    }
                    #endif
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    @ViewBuilder
    private func headerSection(geo: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<words.count, id: \.self) { idx in
                Text(words[idx].text)
                    .font(words[idx].font)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: geo.size.width * 0.86, alignment: .leading)
        .padding(.top, geo.size.height * 0.08)
        .padding(.bottom, geo.size.height * 0.02)
        .padding(.horizontal, geo.size.width * 0.07)
    }

    @ViewBuilder
    private func subtextSection(geo: GeometryProxy) -> some View {
        Text("Sending you a verification code to secure your account")
            .font(.custom("PlayfairDisplay-Regular", size: geo.size.width * 0.042))
            .foregroundColor(AppConstants.Colors.textSecondary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: geo.size.width * 0.86, alignment: .leading)
            .padding(.bottom, geo.size.height * 0.035)
            .padding(.horizontal, geo.size.width * 0.07)
    }

    @ViewBuilder
    private func phoneInputSection(geo: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            Text("+1")
                .font(.custom("PlayfairDisplay-Regular", size: 18))
                .foregroundColor(isFieldFocused ? AppConstants.Colors.primary : AppConstants.Colors.primary.opacity(0.6))
                .frame(width: 60, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isFieldFocused ? AppConstants.Colors.primary.opacity(0.15) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(
                                    isFieldFocused ? AppConstants.Colors.primary.opacity(0.3) : Color.clear,
                                    lineWidth: 1
                                )
                        )
                )
                .scaleEffect(pulseScale)
                .animation(.easeInOut(duration: 0.3), value: isFieldFocused)
                .overlay(
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 1)
                        .padding(.vertical, 8),
                    alignment: .trailing
                )
            ZStack(alignment: .leading) {
                if phoneInput.isEmpty {
                    Text("phone number")
                        .font(.custom("PlayfairDisplay-Regular", size: 18))
                        .foregroundColor(AppConstants.Colors.textSecondary.opacity(0.6))
                        .offset(y: isTyping ? -20 : 0)
                        .scaleEffect(isTyping ? 0.8 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isTyping)
                        .padding(.horizontal, 16)
                }
                TextField("", text: $phoneInput)
                    .font(.custom("PlayfairDisplay-Regular", size: 18))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                    #if os(iOS)
                    .keyboardType(.phonePad)
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
                        if phoneInput.isEmpty {
                            isTyping = true
                        }
                        startPulseAnimation()
                    }
                    .onTapGesture {
                        isFieldFocused = false
                    }
                    .onChange(of: phoneInput, initial: false) { _, newValue in
                        let digits = newValue.filter { $0.isWholeNumber }
                        let cleaned = String(digits.prefix(10))
                        if cleaned.count < phoneNumber.count {
                            phoneNumber = cleaned
                            phoneInput = newValue
                        } else {
                            phoneNumber = cleaned
                            phoneInput = formatPhoneNumberSmooth(cleaned)
                        }
                        isTyping = !newValue.isEmpty
                    }
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
        .offset(x: shakeOffset)
        .animation(.easeInOut(duration: 0.3), value: isFieldFocused)
        .animation(.easeInOut(duration: 0.2), value: hasSubmitted)
        .padding(.horizontal, geo.size.width * 0.07)
        .padding(.bottom, geo.size.height * 0.045) // 4.5% of screen height
    }

    @ViewBuilder
    private func errorSection(geo: GeometryProxy) -> some View {
        if showError {
            Text(errorMessage)
                .font(AppConstants.Fonts.responsiveBody(geo.size.width))
                .foregroundColor(AppConstants.Colors.error)
                .padding(.horizontal, geo.size.width * 0.07)
                .padding(.bottom, geo.size.height * 0.01)
        }
    }

    @ViewBuilder
    private func tosSection(geo: GeometryProxy) -> some View {
        if #available(iOS 15.0, *) {
            Text("By clicking continue, you agree to our [Terms of Service](https://yourdomain.com/terms) and [Privacy Policy](https://yourdomain.com/privacy).")
                .font(AppConstants.Fonts.responsiveBody(geo.size.width))
                .foregroundColor(AppConstants.Colors.textPrimary.opacity(0.7))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, geo.size.width * 0.07)
                .padding(.bottom, geo.size.height * 0.065) // 6.5% of screen height
                .tint(AppConstants.Colors.primary)
        }
    }

    @ViewBuilder
    private func continueButtonSection(geo: GeometryProxy) -> some View {
        PrimaryButton(
            showSuccess ? "Code Sent!" : (isSendingCode ? "Sending Code" : "Continue"),
            isEnabled: isValidPhoneNumber && !isSendingCode && !showSuccess,
            isLoading: isSendingCode,
            isSuccess: showSuccess
        ) {
            sendVerificationCode()
        }
        .padding(.horizontal, geo.size.width * 0.07)
    }

    // MARK: - Computed Properties
    private var isValidPhoneNumber: Bool {
        let digits = phoneNumber.filter { $0.isNumber }
        return digits.count == 10
    }
    
    private var borderColor: Color {
        if hasSubmitted && !isValidPhoneNumber {
            return AppConstants.Colors.error
        } else if isFieldFocused {
            return AppConstants.Colors.primary
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private var borderWidth: CGFloat {
        if hasSubmitted && !isValidPhoneNumber || isFieldFocused {
            return 2
        } else {
            return 1
        }
    }

    // MARK: - Methods
    private func animateWords() {
        for i in 0..<wordVisibility.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.22) {
                withAnimation { wordVisibility[i] = true }
            }
        }
    }
    
    private func startPulseAnimation() {
        // Reset to ensure clean animation
        pulseScale = 1.0
        
        // Scale up with a more noticeable effect
        withAnimation(.easeInOut(duration: 0.2)) {
            pulseScale = 1.15
        }
        
        // Scale back down
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.2)) {
                pulseScale = 1.0
            }
        }
    }
    
    private func showSuccessAnimation() {
        // Reset animation states
        checkmarkScale = 0
        checkmarkOpacity = 0
        
        // Show success state
        showSuccess = true
        
        // Animate checkmark appearance
        withAnimation(.easeInOut(duration: 0.2)) {
            checkmarkOpacity = 1.0
        }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1)) {
            checkmarkScale = 1.0
        }
        
        // Navigate to next page after success animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            currentPage = 5
        }
    }
    
    private func shakeAnimation() {
        // Reset shake offset
        shakeOffset = 0
        
        // Shake sequence: left, right, left, right, center
        let shakeSequence: [CGFloat] = [-10, 10, -8, 8, -4, 4, 0]
        
        for (index, offset) in shakeSequence.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                withAnimation(.easeInOut(duration: 0.05)) {
                    shakeOffset = offset
                }
            }
        }
    }

    private func formatPhoneNumber(_ number: String) -> String {
        let digits = number.filter { $0.isNumber }
        var result = ""

        if digits.count >= 1 {
            result += "(" + String(digits.prefix(3))
        }
        if digits.count >= 3 {
            result += ") " + String(digits.dropFirst(3).prefix(3))
        }
        if digits.count >= 6 {
            result += "-" + String(digits.dropFirst(6).prefix(4))
        }

        return result
    }
    
    private func formatPhoneNumberSmooth(_ number: String) -> String {
        let digits = number.filter { $0.isNumber }
        
        switch digits.count {
        case 0:
            return ""
        case 1...3:
            return "(" + digits
        case 4...6:
            let areaCode = String(digits.prefix(3))
            let prefix = String(digits.dropFirst(3))
            return "(\(areaCode)) \(prefix)"
        case 7...10:
            let areaCode = String(digits.prefix(3))
            let prefix = String(digits.dropFirst(3).prefix(3))
            let lineNumber = String(digits.dropFirst(6))
            return "(\(areaCode)) \(prefix)-\(lineNumber)"
        default:
            // Limit to 10 digits
            let limitedDigits = String(digits.prefix(10))
            return formatPhoneNumberSmooth(limitedDigits)
        }
    }
    
    private func sendVerificationCode() {
        isSendingCode = true
        print("🔍 DEBUG: sendVerificationCode() called")
        print("🔍 DEBUG: phoneNumber = '\(phoneNumber)'")
        print("🔍 DEBUG: isValidPhoneNumber = \(isValidPhoneNumber)")
        
        hasSubmitted = true
        
        guard isValidPhoneNumber else {
            print("🔍 DEBUG: Phone number validation failed")
            isSendingCode = false
            showError = true
            errorMessage = "Please enter a valid 10-digit phone number"
            shakeAnimation()
            return
        }
        
        print("🔍 DEBUG: Starting verification process...")
        
        Task {
            do {
                print("🔍 DEBUG: Calling verificationService.sendVerificationCode...")
                let formattedPhone = "+1\(phoneNumber.filter { $0.isNumber })"
                print("🔍 DEBUG: Formatted phone number: \(formattedPhone)")
                
                #if canImport(Firebase)
                print("DEBUG: About to call sendVerificationCode with: \(formattedPhone)")
                print("DEBUG: FirebaseApp.app(): \(String(describing: FirebaseApp.app()))")
                print("DEBUG: Is Firebase configured? \(FirebaseApp.app() != nil)")
                print("DEBUG: formattedPhone type: \(type(of: formattedPhone))")
                // Check if Firebase is configured
                guard FirebaseApp.app() != nil else {
                    throw NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase not configured"])
                }
                
                try await verificationService.sendVerificationCode(to: formattedPhone)
                #else
                // Fallback for when Firebase is not available
                print("Firebase not available - using fallback")
                // Simulate successful verification
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
                #endif
                
                print("🔍 DEBUG: Verification successful")
                
                await MainActor.run {
                    isSendingCode = false
                    showSuccessAnimation()
                }
            } catch {
                print("🔍 DEBUG: Verification failed with error: \(error)")
                await MainActor.run {
                    isSendingCode = false
                    #if canImport(Firebase)
                    // More specific error handling
                    if let authError = error as? AuthErrorCode {
                        switch authError.code {
                        case .invalidPhoneNumber:
                            errorMessage = "Invalid phone number format. Please check and try again."
                        case .quotaExceeded:
                            errorMessage = "Too many attempts. Please try again later."
                        case .networkError:
                            errorMessage = "Network error. Please check your connection and try again."
                        default:
                            errorMessage = "Verification failed. Please try again."
                        }
                    } else {
                        errorMessage = error.localizedDescription
                    }
                    #else
                    errorMessage = "Verification service not available"
                    #endif
                    showError = true
                }
            }
        }
    }
}

struct PhoneNumberPage_Previews: PreviewProvider {
    @State static var dummyPage = 4
    static var previews: some View {
        PhoneNumberPage(currentPage: $dummyPage)
    }
}
