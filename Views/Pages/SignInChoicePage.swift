import SwiftUI
import AVFoundation

struct SignInChoicePage: View {
    @Binding var currentPage: Int
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppConstants.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                VStack {
                    Text("ARKANA")
                        .font(AppConstants.Fonts.responsiveTitle(geo.size.width))
                        .padding(.top, geo.safeAreaInsets.top - geo.size.height * 0.038)
                    
                    Spacer()
                    
                    // Buttons at the bottom
                    VStack(spacing: AppConstants.Spacing.responsiveMedium(geo.size.height)) {
                        PrimaryButton("New user") {
                            currentPage += 1
                        }
                        
                        SecondaryButton("Existing user →") {
                            currentPage = 4
                        }
                    }
                    .padding(.horizontal, geo.size.width * 0.07)
                    .padding(.bottom, geo.safeAreaInsets.bottom)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .onAppear {
            print("SignInChoicePage appeared")
            
            #if os(iOS)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let utterance = AVSpeechUtterance(string: "Welcome to Arkana. The world's first operating system for Ancient Medicine. Before we begin, please create a new account or sign into an existing one.")
                utterance.rate = 0.45
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
            }
            #endif
        }
    }
}

struct SignInChoicePage_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var dummyPage = 3
        
        var body: some View {
            SignInChoicePage(currentPage: $dummyPage)
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
