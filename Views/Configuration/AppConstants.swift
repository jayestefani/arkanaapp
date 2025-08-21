import SwiftUI
#if os(iOS)
import UIKit
#endif

// MARK: - App Constants
struct AppConstants {
    
    // MARK: - Colors
    struct Colors {
        static let primary = Color(hex: "#AA3939")
        static let accent = Color(hex: "#7BAE7B") // Green accent color
        static let secondary = Color(hex: "#334833") // Dark green
        static let backgroundGradient = LinearGradient(
            gradient: Gradient(colors: [Color(hex: "#E2D5C0"), Color(hex: "#FFFEFC")]),
            startPoint: .top,
            endPoint: .bottom
        )
        static let secondaryBackgroundGradient = LinearGradient(
            gradient: Gradient(colors: [Color(hex: "#E2D5C0"), Color(hex: "#FFFEFC")]),
            startPoint: .top,
            endPoint: .bottom
        )
        static let selectedGradient = LinearGradient(
            gradient: Gradient(colors: [Color(hex: "#7BAE7B"), Color(hex: "#334833")]),
            startPoint: .leading,
            endPoint: .trailing
        )
        static let unselectedGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 123/255, green: 174/255, blue: 123/255, opacity: 0.2),
                Color(red: 51/255, green: 72/255, blue: 51/255, opacity: 0.2)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        
        // Sleep gradients
        static let deepSleepGradient = LinearGradient(
            gradient: Gradient(colors: [Color(hex: "#5A7D5A").opacity(0.3), Color(hex: "#A3E3A3").opacity(0.3)]),
            startPoint: .leading,
            endPoint: .trailing
        )
        
        static let lightSleepGradient = LinearGradient(
            gradient: Gradient(colors: [Color(hex: "#6BA4B8").opacity(0.3), Color(hex: "#304952").opacity(0.3)]),
            startPoint: .leading,
            endPoint: .trailing
        )
        
        static let brokenSleepGradient = LinearGradient(
            gradient: Gradient(colors: [Color(hex: "#E6B422").opacity(0.3), Color(hex: "#806413").opacity(0.3)]),
            startPoint: .leading,
            endPoint: .trailing
        )
        
        static let noSleepGradient = LinearGradient(
            gradient: Gradient(colors: [Color(hex: "#9F1F1F").opacity(0.3), Color(hex: "#9F1F1F").opacity(0.3)]),
            startPoint: .leading,
            endPoint: .trailing
        )
        static let buttonBackgroundGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "#D1BFA3"), // Slightly darker than #E2D5C0
                Color(hex: "#BFA77E")  // Even darker for depth
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let textPrimary = Color.black
        static let textSecondary = Color.black.opacity(0.7)
        #if os(iOS)
        static let systemGray6 = Color(.systemGray6)
        static let systemGray4 = Color(.systemGray4)
        #else
        static let systemGray6 = Color.gray.opacity(0.1)
        static let systemGray4 = Color.gray.opacity(0.3)
        #endif
        static let error = Color.red
        static let white = Color.white
        static let success = Color.green
        static let warning = Color.orange
        
        // Shadow colors
        static let shadowLight = Color.gray.opacity(0.07)
        static let shadowMedium = Color.gray.opacity(0.16)
        static let shadowBorder = Color.gray.opacity(0.6)
        
        // Black shadow colors
        static let shadowBlackLight = Color.black.opacity(0.04)
        static let shadowBlackMedium = Color.black.opacity(0.06)
        static let shadowBlackStrong = Color.black.opacity(0.5)
    }
    
    // MARK: - Fonts
    struct Fonts {
        // Primary Fonts - Consistent across the app
        static let title = Font.custom("CormorantGaramond-Bold", size: 32)
        static let heading = Font.custom("PlayfairDisplay-Regular", size: 28)
        static let headingItalic = Font.custom("PlayfairDisplay-Italic", size: 28)
        static let headingSC = Font.custom("PlayfairDisplaySC-Regular", size: 28)
        static let headingSCItalic = Font.custom("PlayfairDisplaySC-Italic", size: 28)
        static let headingSCBold = Font.custom("PlayfairDisplaySC-Bold", size: 28)
        
        // Body Text - Consistent NotoSans usage
        static let body = Font.custom("NotoSansSC-Regular", size: 16)
        static let bodyMedium = Font.custom("NotoSansSC-Regular", size: 16)
        static let bodySmall = Font.custom("NotoSansSC-Regular", size: 14)
        static let bodyTiny = Font.custom("NotoSansSC-Regular", size: 12)
        static let bodyTinyBold = Font.custom("NotoSansSC-Regular", size: 12)
        
        // Chinese Simplified - For specific cultural content
        static let bodyChinese = Font.custom("noto-sans-sc-chinese-simplified-400-normal", size: 16)
        static let bodyChineseMedium = Font.custom("noto-sans-sc-chinese-simplified-500-normal", size: 16)
        
        // Button Text
        static let button = Font.custom("NotoSansSC-Regular", size: 18)
        static let buttonSmall = Font.custom("NotoSansSC-Regular", size: 16)
        
        // Responsive Fonts
        static func responsiveTitle(_ width: CGFloat) -> Font {
            Font.custom("CormorantGaramond-Bold", size: width * 0.09)
        }
        
        static func responsiveHeading(_ width: CGFloat) -> Font {
            Font.custom("PlayfairDisplay-Regular", size: width * 0.065)
        }
        
        static func responsiveBody(_ width: CGFloat) -> Font {
            Font.custom("NotoSansSC-Regular", size: width * 0.04)
        }
        
        static func responsiveButton(_ width: CGFloat) -> Font {
            Font.custom("NotoSansSC-Regular", size: width * 0.045)
        }
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
        
        static func responsiveSmall(_ height: CGFloat) -> CGFloat {
            height * 0.015
        }
        
        static func responsiveMedium(_ height: CGFloat) -> CGFloat {
            height * 0.025
        }
        
        static func responsiveLarge(_ height: CGFloat) -> CGFloat {
            height * 0.04
        }
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 10
        static let medium: CGFloat = 20
        static let large: CGFloat = 40
    }
    
    // MARK: - Animation
    struct Animation {
        static let standard = SwiftUI.Animation.easeOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeOut(duration: 0.6)
        static let fast = SwiftUI.Animation.easeOut(duration: 0.2)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Shared Components
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    let isEnabled: Bool
    let isLoading: Bool
    let isSuccess: Bool
    @State private var isPressed = false
    
    init(_ title: String, isEnabled: Bool = true, isLoading: Bool = false, isSuccess: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.isSuccess = isSuccess
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if isEnabled {
                // Haptic feedback (iOS only)
                #if os(iOS)
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                #endif
                
                // Visual feedback
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
                
                // Reset after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
                
                // Execute action
                action()
            }
        }) {
            buttonContent
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.large)
                        .fill(buttonBackgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.large)
                        .stroke(buttonBorderColor, lineWidth: 2)
                )
        }
        .disabled(!isEnabled)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        // Onboarding-style emphasis: subtly lift and scale when the button is enabled
        .scaleEffect(isEnabled ? 1.03 : 0.96)
        .offset(y: isEnabled ? -4 : 0)
        .shadow(
            color: AppConstants.Colors.primary.opacity(isEnabled ? 0.25 : 0.0),
            radius: isEnabled ? 8 : 0,
            x: 0,
            y: isEnabled ? 6 : 0
        )
        .animation(.easeInOut(duration: 0.32), value: isEnabled)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
    
    @ViewBuilder
    private var buttonContent: some View {
        if isSuccess {
            HStack(spacing: 8) {
                Image(systemName: "checkmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text(title)
                    .font(.custom("NotoSans", size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
        } else if isLoading {
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.white)
                            .frame(width: 6, height: 6)
                            .scaleEffect(1.0 + 0.3 * sin(Double(index) * 0.5))
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                                value: isLoading
                            )
                    }
                }
                Text(title)
                    .font(.custom("NotoSans", size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
        } else {
            Text(title)
                .font(.custom("NotoSans", size: 18))
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
    
    private var buttonBackgroundColor: Color {
        if isSuccess {
            return Color.green
        } else if isEnabled {
            return AppConstants.Colors.primary
        } else {
            return AppConstants.Colors.primary.opacity(0.6)
        }
    }
    
    private var buttonBorderColor: Color {
        if isSuccess {
            return Color.clear
        } else if isEnabled {
            return Color.clear
        } else {
            return AppConstants.Colors.primary.opacity(0.4)
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    let isEnabled: Bool
    
    init(_ title: String, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("NotoSans", size: 18))
                .foregroundColor(AppConstants.Colors.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.large)
                        .stroke(AppConstants.Colors.primary, lineWidth: 2)
                )
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
}

 
