import Foundation
import SwiftUI

// MARK: - Button Content Manager
class ButtonContentManager: ObservableObject {
    static let shared = ButtonContentManager()
    
    @Published var buttonContents: [ButtonContent] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let firebaseManager = FirebaseManager.shared
    
    private init() {}
    
    // Load button contents for a specific screen
    func loadButtonContents(for screen: String) async {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        do {
            let contents = try await firebaseManager.getButtonContents(for: screen)
            await MainActor.run {
                self.buttonContents = contents.sorted { $0.order < $1.order }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // Get button content by ID
    func getButtonContent(for buttonId: String) -> ButtonContent? {
        return buttonContents.first { $0.buttonId == buttonId }
    }
    
    // Get button contents for a specific screen
    func getButtonContents(for screen: String) -> [ButtonContent] {
        return buttonContents.filter { $0.screen == screen }.sorted { $0.order < $1.order }
    }
}

// MARK: - Dynamic Button View
struct DynamicButton: View {
    let buttonContent: ButtonContent
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let iconName = buttonContent.iconName {
                    Image(systemName: iconName)
                        .foregroundColor(Color(hex: buttonContent.textColor))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(buttonContent.title)
                        .font(.custom("NotoSans", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: buttonContent.textColor))
                    
                    if let subtitle = buttonContent.subtitle {
                        Text(subtitle)
                            .font(.custom("NotoSans", size: 12))
                            .foregroundColor(Color(hex: buttonContent.textColor).opacity(0.8))
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(hex: buttonContent.backgroundColor))
            .cornerRadius(12)
        }
        .disabled(!buttonContent.isEnabled)
        .opacity(buttonContent.isEnabled ? 1.0 : 0.6)
    }
}

 