import SwiftUI

struct AnalysisPage: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        NavigationContentView(selectedTab: $selectedTab) {
            GeometryReader { geo in
                ZStack {
                    // Full screen background gradient
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#E2D5C0"), // darker on top
                            Color(hex: "#FFFEFC")  // lighter on bottom
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(.all, edges: .all)
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Analytical Visual
                            analyticalVisual
                            
                            // Two buttons stacked
                            VStack(spacing: 16) {
                                elementalBalanceButton
                                organHealthButton
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                    }
                }
            }
        }
    }
    
    // MARK: - Analytical Visual
    private var analyticalVisual: some View {
        VStack(spacing: 16) {
            // Health Score Circle
            ZStack {
                Circle()
                    .stroke(Color(hex: "#E6B422").opacity(0.2), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: 0.75) // 75% completion
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#E6B422"),
                                Color(hex: "#E6B422").opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("75")
                        .font(.custom("PlayfairDisplay-Regular", size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#E6B422"))
                    
                    Text("Score")
                        .font(.custom("PlayfairDisplay-Regular", size: 14))
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "#E6B422").opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Elemental Balance Button
    private var elementalBalanceButton: some View {
        Button(action: {
            // Handle elemental balance button tap
        }) {
            VStack(spacing: 8) {
                Text("Elemental Balance")
                    .font(.custom("PlayfairDisplay-Regular", size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Pie Chart for 5 Elements
                ZStack {
                    // Wood (Green) - 25%
                    PieSlice(startAngle: .degrees(0), endAngle: .degrees(90), color: Color(hex: "#6BCF7F"))
                    
                    // Fire (Red) - 20%
                    PieSlice(startAngle: .degrees(90), endAngle: .degrees(162), color: Color(hex: "#E6B422"))
                    
                    // Earth (Yellow) - 15%
                    PieSlice(startAngle: .degrees(162), endAngle: .degrees(216), color: Color(hex: "#F0E9DE"))
                    
                    // Metal (Gray) - 25%
                    PieSlice(startAngle: .degrees(216), endAngle: .degrees(306), color: Color(hex: "#8C9B9D"))
                    
                    // Water (Blue) - 15%
                    PieSlice(startAngle: .degrees(306), endAngle: .degrees(360), color: Color(hex: "#6BA4B8"))
                }
                .frame(width: 80, height: 80)
                
                // Element Labels
                HStack(spacing: 4) {
                    elementLabel("Wood", color: Color(hex: "#6BCF7F"))
                    elementLabel("Fire", color: Color(hex: "#E6B422"))
                    elementLabel("Earth", color: Color(hex: "#F0E9DE"))
                    elementLabel("Metal", color: Color(hex: "#8C9B9D"))
                    elementLabel("Water", color: Color(hex: "#6BA4B8"))
                }
                .font(.custom("PlayfairDisplay-Regular", size: 8))
                .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 280)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#6BA4B8"),
                                Color(hex: "#6BA4B8").opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(hex: "#6BA4B8").opacity(0.3), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Organ Health Button
    private var organHealthButton: some View {
        Button(action: {
            // Handle organ health button tap
        }) {
            VStack(spacing: 8) {
                Text("Organ Health")
                    .font(.custom("PlayfairDisplay-Regular", size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Circular Progress Chart for Organ Health
                ZStack {
                    // Background circles (faint)
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 8)
                        .frame(width: 40, height: 40)
                    
                    // Outer arc - Heart/Lungs (Blue) - 82%
                    CircularArc(
                        startAngle: .degrees(-90),
                        endAngle: .degrees(-90 + (360 * 0.82)),
                        color: Color(hex: "#6BA4B8"),
                        lineWidth: 8,
                        radius: 40
                    )
                    
                    // Middle arc - Liver/Gallbladder (Yellow) - 49%
                    CircularArc(
                        startAngle: .degrees(-90),
                        endAngle: .degrees(-90 + (360 * 0.49)),
                        color: Color(hex: "#E6B422"),
                        lineWidth: 8,
                        radius: 30
                    )
                    
                    // Inner arc - Kidneys/Bladder (Red) - 34%
                    CircularArc(
                        startAngle: .degrees(-90),
                        endAngle: .degrees(-90 + (360 * 0.34)),
                        color: Color(hex: "#AA3939"),
                        lineWidth: 8,
                        radius: 20
                    )
                    
                    // Overall Score
                    VStack(spacing: 2) {
                        Text("55")
                            .font(.custom("PlayfairDisplay-Regular", size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Overall")
                            .font(.custom("PlayfairDisplay-Regular", size: 8))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .frame(width: 80, height: 80)
                
                // Organ Labels
                HStack(spacing: 6) {
                    organLabel("Heart", color: Color(hex: "#6BA4B8"), percentage: "82%")
                    organLabel("Liver", color: Color(hex: "#E6B422"), percentage: "49%")
                    organLabel("Kidneys", color: Color(hex: "#AA3939"), percentage: "34%")
                }
                .font(.custom("PlayfairDisplay-Regular", size: 8))
                .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 280)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#6BCF7F"),
                                Color(hex: "#6BCF7F").opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(hex: "#6BCF7F").opacity(0.3), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper Functions
    private func elementLabel(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.custom("PlayfairDisplay-Regular", size: 8))
            .foregroundColor(.white)
            .padding(.horizontal, 2)
    }
    
    private func organLabel(_ text: String, color: Color, percentage: String) -> some View {
        HStack(spacing: 2) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text("\(text) \(percentage)")
                .font(.custom("PlayfairDisplay-Regular", size: 8))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Supporting Views
struct PieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    var body: some View {
        Path { path in
            let center = CGPoint(x: 40, y: 40)
            let radius: CGFloat = 35
            path.move(to: center)
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            path.closeSubpath()
        }
        .fill(color)
    }
}

struct CircularArc: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    let lineWidth: CGFloat
    let radius: CGFloat
    
    var body: some View {
        Path { path in
            let center = CGPoint(x: 40, y: 40)
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        }
        .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
    }
}

// MARK: - Preview
struct AnalysisPage_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisPage()
    }
} 
