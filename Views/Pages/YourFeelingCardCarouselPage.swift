import SwiftUI

struct YourFeelingCardCarouselPage: View {
    @Binding var currentPage: Int
    @State private var selectedOptions: Set<Int> = []
    @State private var wordVisibility = Array(repeating: false, count: 10)
    
    private let words: [(text: String, font: Font)] = [
        ("How's", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("your", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("mood", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("most", AppConstants.Fonts.heading),
        ("",  AppConstants.Fonts.heading),
        ("days", AppConstants.Fonts.heading),
        ("?", AppConstants.Fonts.heading)
    ]

    let moodOptions: [(label: String, emoji: String)] = [
        ("Calm", "🐉"),
        ("Balanced", "🍵"),
        ("Neutral", "🍚"),
        ("Unsettled", "🌪️"),
        ("Overwhelmed", "🔥")
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppConstants.Colors.secondaryBackgroundGradient
                    .ignoresSafeArea()

                VStack(spacing: AppConstants.Spacing.responsiveLarge(geo.size.height)) {
                    // Main heading
                    VStack(alignment: .leading, spacing: 0) {
                        // First line: "How's your mood most"
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
                        
                        // Second line: "days?"
                        HStack(spacing: 0) {
                            ForEach(7..<words.count, id: \.self) { idx in
                                Text(words[idx].text)
                                    .font(words[idx].font)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppConstants.Colors.textPrimary)
                                    .opacity(wordVisibility[idx] ? 1 : 0)
                                    .animation(AppConstants.Animation.standard, value: wordVisibility[idx])
                            }
                        }
                        // Subheader
                        Text("Choose your typical mood")
                            .font(.custom("PlayfairDisplay-Regular", size: geo.size.width * 0.042))
                            .foregroundColor(AppConstants.Colors.textSecondary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: geo.size.width * 0.86, alignment: .leading)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(geo.size.width * 0.042 * 0.4)
                            .kerning(0.2)
                            .padding(.top, geo.size.height * 0.02)
                            .opacity(wordVisibility.last == true ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.5), value: wordVisibility.last)
                    }
                    .frame(maxWidth: geo.size.width * 0.86, alignment: .leading)
                    .padding(.horizontal, geo.size.width * 0.07)
                    .padding(.top, geo.size.height * 0.065)
                    .padding(.bottom, geo.size.height * 0.015)

                    // Pill Options
                    VStack(spacing: geo.size.height * 0.03) {
                        ForEach(0..<moodOptions.count, id: \.self) { index in
                            let option = moodOptions[index]
                            let isSelected = selectedOptions.contains(index)
                            
                            Button(action: {
                                if isSelected {
                                    selectedOptions.remove(index)
                                } else if selectedOptions.count < 3 {
                                    selectedOptions.insert(index)
                                }
                            }) {
                                HStack {
                                    Text(option.emoji)
                                        .font(.custom("PlayfairDisplay-Regular", size: 16))
                                        .foregroundColor(isSelected ? .white : AppConstants.Colors.textPrimary)
                                        .padding(.trailing, geo.size.width * 0.025)
                                        .scaleEffect(isSelected ? 1.1 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                                    Text(option.label)
                                        .font(.custom("PlayfairDisplay-Regular", size: 16))
                                        .foregroundColor(isSelected ? .white : AppConstants.Colors.textPrimary)
                                    Spacer()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(optionBackground(isSelected: isSelected))
                                .disabled(!isSelected && selectedOptions.count >= 3)
                                .cornerRadius(30)
                            }
                            .opacity(wordVisibility.last == true ? 1 : 0)
                            .offset(y: wordVisibility.last == true ? 0 : 20)
                            .animation(.easeInOut(duration: 0.5).delay(0.7 + Double(index) * 0.1), value: wordVisibility.last)
                        }
                    }
                    .padding(.horizontal, geo.size.width * 0.07)
                    .padding(.bottom, geo.size.height * 0.04)

                    Spacer()

                    // Next button
                    PrimaryButton("Next", isEnabled: !selectedOptions.isEmpty) {
                        currentPage += 1
                    }
                    .padding(.horizontal, geo.size.width * 0.07)
                    .padding(.bottom, geo.size.height * 0.03)
                    .opacity(!selectedOptions.isEmpty ? 1 : 0.6)
                    .animation(.easeInOut(duration: 0.3), value: selectedOptions.isEmpty)
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                .onAppear {
                    selectedOptions.removeAll()
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
    }
}

struct YourFeelingCardCarouselPage_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var page = 12
        var body: some View {
            YourFeelingCardCarouselPage(currentPage: $page)
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}
