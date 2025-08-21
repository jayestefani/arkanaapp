import SwiftUI

struct EnergySurveyCarouselPage: View {
    @Binding var currentPage: Int
    @State private var energyLevel: Double = 0.5 // Start in the middle (50%)
    @State private var wordVisibility = Array(repeating: false, count: 8)
    @State private var breathingPhase: Double = 0.0 // For breathing animation
    @State private var isDragging = false
    
    private let words: [(text: String, font: Font)] = [
        ("Describe", AppConstants.Fonts.heading),
        (" ", AppConstants.Fonts.heading),
        ("your",AppConstants.Fonts.heading),
        (" ", AppConstants.Fonts.heading),
        ("daily", AppConstants.Fonts.heading),
        (" ", AppConstants.Fonts.heading),
        ("energy",AppConstants.Fonts.heading),
        (".", AppConstants.Fonts.heading)
    ]
    
    let energyStates = [
        ("🔥", "CONSTANTLY DRAINED", "You feel exhausted most of the time. Your Qi may be deficient or blocked, requiring gentle nourishment and rest.", AppConstants.Colors.primary), // Brand Red for very low
        ("🍁", "OFTEN DRAINED", "Energy crashes are common. Your Qi flow might be irregular, needing support to find balance.", Color(hex: "#D45A5A")), // Lighter Red for low
        ("🍂", "PEAKS & CRASHES", "Your energy fluctuates dramatically. This suggests Qi stagnation that needs smoothing out.", Color(hex: "#FFD93D")), // Yellow for middle
        ("🍃", "MOSTLY STABLE", "Generally good energy with occasional dips. Your Qi is mostly balanced with room for improvement.", AppConstants.Colors.accent), // Brand Green for good
        ("🌱", "STEADY & BALANCED", "Consistent, sustainable energy throughout the day. Your Qi flows harmoniously!", AppConstants.Colors.secondary) // Dark Green for high
    ]
    
    var currentEnergyState: (emoji: String, title: String, description: String, color: Color) {
        let index = Int(energyLevel * 4) // Convert 0-1 to 0-4
        return energyStates[min(index, energyStates.count - 1)]
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppConstants.Colors.secondaryBackgroundGradient
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header (tokenized with AppConstants fonts + animation)
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 0) {
                            ForEach(0..<6, id: \.self) { idx in
                                Text(words[idx].text)
                                    .font(words[idx].font)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppConstants.Colors.textPrimary)
                                    .opacity(wordVisibility[idx] ? 1 : 0)
                                    .animation(AppConstants.Animation.standard, value: wordVisibility[idx])
                            }
                        }
                        HStack(spacing: 0) {
                            ForEach(6..<words.count, id: \.self) { idx in
                                Text(words[idx].text)
                                    .font(words[idx].font)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppConstants.Colors.textPrimary)
                                    .opacity(wordVisibility[idx] ? 1 : 0)
                                    .animation(AppConstants.Animation.standard, value: wordVisibility[idx])
                            }
                        }
                    }
                    .frame(maxWidth: geo.size.width * 0.86, alignment: .leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, geo.size.height * 0.065)
                    .padding(.horizontal, geo.size.width * 0.07)

                    // Subheader
                    Text("Tap or drag the circle to set your energy level")
                        .font(.custom("PlayfairDisplay-Regular", size: geo.size.width * 0.042))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 20)
                        .padding(.horizontal, geo.size.width * 0.07)

                    // Circular Energy Meter
                    VStack(spacing: 0) {
                        CircularEnergyMeter(
                            energyLevel: energyLevel,
                            breathingPhase: breathingPhase,
                            isDragging: isDragging,
                            energyStates: energyStates,
                            geo: geo
                        )
                        .frame(width: geo.size.width * 0.7, height: geo.size.width * 0.7)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    isDragging = true
                                    let center = CGPoint(x: geo.size.width * 0.35, y: geo.size.width * 0.35)
                                    let radius = geo.size.width * 0.25
                                    
                                    let distance = sqrt(pow(value.location.x - center.x, 2) + pow(value.location.y - center.y, 2))
                                    let angle = atan2(value.location.y - center.y, value.location.x - center.x)
                                    
                                    // Convert angle to 0-1 range (0 = top, 0.5 = bottom, 1 = top)
                                    var normalizedAngle = (angle + .pi/2) / (2 * .pi)
                                    if normalizedAngle < 0 { normalizedAngle += 1 }
                                    
                                    // Use distance to determine if we're in the outer ring
                                    if distance > radius * 0.6 && distance < radius * 1.2 {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            energyLevel = normalizedAngle
                                        }

                                    }
                                }
                                .onEnded { _ in
                                    isDragging = false
                                    // Snap to nearest energy level
                                    let snappedLevel = round(energyLevel * 4) / 4
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        energyLevel = snappedLevel
                                    }
                                }
                        )
                        .onTapGesture {
                            // Handle tap for quick selection
                            let tapLevel = energyLevel
                            let snappedLevel = round(tapLevel * 4) / 4
                            withAnimation(.easeInOut(duration: 0.3)) {
                                energyLevel = snappedLevel
                            }

                        }
                        

                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 32)


                    
                    Spacer()
                    
                    // Next Button
                    PrimaryButton("Next", isEnabled: true) {
                        currentPage += 1
                    }
                    .padding(.horizontal, geo.size.width * 0.07)
                    .padding(.bottom, geo.size.height * 0.08)
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            }
        }
        .onAppear {
            animateWords()
            startBreathingAnimation()
        }
    }
    
    private func startBreathingAnimation() {
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            breathingPhase = 1.0
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

// MARK: - Circular Energy Meter
struct CircularEnergyMeter: View {
    let energyLevel: Double
    let breathingPhase: Double
    let isDragging: Bool
    let energyStates: [(emoji: String, title: String, description: String, color: Color)]
    let geo: GeometryProxy
    
    private var energyPercentage: Int {
        Int(energyLevel * 100)
    }
    
    private var energyColor: Color {
        switch energyLevel {
        case 0.0...0.2: return AppConstants.Colors.primary // Brand Red for very low
        case 0.2...0.4: return Color(hex: "#D45A5A") // Lighter Red for low
        case 0.4...0.6: return Color(hex: "#FFD93D") // Yellow for middle
        case 0.6...0.8: return AppConstants.Colors.accent // Brand Green for good
        case 0.8...1.0: return AppConstants.Colors.secondary // Dark Green for high
        default: return Color.gray
        }
    }
    
    var body: some View {
        ZStack {
            // Outer breathing ring
            Circle()
                .stroke(
                    energyColor.opacity(0.1),
                    lineWidth: 2
                )
                .scaleEffect(1.0 + breathingPhase * 0.05)
                .opacity(0.3 + breathingPhase * 0.2)
            
            // Main progress ring
            Circle()
                .trim(from: 0, to: energyLevel)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            energyColor.opacity(0.8),
                            energyColor.opacity(1.0),
                            energyColor.opacity(0.8)
                        ]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .scaleEffect(isDragging ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isDragging)
            
            // Inner breathing glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            energyColor.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: geo.size.width * 0.15
                    )
                )
                .scaleEffect(1.0 + breathingPhase * 0.1)
                .opacity(0.5 + breathingPhase * 0.3)
            
            // Center content
            VStack(spacing: 8) {
                Text("\(energyPercentage)%")
                    .font(.custom("PlayfairDisplay-Regular", size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(energyColor)
                
                Text(getEnergyStateTitle())
                    .font(.custom("PlayfairDisplay-Regular", size: 14))
                    .foregroundColor(energyColor)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: geo.size.width * 0.4)
            }
            .scaleEffect(isDragging ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isDragging)
            
            // Energy level tick marks
            ForEach(0..<5) { index in
                let angle = Double(index) * 72 - 90 // 5 ticks, 72 degrees apart, starting from top
                let innerRadius = geo.size.width * 0.125
                
                // Create tick line
                Rectangle()
                    .fill(index <= Int(energyLevel * 4) ? energyColor : Color.gray.opacity(0.5))
                    .frame(width: 3, height: 12)
                    .offset(x: cos(angle * .pi / 180) * innerRadius, y: sin(angle * .pi / 180) * innerRadius)
                    .rotationEffect(.degrees(Double(index) * 72 - 90))
                    .scaleEffect(isDragging ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isDragging)
            }
        }
    }
    
    private func getEnergyStateTitle() -> String {
        let index = Int(energyLevel * 4)
        let state = energyStates[min(index, energyStates.count - 1)]
        return state.title
    }
}





struct EnergySurveyCarouselPage_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var page = 12
        var body: some View {
            EnergySurveyCarouselPage(currentPage: $page)
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}
