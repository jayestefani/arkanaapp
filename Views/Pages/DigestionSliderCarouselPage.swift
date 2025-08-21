import SwiftUI

struct DigestionSliderCarouselPage: View {
    @Binding var currentPage: Int
    @State private var selectedOption: Int? = nil
    @State private var wordVisibility = Array(repeating: false, count: 12)
    @State private var subheaderVisible = false
    @State private var optionsVisible = false

    private let words: [(text: String, font: Font)] = [
        ("How", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("is", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("your", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("digestion", AppConstants.Fonts.heading),
        ("",  AppConstants.Fonts.heading),
        ("most", AppConstants.Fonts.heading),
        (" ",  AppConstants.Fonts.heading),
        ("days", AppConstants.Fonts.heading),
        ("?", AppConstants.Fonts.title)
    ]

    let digestionStates = [
        ("🌱", "Robust & Harmonious", "Strong and balanced", "🌱 Robust", AppConstants.Colors.secondary), // Dark Green for excellent
        ("🍵", "Balanced & Comfortable", "Usually comfortable and regular", "🍵 Balanced", AppConstants.Colors.accent), // Brand Green for good
        ("🍚", "Mostly Neutral", "Neither great nor bad", "🍚 Neutral", Color(hex: "#FFD93D")), // Yellow for normal
        ("💨", "Unsettled / Sensitive", "Feel bloated, gassy, sensitive", "💨 Sensitive", Color(hex: "#D45A5A")), // Lighter Red for poor
        ("🔥", "Hot / Painful / Blocked", "Frequent discomfort or pain", "🔥 Painful", AppConstants.Colors.primary) // Brand Red for very poor
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppConstants.Colors.secondaryBackgroundGradient
                    .ignoresSafeArea()

                VStack(alignment: .leading) {
                    // Header
                    headerView(geo: geo)
                    
                    // Subheader
                    Text("Gut comfort uncovers hidden imbalances.")
                        .font(.custom("PlayfairDisplay-Regular", size: geo.size.width * 0.042))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: geo.size.width * 0.86, alignment: .leading)
                        .opacity(subheaderVisible ? 1 : 0)
                        .animation(AppConstants.Animation.standard, value: subheaderVisible)
                        .padding(.bottom, geo.size.height * 0.04)
                        .padding(.horizontal, geo.size.width * 0.07)

                    // Reduce vertical gap between header and options
                    Spacer()
                        .frame(height: geo.size.height * 0.016)

                    // Digestion Options
                    digestionOptionsView(geo: geo)

                    Spacer()

                    // Next Button
                    PrimaryButton("Next", isEnabled: selectedOption != nil) {
                        currentPage += 1
                    }
                    .padding(.horizontal, geo.size.width * 0.07)
                    .padding(.bottom, geo.size.height * 0.03)
                }
                .frame(maxWidth: .infinity)
                .frame(height: geo.size.height, alignment: .top)
                .onAppear {
                    subheaderVisible = false
                    optionsVisible = false
                    animateWords()
                }
            }
        }
    }
    
    // MARK: - Header View
    @ViewBuilder
    private func headerView(geo: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // First line: "How is your digestion"
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
            // Second line: "most days?"
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
        .padding(.top, geo.size.height * 0.065)
        .padding(.bottom, geo.size.height * 0.02)
        .padding(.horizontal, geo.size.width * 0.07)
    }
    
    // MARK: - Digestion Options View
    @ViewBuilder
    private func digestionOptionsView(geo: GeometryProxy) -> some View {
        VStack(spacing: AppConstants.Spacing.responsiveMedium(geo.size.height)) {
            ForEach(0..<digestionStates.count, id: \.self) { index in
                digestionOptionButton(index: index, geo: geo)
            }
        }
        .opacity(optionsVisible ? 1 : 0)
        .animation(AppConstants.Animation.standard, value: optionsVisible)
        .padding(.horizontal, geo.size.width * 0.07)
    }
    
    // MARK: - Individual Digestion Option Button
    @ViewBuilder
    private func digestionOptionButton(index: Int, geo: GeometryProxy) -> some View {
        let isSelected = selectedOption == index
        
        Button(action: {
            selectedOption = isSelected ? nil : index
        }) {
            HStack(alignment: .top, spacing: 12) {
                Text(digestionStates[index].0)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : AppConstants.Colors.textPrimary)
                
                VStack(alignment: .leading, spacing: 4) {
                    // Promote previous subheader to header text
                    Text(digestionStates[index].2)
                        .font(.custom("PlayfairDisplay-Regular", size: 16))
                        .foregroundColor(isSelected ? .white : AppConstants.Colors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(optionBackground(isSelected: isSelected, index: index))
            .cornerRadius(30)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
    
    private func optionBackground(isSelected: Bool, index: Int) -> some View {
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
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation { wordVisibility[i] = true }
            }
        }
        
        // After header animation completes, fade in the rest of the UI
        let headerDuration = Double(wordVisibility.count) * 0.15
        DispatchQueue.main.asyncAfter(deadline: .now() + headerDuration + 0.3) {
            withAnimation { subheaderVisible = true }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + headerDuration + 0.6) {
            withAnimation { optionsVisible = true }
        }
    }
}

struct DigestionSliderCarouselPage_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var page = 13
        var body: some View {
            DigestionSliderCarouselPage(currentPage: $page)
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}

