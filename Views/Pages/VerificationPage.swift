import SwiftUI
import AVFoundation

// Check if Firebase is available
#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

// MARK: - Code Input View
struct SecurityCodeInput: View {
    @Binding var code: String
    let length: Int
    let geo: GeometryProxy
    @FocusState private var isFocused: Bool
    @State private var codeArray: [String]

    init(code: Binding<String>, length: Int, geo: GeometryProxy) {
        self._code = code
        self.length = length
        self.geo = geo
        self._codeArray = State(initialValue: Array(repeating: "", count: length))
    }

    var body: some View {
        VStack {
            TextField("", text: Binding(
                get: { code },
                set: { newValue in
                    let filtered = newValue.filter { $0.isWholeNumber }
                    let capped = String(filtered.prefix(length))
                    code = capped
                    for i in 0..<length {
                        codeArray[i] = i < capped.count ? String(capped[capped.index(capped.startIndex, offsetBy: i)]) : ""
                    }
                }
            ))
            #if os(iOS)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            #endif
            .focused($isFocused)
            .frame(width: 0, height: 0)
            .opacity(0.01)
            .disabled(false)
            .onAppear {
                #if os(iOS)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    let utterance = AVSpeechUtterance(string: "We sent you a code. If you didn't receive it, choose resend code to get a new one.")
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                    utterance.rate = 0.45
                    AVSpeechSynthesizer().speak(utterance)
                }
                #endif
            }

            HStack(spacing: 13) {
                ForEach(0..<length, id: \.self) { i in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppConstants.Colors.shadowBorder, lineWidth: 2)
                            .frame(width: 48, height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppConstants.Colors.white)
                                    .shadow(color: AppConstants.Colors.shadowBlackLight, radius: 2, x: 0, y: 2)
                            )
                        Text(codeArray[i])
                            .font(AppConstants.Fonts.responsiveHeading(geo.size.width))
                            .foregroundColor(AppConstants.Colors.textPrimary)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                self.isFocused = true
            }
        }
        .onChange(of: code) {
            let capped = String(code.filter { $0.isWholeNumber }.prefix(length))
            for i in 0..<length {
                codeArray[i] = i < capped.count ? String(capped[capped.index(capped.startIndex, offsetBy: i)]) : ""
            }
        }
    }
}

// MARK: - Verification Page
struct VerificationPage: View {
    @Binding var currentPage: Int
    @State private var code: String = ""
    @State private var isCodeValid = true
    @State private var showResend = false
    @State private var hasSentInitialCode = false
    @State private var showError = false
    @State private var errorMessage = ""
    private let words: [(text: String, font: Font)] = [
        ("Sending", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("you", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("an", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("SMS", AppConstants.Fonts.heading)
    ]
    @State private var wordVisibility = Array(repeating: false, count: 7)

    @AppStorage("userPhoneNumber") private var phoneNumber: String = ""
    
    // Use phone verification service
    @StateObject private var verificationService = PhoneVerificationService.shared

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                AppConstants.Colors.backgroundGradient
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // Header (word-by-word fade-in, like NamePage)
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
                    .padding(.bottom, geo.size.height * 0.025)
                    .padding(.horizontal, geo.size.width * 0.07)

                    (Text("Enter security code sent to ")
                        .font(.custom("PlayfairDisplay-Regular", size: geo.size.width * 0.042))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                     + Text(formatPhoneNumber(phoneNumber))
                        .font(.custom("PlayfairDisplay-Regular", size: geo.size.width * 0.042))
                        .fontWeight(.bold)
                        .foregroundColor(AppConstants.Colors.textSecondary))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: geo.size.width * 0.86, alignment: .leading)
                        .padding(.bottom, geo.size.height * 0.035)
                        .padding(.horizontal, geo.size.width * 0.07)



                    HStack {
                        Spacer()
                        SecurityCodeInput(code: $code, length: 6, geo: geo)
                            .padding(.vertical, geo.size.height * 0.03)
                        Spacer()
                    }

                    if !isCodeValid {
                        Text("Invalid code. Try again.")
                            .foregroundColor(AppConstants.Colors.error)
                            .font(AppConstants.Fonts.responsiveBody(geo.size.width))
                            .padding(.horizontal, geo.size.width * 0.07)
                    }

                    PrimaryButton(verificationService.isLoading ? "Verifying..." : "Confirm") {
                        verifyCode()
                    }
                    .disabled(verificationService.isLoading)
                    .padding(.horizontal, geo.size.width * 0.07)
                    .padding(.top, geo.size.height * 0.03)

                    HStack {
                        Spacer()
                        Button(action: {
                            Task { await resendCode() }
                        }) {
                            Text(verificationService.isLoading ? "Sending..." : "resend code")
                                .font(.custom("NotoSans", size: 14))
                                .foregroundColor(AppConstants.Colors.primary)
                                .padding(.top, geo.size.height * 0.02)
                        }
                        .disabled(verificationService.isLoading)
                        Spacer()
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .onAppear {
                    animateWords()
                }
            }
            .task {
                if !hasSentInitialCode {
                    hasSentInitialCode = true
                    await resendCode()
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Logic
    func verifyCode() {
        guard code.count == 6 else {
            isCodeValid = false
            return
        }
        
        Task {
            do {
                try await verificationService.verifyCode(code)
                
                await MainActor.run {
                    // User is now signed in with Firebase
                    print("✅ User signed in successfully")
                    currentPage = 6 // Go to NamePage (page 6)
                }
            } catch {
                await MainActor.run {
                    // Check if this is development mode success
                    if let nsError = error as NSError?, nsError.code == 999 && nsError.domain == "PhoneVerification" {
                        print("✅ Development mode verification successful")
                        currentPage = 6 // Go to NamePage (page 6)
                        return
                    }
                    
                    isCodeValid = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    func resendCode() async {
        do {
            try await verificationService.sendVerificationCode(to: phoneNumber)
            await MainActor.run {
                showResend = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func animateWords() {
        for i in 0..<wordVisibility.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation { wordVisibility[i] = true }
            }
        }
    }

    private func formatPhoneNumber(_ number: String) -> String {
        let digits = number.filter { $0.isNumber }
        guard digits.count == 10 else { return number }
        let area = digits.prefix(3)
        let mid = digits.dropFirst(3).prefix(3)
        let last = digits.suffix(4)
        return "(\(area)) \(mid)-\(last)"
    }
}

// MARK: - Preview
struct VerificationPage_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var dummyPage = 5
        var body: some View {
            VerificationPage(currentPage: $dummyPage)
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
