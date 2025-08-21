import SwiftUI

struct StressSurveyPage: View {
    @Binding var currentPage: Int
    @State private var selectedIndex: Int = 2
    @State private var wordVisibility = Array(repeating: false, count: 10)
    @State private var buttonVisible = false
    
    private let words: [(text: String, font: Font)] = [
        ("How", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("stressed", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("do", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("you", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("feel", AppConstants.Fonts.heading),
        ("?", AppConstants.Fonts.heading)
    ]

    let stressOptions: [(emoji: String, primaryLabel: String, subtitle: String, color: Color)] = [
        ("🌿", "Low Stress", "You feel calm and relaxed most days", AppConstants.Colors.secondary), // Dark Green for low
        ("🍃", "Mild Stress", "Occasional stress but manageable", AppConstants.Colors.accent), // Brand Green for mild
        ("🍂", "Moderate Stress", "Regular stress that affects daily life", Color(hex: "#FFD93D")), // Yellow for middle
        ("🌪️", "High Stress", "Frequent stress and tension", Color(hex: "#D45A5A")), // Lighter Red for high
        ("🔥", "Overwhelming Stress", "Constant stress affecting health", AppConstants.Colors.primary) // Brand Red for overwhelming
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppConstants.Colors.secondaryBackgroundGradient
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 0) {
                        // First line: "How stressed do you"
                        HStack(spacing: 0) {
                            ForEach(0..<8, id: \.self) { idx in
                                Text(words[idx].text)
                                    .font(words[idx].font)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppConstants.Colors.textPrimary)
                            }
                        }
                        // Second line: "feel?"
                        HStack(spacing: 0) {
                            ForEach(8..<words.count, id: \.self) { idx in
                                Text(words[idx].text)
                                    .font(words[idx].font)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppConstants.Colors.textPrimary)
                            }
                        }
                    }
                    .frame(maxWidth: geo.size.width * 0.86, alignment: .leading)
                    .padding(.top, geo.size.height * 0.065)
                    .padding(.bottom, geo.size.height * 0.03)
                    .padding(.horizontal, geo.size.width * 0.07)

                    // Stress Options
                    VStack(spacing: AppConstants.Spacing.responsiveMedium(geo.size.height)) {
                        ForEach(0..<stressOptions.count, id: \.self) { index in
                            let option = stressOptions[index]
                            let isSelected = selectedIndex == index
                            
                            Button(action: {
                                withAnimation(AppConstants.Animation.standard) {
                                    selectedIndex = index
                                }
                            }) {
                                HStack(alignment: .top, spacing: 12) {
                                    Text(option.emoji)
                                        .font(.title2)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(option.primaryLabel)
                                            .font(.custom("PlayfairDisplay-Regular", size: 18))
                                            .foregroundColor(AppConstants.Colors.textPrimary)
                                            .fontWeight(.medium)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text(option.subtitle)
                                            .font(.custom("PlayfairDisplay-Regular", size: 16))
                                            .foregroundColor(AppConstants.Colors.textSecondary)
                                            .lineLimit(2)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(stressOptionBackground(isSelected: isSelected, color: option.color))
                                .cornerRadius(30)
                                .scaleEffect(isSelected ? 1.02 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: isSelected)
                            }
                        }
                    }
                    .padding(.horizontal, geo.size.width * 0.07)

                    Spacer()

                    // Next Button
                    PrimaryButton("Next", isEnabled: selectedIndex != 2) {
                        currentPage += 1
                    }
                    .opacity(buttonVisible ? 1 : 0)
                    .animation(AppConstants.Animation.standard, value: buttonVisible)
                    .padding(.horizontal, geo.size.width * 0.07)
                    .padding(.bottom, geo.size.height * 0.03)
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                .onAppear {
                    selectedIndex = 2
                    buttonVisible = false
                    animateWords()
                }
            }
        }
    }
    
    private func stressOptionBackground(isSelected: Bool, color: Color) -> some View {
        Group {
            if isSelected {
                color.opacity(0.2)
            } else {
                AppConstants.Colors.unselectedGradient
            }
        }
    }
    
    private func animateWords() {
        for i in 0..<wordVisibility.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.22) {
                withAnimation { wordVisibility[i] = true }
            }
        }
        
        // After header animation completes, fade in the button
        let headerDuration = Double(wordVisibility.count) * 0.22
        DispatchQueue.main.asyncAfter(deadline: .now() + headerDuration + 0.6) {
            withAnimation { buttonVisible = true }
        }
    }
}

struct StressSurveyPage_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var page = 14
        var body: some View {
            StressSurveyPage(currentPage: $page)
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
} 
