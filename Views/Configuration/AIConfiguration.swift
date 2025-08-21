import Foundation

// MARK: - AI Configuration Manager
class AIConfiguration {
    static let shared = AIConfiguration()
    
    private init() {}
    
    // MARK: - API Keys
    var openAIAPIKey: String {
        // In production, use proper key management like Keychain
        // For development, you can set this in environment variables
        return ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    }
    
    // MARK: - API Configuration
    struct APIConfig {
        static let baseURL = "https://api.openai.com/v1/chat/completions"
        static let model = "gpt-4-vision-preview"
        static let maxTokens = 1500
        static let temperature = 0.7
        static let timeoutInterval: TimeInterval = 60
    }
    
    // MARK: - Image Processing
    struct ImageConfig {
        static let maxImageSize: CGFloat = 1024
        static let compressionQuality: CGFloat = 0.8
        static let supportedFormats = ["jpeg", "jpg", "png"]
    }
    
    // MARK: - Analysis Settings
    struct AnalysisConfig {
        static let confidenceThreshold: Double = 0.6
        static let maxRetries = 3
        static let retryDelay: TimeInterval = 2.0
    }
    
    // MARK: - Validation
    var isConfigured: Bool {
        return !openAIAPIKey.isEmpty && openAIAPIKey != "YOUR_OPENAI_API_KEY"
    }
    
    // MARK: - Error Messages
    struct ErrorMessages {
        static let invalidAPIKey = "OpenAI API key is not configured. Please add your API key to the environment variables."
        static let networkError = "Network connection error. Please check your internet connection and try again."
        static let rateLimitExceeded = "Rate limit exceeded. Please wait a moment and try again."
        static let serverError = "Server error occurred. Please try again later."
        static let invalidResponse = "Invalid response from AI service. Please try again."
        static let imageProcessingError = "Error processing the image. Please try with a different photo."
    }
}

// MARK: - Environment Variable Helper
extension ProcessInfo {
    func environmentValue(for key: String) -> String? {
        return environment[key]
    }
}

// MARK: - Secure Storage (for production use)
class SecureStorage {
    static let shared = SecureStorage()
    
    private init() {}
    
    // MARK: - Keychain Operations
    func saveAPIKey(_ key: String, for service: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecValueData as String: key.data(using: .utf8)!
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func retrieveAPIKey(for service: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return key
    }
    
    func deleteAPIKey(for service: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}

// MARK: - Configuration Validation
extension AIConfiguration {
    func validateConfiguration() -> [String] {
        var errors: [String] = []
        
        if !isConfigured {
            errors.append(ErrorMessages.invalidAPIKey)
        }
        
        return errors
    }
    
    func getConfigurationStatus() -> ConfigurationStatus {
        if isConfigured {
            return .configured
        } else {
            return .notConfigured
        }
    }
}

// MARK: - Configuration Status
enum ConfigurationStatus {
    case configured
    case notConfigured
    
    var description: String {
        switch self {
        case .configured:
            return "AI Configuration is ready"
        case .notConfigured:
            return "AI Configuration needs setup"
        }
    }
    
    var isReady: Bool {
        switch self {
        case .configured:
            return true
        case .notConfigured:
            return false
        }
    }
} 