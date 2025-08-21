import SwiftUI

struct HydrateDetailPage: View {
    let recommendation: RecommendationItemProtocol
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedIconIndex = 2 // Start with middle icon (Green Tea)

    
    var body: some View {
        NavigationContentView(selectedTab: .constant(0)) {
            GeometryReader { geo in
                ZStack {
                    // Background gradient
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#E2D5C0"), // darker on top
                            Color(hex: "#FFFEFC")  // lighter on bottom
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(.all, edges: .all)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // 3D Icon Carousel
                            iconCarousel
                            
                            // Benefits Section
                            VStack(spacing: 16) {
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(Color(hex: "#6BA4B8"))
                                        .font(.system(size: 20))
                                    Text("Benefits")
                                        .font(.custom("PlayfairDisplay-Regular", size: 22))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(getBenefitsForIcon(selectedIconIndex), id: \.self) { benefit in
                                        benefitRow(icon: benefit.icon, text: benefit.text)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                            .frame(height: 260) // Increased height to better accommodate wrapped text
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.8))
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                            
                            // Increased spacing between sections
                            Spacer()
                                .frame(height: 32)
                            
                            // Pro Tips Section
                            VStack(spacing: 16) {
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(Color(hex: "#6BA4B8"))
                                        .font(.system(size: 20))
                                    Text("Pro Tips")
                                        .font(.custom("PlayfairDisplay-Regular", size: 22))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(getTipsForIcon(selectedIconIndex), id: \.self) { tip in
                                        tipRow(icon: tip.icon, text: tip.text)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                            .frame(height: 260) // Increased height to better accommodate wrapped text
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.8))
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("Back")
                            .font(.custom("NotoSansSC-Regular", size: 16))
                    }
                    .foregroundColor(Color(hex: "#6BA4B8"))
                }
            }
            

        }
    }
    
    // MARK: - 3D Icon Carousel
    private var iconCarousel: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Simplified centering approach
            VStack(spacing: 20) {
                ZStack {
                    // Background circle for depth - perfectly centered
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                    
                    // Icon carousel - centered within the background circle
                    HStack(spacing: 0) {
                        ForEach(0..<hydrationIcons.count, id: \.self) { index in
                            let icon = hydrationIcons[index]
                            let isSelected = selectedIconIndex == index
                            let offset = CGFloat(index - selectedIconIndex)
                            
                            ZStack {
                                // Icon background
                                Circle()
                                    .fill(isSelected ? Color(hex: "#6BA4B8") : Color.white.opacity(0.8))
                                    .frame(width: isSelected ? 80 : 60, height: isSelected ? 80 : 60)
                                    .shadow(color: isSelected ? Color(hex: "#6BA4B8").opacity(0.4) : Color.black.opacity(0.1), 
                                           radius: isSelected ? 15 : 8, 
                                           x: 0, 
                                           y: isSelected ? 8 : 4)
                                
                                // Icon
                                Image(systemName: icon.symbol)
                                    .font(.system(size: isSelected ? 32 : 24, weight: .medium))
                                    .foregroundColor(isSelected ? .white : Color(hex: "#6BA4B8"))
                            }
                            .scaleEffect(isSelected ? 1.0 : 0.8)
                            .offset(x: offset * 25)
                            .zIndex(isSelected ? 1 : 0)
                            .opacity(abs(offset) <= 1 ? 1.0 : 0.0) // Only show 3 icons: selected + 1 on each side
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedIconIndex)
                        }
                    }
                    .offset(x: -CGFloat(selectedIconIndex) * 25) // Center the selected icon
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                if value.translation.width > threshold && selectedIconIndex > 0 {
                                    // Swipe right - go to previous icon
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        selectedIconIndex -= 1
                                    }
                                } else if value.translation.width < -threshold && selectedIconIndex < hydrationIcons.count - 1 {
                                    // Swipe left - go to next icon
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        selectedIconIndex += 1
                                    }
                                }
                            }
                    )
                }
                
                // Icon labels - centered below the carousel
                Text(hydrationIcons[selectedIconIndex].name)
                    .font(.custom("NotoSansSC-Regular", size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "#6BA4B8"))
                    .animation(.easeInOut(duration: 0.3), value: selectedIconIndex)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Functions
    private func benefitRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#6BA4B8"))
                .font(.system(size: 16))
                .frame(width: 20)
            
            Text(text)
                .font(.custom("NotoSansSC-Regular", size: 16))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
    
    private func tipRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#6BA4B8"))
                .font(.system(size: 16))
                .frame(width: 20)
            
            Text(text)
                .font(.custom("NotoSansSC-Regular", size: 16))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
    
    // MARK: - Benefits and Tips Data
    private func getBenefitsForIcon(_ index: Int) -> [BenefitItem] {
        switch index {
        case 0: // Pure Water
            return [
                BenefitItem(icon: "drop.fill", text: "Promotes healthy skin and complexion"),
                BenefitItem(icon: "leaf.fill", text: "Supports natural detoxification"),
                BenefitItem(icon: "heart.fill", text: "Improves cardiovascular health"),
                BenefitItem(icon: "brain.head.profile", text: "Enhances mental clarity and focus")
            ]
        case 1: // Herbal Tea
            return [
                BenefitItem(icon: "leaf.fill", text: "Natural stress relief and relaxation"),
                BenefitItem(icon: "moon.fill", text: "Improves sleep quality"),
                BenefitItem(icon: "heart.fill", text: "Supports digestive health"),
                BenefitItem(icon: "drop.fill", text: "Rich in antioxidants and minerals")
            ]
        case 2: // Green Tea
            return [
                BenefitItem(icon: "flame.fill", text: "Boosts metabolism and energy"),
                BenefitItem(icon: "brain.head.profile", text: "Enhances cognitive function"),
                BenefitItem(icon: "heart.fill", text: "Improves heart health"),
                BenefitItem(icon: "leaf.fill", text: "High in polyphenols and antioxidants")
            ]
        case 3: // Coconut Water
            return [
                BenefitItem(icon: "drop.fill", text: "Natural electrolyte replacement"),
                BenefitItem(icon: "heart.fill", text: "Supports kidney function"),
                BenefitItem(icon: "leaf.fill", text: "Rich in potassium and magnesium"),
                BenefitItem(icon: "flame.fill", text: "Great for post-workout recovery")
            ]
        case 4: // Hot Beverage
            return [
                BenefitItem(icon: "thermometer", text: "Warms the body naturally"),
                BenefitItem(icon: "heart.fill", text: "Improves circulation"),
                BenefitItem(icon: "brain.head.profile", text: "Enhances focus and alertness"),
                BenefitItem(icon: "leaf.fill", text: "Supports respiratory health")
            ]
        default:
            return []
        }
    }
    
    private func getTipsForIcon(_ index: Int) -> [TipItem] {
        switch index {
        case 0: // Pure Water
            return [
                TipItem(icon: "clock.fill", text: "Drink 8 oz every 2 hours for optimal hydration"),
                TipItem(icon: "thermometer", text: "Room temperature water is easier to absorb"),
                TipItem(icon: "drop.fill", text: "Add lemon or cucumber for natural flavoring"),
                TipItem(icon: "moon.fill", text: "Stay hydrated even during sleep hours")
            ]
        case 1: // Herbal Tea
            return [
                TipItem(icon: "clock.fill", text: "Best consumed 1-2 hours before bedtime"),
                TipItem(icon: "thermometer", text: "Steep for 5-7 minutes for optimal flavor"),
                TipItem(icon: "leaf.fill", text: "Try chamomile, lavender, or valerian for sleep"),
                TipItem(icon: "drop.fill", text: "Avoid caffeine-containing herbal blends")
            ]
        case 2: // Green Tea
            return [
                TipItem(icon: "clock.fill", text: "Best consumed in the morning or early afternoon"),
                TipItem(icon: "thermometer", text: "Steep at 175°F for 2-3 minutes"),
                TipItem(icon: "drop.fill", text: "Add honey or lemon for natural sweetness"),
                TipItem(icon: "flame.fill", text: "Limit to 2-3 cups daily for optimal benefits")
            ]
        case 3: // Coconut Water
            return [
                TipItem(icon: "clock.fill", text: "Perfect for pre and post-workout hydration"),
                TipItem(icon: "thermometer", text: "Serve chilled for best taste"),
                TipItem(icon: "drop.fill", text: "Choose fresh over packaged when possible"),
                TipItem(icon: "leaf.fill", text: "Great base for smoothies and cocktails")
            ]
        case 4: // Hot Beverage
            return [
                TipItem(icon: "clock.fill", text: "Best consumed in the morning to warm up"),
                TipItem(icon: "thermometer", text: "Serve at comfortable drinking temperature"),
                TipItem(icon: "drop.fill", text: "Add ginger or honey for extra benefits"),
                TipItem(icon: "moon.fill", text: "Avoid very hot beverages before sleep")
            ]
        default:
            return []
        }
    }
    
    // MARK: - Hydration Icons Data
    private let hydrationIcons = [
        HydrationIcon(symbol: "drop.fill", name: "Pure Water"),
        HydrationIcon(symbol: "leaf.fill", name: "Herbal Tea"),
        HydrationIcon(symbol: "cup.and.saucer.fill", name: "Green Tea"),
        HydrationIcon(symbol: "drop.circle.fill", name: "Coconut Water"),
        HydrationIcon(symbol: "flame.fill", name: "Hot Beverage")
    ]
}

// MARK: - Data Models
struct HydrationIcon {
    let symbol: String
    let name: String
}

struct BenefitItem: Hashable {
    let icon: String
    let text: String
}

struct TipItem: Hashable {
    let icon: String
    let text: String
}



// MARK: - Preview
struct HydrateDetailPage_Previews: PreviewProvider {
    static var previews: some View {
        // Create a simple mock for preview using the existing MockRecommendationItem
        let mockRecommendation = MockRecommendationItem(
            title: "Drink Water",
            subtitle: "8 oz glass",
            icon: "drop.fill"
        )
        
        HydrateDetailPage(recommendation: mockRecommendation)
    }
}

 