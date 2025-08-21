import SwiftUI

struct SurveyStartPage: View {
    @Binding var currentPage: Int
    @State private var selectedOptions: Set<Int> = []

    let options = [
        ("Interest in Chinese medicine", "🏮"),
        ("Solving unresolved health issues", "🤕"),
        ("Preventative care & holistic wellness", "🌿"),
        ("Stress relief or emotional balance", "☯️"),
        ("Pain management (chronic/acute)", "😓"),
        ("Hormonal/digestive issues (IBS,PMS...)", "💥"),
        ("Sleep restoration (insomnia, fatigue)", "😴")
    ]

    private let words: [(text: String, font: Font)] = [
        ("What", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("brings", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("you", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("here", AppConstants.Fonts.heading),
        ("",  AppConstants.Fonts.heading),
        ("today", AppConstants.Fonts.heading),
        ("?", AppConstants.Fonts.heading)
    ]

    @State private var wordVisibility = Array(repeating: false, count: 10)

    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppConstants.Colors.secondaryBackgroundGradient
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Main Heading
                    VStack(alignment: .leading, spacing: 0) {
                        // First line: "What brings you here"
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
                        // Second line: "today?"
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
                    }
                    .multilineTextAlignment(.leading)
                        .frame(maxWidth: geo.size.width * 0.86, alignment: .leading)
                        .padding(.horizontal, geo.size.width * 0.07)
                        .padding(.top, geo.size.height * 0.065)
                    .padding(.bottom, geo.size.height * 0.02)
                    .onAppear {
                        for i in 0..<wordVisibility.count {
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.16) {
                                withAnimation(.easeOut(duration: 0.24)) { wordVisibility[i] = true }
                            }
                        }
                    }

                    // Subheader
                    Text("Choose 3 max")
                        .font(.custom("PlayfairDisplay-Regular", size: geo.size.width * 0.042))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: geo.size.width * 0.86, alignment: .leading)
                        .padding(.horizontal, geo.size.width * 0.07)
                        .padding(.bottom, geo.size.height * 0.04)

                    // Options
                    VStack(spacing: geo.size.height * 0.024) {
                        ForEach(0..<options.count, id: \.self) { index in
                            let isSelected = selectedOptions.contains(index)
                            Button(action: {
                                if isSelected {
                                    selectedOptions.remove(index)
                                } else if selectedOptions.count < 3 {
                                    selectedOptions.insert(index)
                                }
                            }) {
                                HStack {
                                    Text(options[index].1) // Emoji first
                                        .font(.custom("PlayfairDisplay-Regular", size: 16))
                                        .foregroundColor(isSelected ? .white : AppConstants.Colors.textPrimary)
                                        .padding(.trailing, geo.size.width * 0.025)
                                        .scaleEffect(isSelected ? 1.1 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                                    Text(options[index].0)
                                        .font(.custom("PlayfairDisplay-Regular", size: 16))
                                        .foregroundColor(isSelected ? .white : AppConstants.Colors.textPrimary)
                                    Spacer()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(optionBackground(isSelected: isSelected))
                                .cornerRadius(30)
                            }
                            .disabled(!isSelected && selectedOptions.count >= 3)
                        }
                    }
                    .padding(.horizontal, geo.size.width * 0.07)
                    .padding(.bottom, geo.size.height * 0.04) // 4% of screen height below last pill

                    Spacer()

                    // Next Button
                    PrimaryButton("Next", isEnabled: !selectedOptions.isEmpty) {
                        currentPage += 1
                    }
                    .padding(.horizontal, geo.size.width * 0.07)
                    .padding(.bottom, geo.size.height * 0.10)
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
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
}

struct SurveyStartPage_Previews: PreviewProvider {
    @State static var dummyPage = 9
    static var previews: some View {
        SurveyStartPage(currentPage: $dummyPage)
    }
}
