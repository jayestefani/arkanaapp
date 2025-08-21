import Foundation

// MARK: - App Configuration
struct AppConfiguration {
    
    // MARK: - Environment
    enum Environment: String, CaseIterable {
        case development = "development"
        case production = "production"
        
        var displayName: String {
            switch self {
            case .development:
                return "Development"
            case .production:
                return "Production"
            }
        }
    }
    
    // MARK: - Current Environment
    static let currentEnvironment: Environment = {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }()
    
    // MARK: - API Configuration
    struct API {
        static let baseURL: String = {
            switch AppConfiguration.currentEnvironment {
            case .development:
                return "http://localhost:3000/api"
            case .production:
                return "https://arkana-health-backend.onrender.com/api"
            }
        }()
        
        static let timeoutInterval: TimeInterval = 30
        static let maxRetries = 3
    }
    
    // MARK: - App Settings
    struct App {
        static let name = "Arkana Health"
        static let version = "1.0.0"
        static let buildNumber = "1"
        
        static var isDebug: Bool {
            #if DEBUG
            return true
            #else
            return false
            #endif
        }
    }
    
    // MARK: - Debug Information
    static var debugInfo: String {
        return """
        Environment: \(currentEnvironment.displayName)
        API Base URL: \(API.baseURL)
        App Version: \(App.version) (\(App.buildNumber))
        Debug Mode: \(App.isDebug)
        """
    }
}

// MARK: - Configuration Extensions
extension AppConfiguration {
    
    // MARK: - Phone Verification Service Configuration
    #if canImport(FirebaseAuth)
    static func getPhoneVerificationService() -> PhoneVerificationService {
        let service = PhoneVerificationService.shared
        // You can add any additional configuration here
        return service
    }
    #else
    static func getPhoneVerificationService() -> Any? {
        return nil
    }
    #endif
    
    // MARK: - Tongue Analysis Service Configuration
    static func getTongueAnalysisService() -> TongueAnalyzer {
        let analyzer = TongueAnalyzer()
        // You can add any additional configuration here
        return analyzer
    }
} 