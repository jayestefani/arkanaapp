import Foundation

// Check if Firebase is available
#if canImport(FirebaseAuth)
import FirebaseAuth
import Firebase

class PhoneVerificationService: ObservableObject {
    static let shared = PhoneVerificationService()
    
    @Published var verificationID: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Development mode for testing - always enabled due to Firebase Auth API changes
    private let isDevelopmentMode = true // TODO: Set to false when Firebase Auth API is properly configured
    @Published var isDevelopmentSignedIn = false
    
    private init() {}
    
    // MARK: - Test Firebase Configuration
    func testFirebaseConfiguration() -> String {
        var status = "Firebase Configuration Test:\n"
        
        // Check if Firebase is configured
        if FirebaseApp.app() != nil {
            status += "✅ Firebase App configured\n"
        } else {
            status += "❌ Firebase App not configured\n"
            return status
        }
        
        // Check if Auth is available
        _ = Auth.auth()
        status += "✅ Firebase Auth available\n"
        
        // Note: PhoneAuthProvider API has changed in current Firebase version
        status += "⚠️ PhoneAuthProvider API needs update for current Firebase version\n"
        status += "🔧 Using development mode for phone verification\n"
        
        return status
    }
    
    fileprivate func _sendVerificationCode(to phoneNumber: String) async throws {
        print("DEBUG: sendVerificationCode called with: \(phoneNumber)")
        print("🔍 DEBUG: Checking if this is a test phone number...")
        print("🔍 DEBUG: Phone number format: \(phoneNumber)")
        print("🔍 DEBUG: Expected test format: +16503034654")
        print("🔍 DEBUG: Is test number: \(phoneNumber == "+16503034654")")
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Development mode - use mock verification for simulator
        if isDevelopmentMode {
            print("🔧 DEVELOPMENT MODE: Using mock verification")
            // Simulate network delay
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            await MainActor.run {
                verificationID = "mock_verification_id_12345"
                isLoading = false
            }
            return
        }
        
        // Defensive: Check Firebase is configured
        guard FirebaseApp.app() != nil else {
            print("ERROR: FirebaseApp not configured")
            await MainActor.run {
                isLoading = false
                errorMessage = "Firebase is not configured."
            }
            throw NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase is not configured."])
        }
        
        // Auto-format phone number: add +1 if missing and 10 digits
        var formattedPhone = phoneNumber
        let digits = phoneNumber.filter { $0.isWholeNumber }
        if digits.count == 10 && !phoneNumber.hasPrefix("+1") {
            formattedPhone = "+1" + digits
        }

        print("🔍 DEBUG: Final formatted phone: \(formattedPhone)")
        print("🔍 DEBUG: Should work with test number: \(formattedPhone == "+16503034654")")

        // Defensive: Check phone number format
        guard formattedPhone.hasPrefix("+1") && formattedPhone.count == 12 else {
            print("ERROR: Invalid phone number format: \(formattedPhone)")
            await MainActor.run {
                isLoading = false
                errorMessage = "Invalid phone number format. Expected 10 digits (US) or +1XXXXXXXXXX."
            }
            throw NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid phone number format"])
        }

        do {
            // For now, use development mode only since Firebase Auth API has changed
            // TODO: Update when Firebase Auth API is properly configured
            print("🔧 DEVELOPMENT MODE: Using mock verification due to Firebase Auth API changes")
            
            // Simulate network delay
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            await MainActor.run {
                self.verificationID = "mock_verification_id_12345"
                self.isLoading = false
            }
        }
    }
    
    fileprivate func _verifyCode(_ code: String) async throws {
        // Development mode - accept any 6-digit code
        if isDevelopmentMode {
            print("🔧 DEVELOPMENT MODE: Mock code verification")
            // Simulate network delay
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            await MainActor.run {
                isDevelopmentSignedIn = true
                isLoading = false
            }
            return
        }
        
        guard verificationID != nil else {
            throw NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "No verification ID available"])
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // For now, use development mode only since Firebase Auth API has changed
        // TODO: Update when Firebase Auth API is properly configured
        print("🔧 DEVELOPMENT MODE: Using mock credential verification")
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        await MainActor.run {
            isLoading = false
            print("✅ Mock phone verification successful")
        }
    }
    
    fileprivate func _signOut() async throws {
        if isDevelopmentMode {
            print("🔧 DEVELOPMENT MODE: Mock sign out")
            await MainActor.run {
                isDevelopmentSignedIn = false
            }
            return
        }
        
        do {
            try Auth.auth().signOut()
            await MainActor.run {
                print("✅ User signed out successfully")
            }
        } catch {
            print("ERROR: Sign out failed: \(error)")
            throw error
        }
    }
    
    // MARK: - Get Current User
    var currentUser: User? {
        if isDevelopmentMode {
            // For development mode, return nil since we can't create a proper Firebase User
            return isDevelopmentSignedIn ? nil : nil
        }
        return Auth.auth().currentUser
    }
    
    // MARK: - Check if User is Signed In
    var isSignedIn: Bool {
        if isDevelopmentMode {
            return isDevelopmentSignedIn
        }
        return Auth.auth().currentUser != nil
    }
    
    // MARK: - Get User ID
    var userId: String? {
        if isDevelopmentMode {
            return isDevelopmentSignedIn ? "dev_user_123" : nil
        }
        return Auth.auth().currentUser?.uid
    }
    
    // MARK: - Get Phone Number
    var phoneNumber: String? {
        if isDevelopmentMode {
            return "+16503034654"
        }
        return Auth.auth().currentUser?.phoneNumber
    }
    
    // MARK: - Main Entry Points
    func sendVerificationCode(to phoneNumber: String) async throws {
        try await _sendVerificationCode(to: phoneNumber)
    }
    
    func verifyCode(_ code: String) async throws {
        try await _verifyCode(code)
    }
    
    func signOut() async throws {
        try await _signOut()
    }
}

#else
// Fallback implementation when Firebase is not available
class PhoneVerificationService: ObservableObject {
    static let shared = PhoneVerificationService()
    
    @Published var verificationID: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // MARK: - Test Firebase Configuration
    func testFirebaseConfiguration() -> String {
        return "Firebase not available"
    }
    
    // MARK: - Send Verification Code
    func sendVerificationCode(to phoneNumber: String) async throws {
        isLoading = true
        errorMessage = "Firebase not configured. Please install Firebase SDK."
        isLoading = false
        throw NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase SDK not installed"])
    }
    
    // MARK: - Verify Code
    func verifyCode(_ code: String) async throws {
        throw NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase SDK not installed"])
    }
    
    // MARK: - Sign Out
    func signOut() async throws {
        // No-op when Firebase is not available
    }
    
    // MARK: - Get Current User
    var currentUser: Any? {
        return nil
    }
    
    // MARK: - Check if User is Signed In
    var isSignedIn: Bool {
        return false
    }
    
    // MARK: - Get User ID
    var userId: String? {
        return nil
    }
    
    // MARK: - Get Phone Number
    var phoneNumber: String? {
        return nil
    }
}
#endif 
