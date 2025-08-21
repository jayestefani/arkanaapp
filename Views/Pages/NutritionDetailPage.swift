import SwiftUI

// MARK: - Protocol for Recommendation Items
protocol RecommendationItemProtocol {
    var title: String { get }
    var subtitle: String { get }
    var icon: String { get }
}

struct NutritionDetailPage: View {
    let recommendation: RecommendationItemProtocol
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedServings: Int = 5
    let availableServings = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
    var body: some View {
        NavigationContentView(selectedTab: .constant(0)) {
            ZStack {
                VStack(spacing: 0) {
                    // Photo placeholder that spans the screen
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 3/5) // 5:3 aspect ratio to match MovementDetailPage
                        .ignoresSafeArea(.all, edges: .top) // Push to very top of screen
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("Photo Placeholder")
                                    .font(.custom("NotoSansSC-Regular", size: 16))
                                    .foregroundColor(.gray)
                            }
                        )
                    
                    // Header Section below photo - positioned to match MovementDetailPage
                    headerSection
                        .padding(.top, -56) // Move header down a bit more
                    
                    // Scrollable content below header
                    ScrollView {
                        VStack(spacing: 0) {
                            // Food description area - tied to database column property
                            Text("This is a placeholder description for Congee. The actual description will be pulled from the database and displayed here. It can include details about the food, nutritional benefits, preparation methods, and any other relevant information.")
                                .font(AppConstants.Fonts.bodySmall)
                                .foregroundColor(Color(hex: "#2A2D34"))
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, AppConstants.Spacing.small) // Reduced from medium to small
                                .padding(.bottom, AppConstants.Spacing.large)
                                .padding(.horizontal, 20)
                            
                            // Divider line between Description and Recipe Properties
                            Rectangle()
                                .fill(Color(hex: "#5A7D5A").opacity(0.3))
                                .frame(height: 1)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                            
                            // Recipe Properties Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recipe Properties")
                                    .font(AppConstants.Fonts.heading)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(hex: "#2A2D34"))
                                
                                HStack(alignment: .top, spacing: 20) {
                                    // Left column
                                    VStack(alignment: .leading, spacing: 12) {
                                        propertyRow(label: "Season", value: "All Year")
                                        propertyRow(label: "Cook Time", value: "45 min")
                                        propertyRow(label: "Total Time", value: "55 min")
                                    }
                                    
                                    // Right column
                                    VStack(alignment: .leading, spacing: 12) {
                                        propertyRow(label: "Servings", value: "4-6 pe")
                                        propertyRow(label: "Difficulty", value: "Easy")
                                        propertyRow(label: "Cuisine", value: "Chinese")
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .padding(.bottom, 24)
                            
                            // Ingredients Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Ingredients")
                                    .font(AppConstants.Fonts.heading)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(hex: "#2A2D34"))
                                
                                // Serves dropdown
                                HStack {
                                    Text("Serves")
                                        .font(AppConstants.Fonts.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(hex: "#5A7D5A"))
                                    
                                    Menu {
                                        ForEach(availableServings, id: \.self) { servings in
                                            Button(action: {
                                                selectedServings = servings
                                            }) {
                                                HStack {
                                                    Text("\(servings)")
                                                    if servings == selectedServings {
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text("\(selectedServings)")
                                                .font(.custom("NotoSansSC-Regular", size: 16))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(hex: "#5A7D5A"))
                                            
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(hex: "#5A7D5A"))
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color(hex: "#5A7D5A").opacity(0.1))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color(hex: "#5A7D5A").opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                }
                                
                                // Recipe Time (NEW)
                                HStack {
                                    Text("Time to make:")
                                        .font(AppConstants.Fonts.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(hex: "#5A7D5A"))
                                    Text("~45 minutes")
                                        .font(.custom("NotoSansSC-Regular", size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(hex: "#5A7D5A"))
                                }
                                .padding(.top, 8)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    ingredientRow(text: "\(scaledQuantity(base: 1, unit: "cup")) white rice (jasmine or short-grain)")
                                    ingredientRow(text: "\(scaledQuantity(base: 6, unit: "cups")) water or chicken broth")
                                    ingredientRow(text: "\(scaledQuantity(base: 1, unit: "inch piece")) fresh ginger, sliced")
                                    ingredientRow(text: "\(scaledQuantity(base: 2, unit: "cloves")) garlic, minced")
                                    ingredientRow(text: "\(scaledQuantity(base: 1, unit: "tablespoon")) soy sauce")
                                    ingredientRow(text: "\(scaledQuantity(base: 1, unit: "teaspoon")) sesame oil")
                                    ingredientRow(text: "\(scaledQuantity(base: 2, unit: "green onions")) chopped")
                                    ingredientRow(text: "Salt and white pepper to taste")
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "#5A7D5A").opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 32) // Add extra spacing after ingredients
                            
                            // Divider line between Ingredients and Step-by-Step
                            Rectangle()
                                .fill(Color(hex: "#5A7D5A").opacity(0.3))
                                .frame(height: 1)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                            
                            // Step-by-Step Recipe Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Step-by-Step Recipe")
                                    .font(AppConstants.Fonts.heading)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(hex: "#2A2D34"))
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    stepRow(number: "1", text: "Rinse the rice thoroughly under cold water until the water runs clear. Drain well.")
                                    stepRow(number: "2", text: "In a large pot, bring 6 cups of water or chicken broth to a boil over medium-high heat.")
                                    stepRow(number: "3", text: "Add the rinsed rice and reduce heat to low. Simmer gently, stirring occasionally to prevent sticking.")
                                    stepRow(number: "4", text: "After 20 minutes, add the ginger, garlic, soy sauce, and sesame oil. Continue simmering for another 10-15 minutes.")
                                    stepRow(number: "5", text: "Stir in the chopped green onions and season with salt and white pepper to taste.")
                                    stepRow(number: "6", text: "Simmer for an additional 5 minutes until the congee reaches your desired consistency.")
                                    stepRow(number: "7", text: "Remove from heat and let stand for 5 minutes before serving hot.")
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            
                            // Divider line between Step-by-Step and Ingredient Properties
                            Rectangle()
                                .fill(Color(hex: "#5A7D5A").opacity(0.3))
                                .frame(height: 1)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                            
                            // Ingredient Properties Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Ingredient Properties")
                                    .font(AppConstants.Fonts.heading)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(hex: "#2A2D34"))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            
                            // Add bottom padding for better scrolling experience
                            Spacer(minLength: 40)
                        }
                    }
                }
                
                // Navigation overlay - positioned absolutely at top
                VStack {
                    HStack {
                        // Back button (left side)
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 50)
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        // Share button (right side)
                        Button(action: {
                            // Share functionality
                            let shareText = "Check out this nutrition recommendation: \(recommendation.title)"
                            let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
                            
                            // Present the share sheet
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                window.rootViewController?.present(activityVC, animated: true)
                            }
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 50)
                        .padding(.trailing, 20)
                    }
                    Spacer()
                }
                .zIndex(3) // Ensure navigation overlay appears above everything
                .ignoresSafeArea(.all, edges: .top) // Position at very top of screen
            }
        }
        .navigationBarHidden(true) // Hide the default navigation bar
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) { // No spacing between elements to bring content closer to photo
            // Main Title - tied to database column property
            Text(recommendation.title.uppercased())
                .font(AppConstants.Fonts.bodyTiny)
                .foregroundColor(Color(hex: "#2A2D34"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 0) // Ensure left alignment
                .padding(.bottom, 8) // Add spacing between title and subtitle
            
            // Subheader - tied to database column property
            Text(recommendation.subtitle)
                .font(AppConstants.Fonts.title)
                .foregroundColor(Color(hex: "#2A2D34"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 0) // Ensure left alignment
                .padding(.bottom, 0) // Match MovementDetailPage spacing
            
            // Category line - tied to database column property
            Text("Thermal Nature - \(recommendation.title)")
                .font(AppConstants.Fonts.body)
                .foregroundColor(Color(hex: "#2A2D34"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 0) // Ensure left alignment
                .padding(.bottom, 4) // Match MovementDetailPage spacing
            
            // Benefits line - tied to database column property
            Text("Flavor - ")
                .font(AppConstants.Fonts.body)
                .foregroundColor(Color(hex: "#2A2D34"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 0) // Ensure left alignment
                .padding(.bottom, 8) // Match MovementDetailPage spacing
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16) // Match MovementDetailPage spacing
    }
    
    // MARK: - Helper Views
    private func ingredientRow(text: String) -> some View {
        HStack(spacing: 12) {
            Text("•")
                .font(.custom("NotoSansSC-Regular", size: 16))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#5A7D5A"))
                .frame(width: 20)
            
            Text(text)
                .font(.custom("NotoSansSC-Regular", size: 14))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
    
    private func stepRow(number: String, text: String) -> some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.custom("NotoSansSC-Regular", size: 16))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#5A7D5A"))
                .frame(width: 20)
            
            Text(text)
                .font(.custom("NotoSansSC-Regular", size: 14))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
    
    private func propertyRow(label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.custom("NotoSansSC-Regular", size: 14))
                .fontWeight(.medium)
                .foregroundColor(Color(hex: "#5A7D5A"))
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.custom("NotoSansSC-Regular", size: 14))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
    
    private func scaledQuantity(base: Double, unit: String) -> String {
        let scaledAmount = base * Double(selectedServings) / 5.0
        if scaledAmount.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(scaledAmount)) \(unit)"
        } else {
            return String(format: "%.1f %@", scaledAmount, unit)
        }
    }
}

// MARK: - Preview
struct NutritionDetailPage_Previews: PreviewProvider {
    static var previews: some View {
        // Create a simple mock for preview
        let mockRecommendation = MockRecommendationItem(
            title: "Breakfast",
            subtitle: "Congee",
            icon: "leaf.fill"
        )
        
        NutritionDetailPage(recommendation: mockRecommendation)
    }
}

// MARK: - Mock Recommendation for Preview
struct MockRecommendationItem: RecommendationItemProtocol {
    let title: String
    let subtitle: String
    let icon: String
}

// MARK: - Extension to make real RecommendationItem conform to protocol
extension RecommendationItem: RecommendationItemProtocol {} 
