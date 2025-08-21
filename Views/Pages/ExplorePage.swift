import SwiftUI

struct ExplorePage: View {
    @Environment(\.presentationMode) var presentationMode
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
                            // Header
                            headerSection
                            
                            // Explore Categories
                            exploreCategoriesSection
                            
                            // Featured Content
                            featuredContentSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Explore")
                .font(.custom("PlayfairDisplay-Regular", size: 36))
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("Discover new wellness practices, learn about TCM principles, and find personalized recommendations for your health journey.")
                .font(.custom("NotoSansSC-Regular", size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Explore Categories Section
    private var exploreCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Categories")
                .font(.custom("PlayfairDisplay-Regular", size: 24))
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                exploreCategoryCard(
                    title: "Nutrition",
                    subtitle: "Food as medicine",
                    icon: "leaf.fill",
                    color: Color(hex: "#6BCF7F")
                )
                
                exploreCategoryCard(
                    title: "Movement",
                    subtitle: "Qi Gong & Exercise",
                    icon: "figure.mind.and.body",
                    color: Color(hex: "#E6B422")
                )
                
                exploreCategoryCard(
                    title: "Mindfulness",
                    subtitle: "Meditation & Breath",
                    icon: "brain.head.profile",
                    color: Color(hex: "#6BA4B8")
                )
                
                exploreCategoryCard(
                    title: "Wellness",
                    subtitle: "Holistic practices",
                    icon: "heart.fill",
                    color: Color(hex: "#AA3939")
                )
            }
        }
    }
    
    private func exploreCategoryCard(title: String, subtitle: String, icon: String, color: Color) -> some View {
        Button(action: {
            // Handle category selection
        }) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.custom("PlayfairDisplay-Regular", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.custom("NotoSansSC-Regular", size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Featured Content Section
    private var featuredContentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Featured")
                .font(.custom("PlayfairDisplay-Regular", size: 24))
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    featuredCard(
                        title: "Seasonal Eating",
                        subtitle: "Align your diet with nature's cycles",
                        imageName: "springbackground"
                    )
                    
                    featuredCard(
                        title: "Morning Rituals",
                        subtitle: "Start your day with intention",
                        imageName: "morningsun"
                    )
                    
                    featuredCard(
                        title: "Elemental Balance",
                        subtitle: "Understanding the five elements",
                        imageName: "yinyangyellow"
                    )
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private func featuredCard(title: String, subtitle: String, imageName: String) -> some View {
        Button(action: {
            // Handle featured content selection
        }) {
            VStack(alignment: .leading, spacing: 8) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 120)
                    .clipped()
                    .cornerRadius(12, corners: [.topLeft, .topRight])
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("PlayfairDisplay-Regular", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.custom("NotoSansSC-Regular", size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .frame(width: 200)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
struct ExplorePage_Previews: PreviewProvider {
    static var previews: some View {
        ExplorePage()
    }
} 